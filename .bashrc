shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000


PS1="\[\033[38m\]\h:\[\033[01;34m\]\$(pwd30)\[\033[32m\]\$(__git_ps1 ' [%s]')\[\033[37m\] $\[\033[00m\] "
PS1="\[\033[38m\]\h:\[\e[38;05;38m\]\$(pwd30)\[\033[32m\]\$(__git_ps1 ' [%s]')\[\033[37m\] $\[\033[00m\] "

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export EDITOR="vim -f"

export PATH=$PATH:~/bin
export LSCOLORS=fxfxcxdxbxegedabagacad

# Auto-screen invocation. see: http://taint.org/wk/RemoteLoginAutoScreen
# if we're coming from a remote SSH connection, in an interactive session
# then automatically put us into a screen(1) session.   Only try once
# -- if $STARTED_SCREEN is set, don't try it again, to avoid looping
# if screen fails for some reason.
# TODO: more testing needed
# if [ "$PS1" != "" -a "${STARTED_SCREEN:-x}" = x -a "${SSH_TTY:-x}" != x ]
# then
#   STARTED_SCREEN=1 ; export STARTED_SCREEN
#   [ -d $HOME/lib/screen-logs ] || mkdir -p $HOME/lib/screen-logs
#   sleep 1
#   screen -RR && exit 0
#   # normally, execution of this rc script ends here...
#   echo "Screen failed! continuing with normal bash startup"
# fi
# [end of auto-screen snippet]

# vim mode
set -o vi
