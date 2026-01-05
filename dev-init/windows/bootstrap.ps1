# [인코딩 강제 설정] 한글 깨짐 방지 및 외부 도구 통신 최적화
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# 실행 정책 확약 (WinGet DSC 모듈 로드 보장)
if ((Get-ExecutionPolicy -Scope Process) -ne 'Bypass') {
    Set-ExecutionPolicy Bypass -Scope Process -Force
}

# ---------------------------------------------------------
# 개발 환경 구축 엔진 (Standard UI - 2026 Edition)
# ---------------------------------------------------------

$StateFile = "$PSScriptRoot\.setup_state"
$ErrorActionPreference = "Stop"

# [함수] PowerShell 표준 선택 프롬프트
function Get-AnswerStandard {
    param ([string]$Message, [string]$Title = "환경 설정 확인")
    if ($Yes) { return $true }
    $yesChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "이 단계를 실행합니다."
    $noChoice = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "이 단계를 건너뜁니다."
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yesChoice, $noChoice)
    $result = $Host.UI.PromptForChoice($Title, $Message, $choices, 1) # 기본값 No
    return $result -eq 0
}

# [함수] 진행 상태 관리
function Test-Progress { param($Step) (Test-Path $StateFile) -and (Get-Content $StateFile | Select-String -Pattern "^$Step$") }
function Save-Progress { param($Step) Add-Content -Path $StateFile -Value $Step }

# [함수] 시스템 환경 진단 (빠른 자동 진단)
function Test-SystemEnvironment {
    Write-Host "`n[1/3] 시스템 환경 확인 (참고용)..." -ForegroundColor Cyan
    
    # 가상화 상태 (CIM 사용)
    $vt = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty HypervisorPresent
    Write-Host " [-] 가상화(VT) 상태: " -NoNewline
    if ($vt) { Write-Host "[정상] (Hypervisor 활성)" -ForegroundColor Green }
    else { Write-Host "[경고] (BIOS/UEFI 확인 필요)" -ForegroundColor Yellow }

    # 가용 메모리
    $freeRam = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
    Write-Host " [-] 가용 메모리: " -NoNewline; Write-Host "$($freeRam)GB" -ForegroundColor Gray

    # WinGet 확인
    $wingetExists = Get-Command winget -ErrorAction SilentlyContinue
    Write-Host " [-] WinGet 매니저: " -NoNewline
    if ($wingetExists) { 
        Write-Host "[확인됨]" -ForegroundColor Green 
    } else { 
        Write-Host "[미설치]" -ForegroundColor Red 
        if (Get-AnswerStandard "WinGet이 없습니다. 설치 가이드 페이지를 여시겠습니까?" "필수 도구 누락") {
            Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1"

            Write-Host "`n [!] 스토어에서 '업데이트' 또는 '설치' 버튼을 눌러주세요." -ForegroundColor Yellow
            Write-Host " [!] 완료 후 이 창을 닫고 다시 실행해 주세요." -ForegroundColor Cyan
            exit
        } else {
            Write-Host " [!] WinGet 없이는 진행이 불가능하여 종료합니다." -ForegroundColor Red
            exit
        }
    }
}

