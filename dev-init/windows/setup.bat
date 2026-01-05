@echo off
:: UTF-8 설정 및 한글 깨짐 방지
@chcp 65001 >nul 2>&1

:: 1. 관리자 권한 확인
net session >nul 2>&1

if %errorlevel% neq 0 (
    echo.
    echo "---------------------------------------------------------"
    echo "[권한 알림] 시스템 설정을 위해 관리자 권한 승격이 필요합니다."
    echo "---------------------------------------------------------"
    echo.
    
    :: 메시지를 echo로 미리 출력 (choice /M 오류 방지)
    echo "관리자 권한으로 승격하여 설치를 계속하시겠습니까? (10초 후 자동취소)"
    choice /T 10 /D N /C YN

    if errorlevel 2 (
        echo.
        echo "취소하였습니다. 설치를 중단합니다."
        timeout /t 3 >nul
        exit /b
    )

    :: 'Y'를 눌렀을 경우(errorlevel 1) 권한 승격 실행
    powershell -Command "Start-Process -FilePath '%0' -Verb RunAs"
    exit /b
)

:: 2. PowerShell 실행부
echo.
echo "---------------------------------------------------------"
echo "[System Setup] GitHub에서 최신 스크립트를 로드합니다."
echo "---------------------------------------------------------"
echo.

:: 2. 내부 로직인 bootstrap.ps1 호출
:: 로컬에 파일이 있다면 로컬 실행, 없다면 GitHub에서 직접 실행
if exist "%~dp0bootstrap.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bootstrap.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm raw.githubusercontent.com | iex"
)

pause
