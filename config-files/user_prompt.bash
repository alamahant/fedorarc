if [ $(id -u) -eq 0 ]; then
    export PS1="\[\e[1;31m\][\u@\h \W]\$ \[\e[0m\]"
else
    export PS1="\[\e[1;32m\][\u@\h \W]\$ \[\e[0m\]"
fi
