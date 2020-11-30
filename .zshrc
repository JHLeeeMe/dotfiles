# Path to your oh-my-zsh installation.
export ZSH="/home/jhleeeme/.oh-my-zsh"

# CUSTOM PATH
# ZSH_CUSTOM=$ZSH/custom

#########
# Theme #
#########
ZSH_THEME="JHLeeeMe-Zsh-Theme/JHLeeeMe"
#ZSH_THEME="agnoster"
#ZSH_THEME="aussiegeek"
#ZSH_THEME="gnzh"
#ZSH_THEME="powerlevel10k/powerlevel10k"


# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	alias-tips
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source ~/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/plugins/alias-tips/alias-tips.plugin.zsh


############
# init env #
############
export PATH=.:/home/jhleeeme/Project/bin:$PATH

#########
# alias #
#########
alias ll="ls -alhF --color=auto"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias pack="mvn package -DskipTests"


neofetch
