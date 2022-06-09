# .bashrc

# User specific aliases and functions
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias s='cd ..'
alias d='ls'
alias p='cd -'

# Need for a xterm & co if we don't make a -ls
[ -n $DISPLAY ] && {
	[ -f /etc/profile.d/color_ls.sh ] && source /etc/profile.d/color_ls.sh
	 export XAUTHORITY=$HOME/.Xauthority
}

# Read first /etc/inputrc if the variable is not defined, and after the /etc/inputrc 
# include the ~/.inputrc
[ -z $INPUTRC ] && export INPUTRC=/etc/inputrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
