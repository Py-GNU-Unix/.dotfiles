if [ -z "$BASHRCSOURCED" ]; then
  BASHRCSOURCED="Y"

  if [ "$PS1" ]; then
    if [ -z "$PROMPT_COMMAND" ]; then
      case $TERM in
      xterm*|vte*)
        if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
        elif [ "${VTE_VERSION:-0}" -ge 3405 ]; then
            PROMPT_COMMAND="__vte_prompt_command"
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        fi
        ;;
      screen*)
        if [ -e /etc/sysconfig/bash-prompt-screen ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
        else
            PROMPT_COMMAND='printf "\033k%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"'
        fi
        ;;
      *)
        [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
        ;;
      esac
    fi
    shopt -s histappend
    history -a
    shopt -s checkwinsize
    [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "
  fi

  if ! shopt -q login_shell ; then
    pathmunge () {
        case ":${PATH}:" in
            *:"$1":*)
                ;;
            *)
                if [ "$2" = "after" ] ; then
                    PATH=$PATH:$1
                else
                    PATH=$1:$PATH
                fi
        esac
    }
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 002
    else
       umask 022
    fi

    SHELL=/bin/bash
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null
            fi
        fi
    done

    unset i
    unset -f pathmunge
  fi

fi
function prompt { 
    prompt="{$(echo $HOSTNAME)-$(whoami)} $(pwd) >"
    PS1=""
    len_PS1="${#prompt}"
    part=$((255 / $len_PS1))
    for ((n_char = 0 ; n_char <= $len_PS1 ; n_char++)) 
    do   
        part=$((255 / $len_PS1))
        green="$(($part * $n_char))"
        char=${prompt:n_char:1}
        PS1="${PS1}\[\033[38;2;255;$green;0m\]$char"
    done 
    PS1="${PS1}\[\033[0;0;0;0;0m\] "    
}

PROMPT_COMMAND=prompt
