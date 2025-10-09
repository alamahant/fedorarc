if [ $(id -u) -eq 0 ]; then
    export PS1='\[\033[1;31m\][\u@\h \W]#\[\033[0m\] '
else
    export PS1='\[\033[1;32m\][\u@\h \W]\$\[\033[0m\] '
fi