# --- 실행 흐름 시작 ---
try {
    Clear-Host
    $Today = Get-Date -Format "yyyy-MM-dd"
    Write-Host "`n=== $Today 개발 환경 자동화 (Bootstrap) ===" -ForegroundColor Cyan
    Write-Host "실행 시점: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray

    # 1. 자동 진단
    Test-SystemEnvironment

    # 2. 선언적 구성 (YAML 기반 개별 확인 설치)
    if (-not (Test-Progress "YamlConfigDone")) {
        $dscPath = "$PSScriptRoot\configuration.dsc.yaml"
    
        if (Test-Path $dscPath) {
            # 1. YAML에서 패키지 ID 추출 (정규표현식 활용)
            $packageList = Select-String -Path $dscPath -Pattern "id: (.+)" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }
        
            Write-Host "`n[구성 목록 감지됨]" -ForegroundColor Cyan
            $packageList | ForEach-Object { Write-Host " • $_" -ForegroundColor Gray }
            Write-Host "---------------------------------------------------------"

            # 2. 개별 확인 루프 시작
            $installedCount = 0
            foreach ($pkg in $packageList) {
                if (Get-AnswerStandard "'$pkg' 항목을 설치하시겠습니까?" "패키지 확인") {
                    Write-Host "[...] $pkg 설치를 시작합니다..." -ForegroundColor Magenta
                    
                    # 2026년 기준 가장 안정적인 설치 명령어 조합
                    # --silent: 무인 설치, --accept-*: 라이선스 자동 동의
                    winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host " [+] $pkg 설치 완료." -ForegroundColor Green
                        $installedCount++
                    } else {
                        Write-Host " [!] $pkg 설치 중 경고가 발생했거나 이미 설치되어 있습니다." -ForegroundColor Yellow
                    }
                }
            }
            
            # 모든 확인 절차가 끝났으므로 진행 상태 저장
            Save-Progress "YamlConfigDone"
            
            # [핵심] 설치 작업이 하나라도 있었다면 환경 변수 즉시 동기화
            if ($installedCount -gt 0) {
                Write-Host "`n[정보] 신규 도구 인식을 위해 시스템 환경 변수를 동기화합니다." -ForegroundColor Gray
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            }
        } else {
            Write-Host "[오류] 설정 파일($dscPath)을 찾을 수 없습니다." -ForegroundColor Red
        }
    }

    # 3. VSCode ext
    if (-not (Test-Progress "VscodeExtDone")) {
        if (Get-AnswerStandard "개발 생산성을 위한 VS Code 확장(Git 도구 등)을 설치하시겠습니까?" "3단계: 에디터 설정") {
            
            
            
            if (Get-Command code -ErrorAction SilentlyContinue) {
                Write-Host "[...] VS Code 확장 프로그램 설치 시작..." -ForegroundColor Magenta
                
                # 설치할 확장 프로그램 리스트
                $extensions = @(
                    "ms-vscode-remote.remote-containers", # Dev Containers (도커 개발 필수)
                    "mhutchie.git-graph",                 # Git Graph (GUI 브랜치 관리)
                    "eamodio.gitlens"                     # GitLens (강력한 Git 히스토리 추적)
                )

                foreach ($ext in $extensions) {
                    Write-Host " [+] 설치 중: $ext" -ForegroundColor Gray
                    & code --install-extension $ext --force | Out-Null
                }

                Write-Host " [!] 모든 확장 프로그램 설치 완료." -ForegroundColor Green
                Save-Progress "VscodeExtDone"
            } else {
                Write-Host " [!] VS Code가 PATH에 등록되지 않았거나 설치되지 않아 확장을 설치할 수 없습니다." -ForegroundColor Yellow
            }
        }
    }
    # 3. VS Code 설정 및 확장 설치 (백업 기능 포함)
    # if (-not (Test-Progress "VscodeExtDone")) {
    #     if (Get-AnswerStandard "VS Code 설정(JSON)을 백업 후 동기화하시겠습니까?" "3단계: 에디터 설정") {
            
    #         # [A] 경로 정의
    #         $sourceSettings = "$PSScriptRoot\configs\settings.json"
    #         $targetSettings = "$env:AppData\Code\User\settings.json"
    #         $backupSettings = "$targetSettings.orig"
    #         $targetDir = Split-Path $targetSettings

    #         # [B] 설정 파일 동기화 프로세스
    #         if (Test-Path $sourceSettings) {
    #             # 타겟 디렉토리가 없으면 생성
    #             if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
                
    #             # [실용주의 포인트] 기존 파일이 있다면 백업 생성
    #             if (Test-Path $targetSettings) {
    #                 if (-not (Test-Path $backupSettings)) {
    #                     # .orig 파일이 없을 때만 백업 (최초 원본 보존)
    #                     Copy-Item -Path $targetSettings -Destination $backupSettings -Force
    #                     Write-Host " [+] 기존 설정이 백업되었습니다: settings.json.orig" -ForegroundColor Gray
    #                 } else {
    #                     Write-Host " [-] 이미 백업 파일(.orig)이 존재하여 추가 백업을 건너뜁니다." -ForegroundColor Gray
    #                 }
    #             }

    #             # 파일 복사
    #             Copy-Item -Path $sourceSettings -Destination $targetSettings -Force
    #             Write-Host " [+] VS Code 설정 동기화 완료." -ForegroundColor Green
    #         }

    #         # [C] .bashrc 동기화 및 백업
    #         $sourceBashrc = "$PSScriptRoot\configs\.bashrc"
    #         $targetBashrc = "$env:UserProfile\.bashrc"
    #         $backupBashrc = "$targetBashrc.orig"

    #         if (Test-Path $sourceBashrc) {
    #             if (Test-Path $targetBashrc) {
    #                 if (-not (Test-Path $backupBashrc)) {
    #                     Copy-Item -Path $targetBashrc -Destination $backupBashrc -Force
    #                     Write-Host " [+] 기존 .bashrc가 백업되었습니다." -ForegroundColor Gray
    #                 }
    #             }
    #             Copy-Item -Path $sourceBashrc -Destination $targetBashrc -Force
    #             Write-Host " [+] .bashrc 동기화 완료." -ForegroundColor Green
    #         }

    #         # [D] 확장 프로그램 설치 로직 실행
    #         # & code --install-extension ...
            
    #         Save-Progress "VscodeExtDone"
    #     }
    # }


    # 정상 종료 처리
    Write-Host "`n🎉 모든 설정이 성공적으로 완료되었습니다!" -ForegroundColor Green
    if (Test-Path $StateFile) {
        Remove-Item $StateFile -Force
    }
} catch {
    Write-Host "`n[오류 발생] $_" -ForegroundColor Red
    Write-Host "스크립트가 중단되었습니다. 문제를 해결한 후 다시 실행해 주세요." -ForegroundColor Yellow
} finally {
    Write-Host "`n[종료] 아무 키나 누르면 창이 닫힙니다."
    pause
}

