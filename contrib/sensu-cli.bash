# Sensu-cli bash completion
# 
# Move into /etc/bash_completion.d/ and re-login
# 
# Be sure that bash completion is enabled if not already:
# . /etc/bash_completion
#
_sensu_clients() {
  sensu-cli client list | grep name | cut -f 2 -d : | xargs
}
_sensu_checks() {
  sensu-cli check list | grep name | cut -f 2 -d : | xargs
}
_sensu_stashes() {
  sensu-cli stash list | grep path | cut -f 2 -d : | xargs
}
_sensu_aggregates() {
  sensu-cli aggregate list | grep check | cut -f 2 -d : | xargs
}
_sensu_silenced_checks() {
  sensu-cli silenced list | grep ^check: | cut -f 2- -d : | xargs
}
_sensu_silenced_ids() {
  sensu-cli silenced list | grep ^id: | cut -f 2- -d : | xargs
}
_sensu_silenced_subscriptions() {
  sensu-cli silenced list | grep ^subscription: | cut -f 2- -d : | xargs
}

_sensu-cli() {
  
#  echo "DEBUG: on word ${COMP_CWORD}"
  
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD-1]}
  prev2=${COMP_WORDS[COMP_CWORD-2]}
  
  
  # First level deep 
  if [ $COMP_CWORD -eq 1 ]; then
    SUB_COMMANDS="info client check event stash aggregate silence silenced resolve health -v --version -h --help"
    COMPREPLY=( $(compgen -W "${SUB_COMMANDS}" -- ${cur}) )
    return 0
  # Second level, after the sub commands 
  elif [ $COMP_CWORD -ge 2 ]; then
    case ${COMP_WORDS[1]} in 
      info)
        COMPREPLY=( $(compgen -W "-h --help" -- ${cur}) ) 
        return 0
      ;;
      event)
        if [ $COMP_CWORD -eq 2 ]; then
          EVENT_COMMANDS="list show delete -h --help"
          COMPREPLY=( $(compgen -W "$EVENT_COMMANDS" -- ${cur}) ) 
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          if [[ $prev == 'list' ]]; then
            EVENT_LIST_OPTS="--format -f"
            COMPREPLY=( $(compgen -W "$EVENT_LIST_OPTS" -- ${cur}) )        
            return 0
          elif [[ $prev == 'show' ]] || [[ $prev == 'delete' ]]; then
            COMPREPLY=( $(compgen -W "$(_sensu_clients)" -- ${cur}) )        
            return 0
          fi
        elif [ $COMP_CWORD -eq 4 ]; then
          if [[ $prev == '--format' ]] || [[ $prev == '-f' ]]; then
            COMPREPLY=( $(compgen -W "single table json" -- ${cur}) )
            return 0
          elif [[ $prev2 == 'show' ]]; then
            COMPREPLY=( $(compgen -W "--check -k --help -h" -- ${cur}) )
            return 0
          elif [[ $prev2 == 'delete' ]]; then
            COMPREPLY=( $(compgen -W "$(_sensu_checks)" -- ${cur}) )
            return 0
          fi
        fi
      ;;
      client)
        if [ $COMP_CWORD -eq 2 ]; then
          CLIENT_COMMANDS="list show delete history -h --help"
          COMPREPLY=( $(compgen -W "$CLIENT_COMMANDS" -- ${cur}) )        
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          if [[ $prev == 'list' ]]; then
            CLIENT_LIST_OPTS="--limit  -l --offset -o --format -f --fields -F"
            COMPREPLY=( $(compgen -W "$CLIENT_LIST_OPTS" -- ${cur}) )        
            return 0
          else 
            COMPREPLY=( $(compgen -W "$(_sensu_clients)" -- ${cur}) )        
            return 0
          fi
        elif [ $COMP_CWORD -eq 4 ]; then
          if [[ $prev == '--format' ]] || [[ $prev == '-f' ]]; then
            COMPREPLY=( $(compgen -W "single table json" -- ${cur}) )
            return 0
          else
            return 0
          fi
        fi
      ;;
      check)
        if [ $COMP_CWORD -eq 2 ]; then
          CHECK_COMMANDS="list show request -h --help"
          COMPREPLY=( $(compgen -W "$CHECK_COMMANDS" -- ${cur}) )        
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          if [[ $prev == 'show' ]] || [[ $prev == 'request' ]] ; then
            COMPREPLY=( $(compgen -W "$(_sensu_checks)" -- ${cur}) )        
            return 0
          else
            return 0
          fi
        fi
      ;;
      stash)
        if [ $COMP_CWORD -eq 2 ]; then
          STASH_COMMANDS="list show delete create -h --help"
          COMPREPLY=( $(compgen -W "$STASH_COMMANDS" -- ${cur}) )        
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          if [[ $prev == 'list' ]] ; then 
            STASH_LIST_ARGS="--limit -l --offset -o --format -f --help -h"
            COMPREPLY=( $(compgen -W "$STASH_LIST_ARGS" -- ${cur}) )        
          else
            COMPREPLY=( $(compgen -W "$(_sensu_stashes)" -- ${cur}) )        
          fi
        elif [ $COMP_CWORD -eq 4 ]; then
          if [[ $prev == '--format' ]] || [[ $prev == '-f' ]]; then
            COMPREPLY=( $(compgen -W "single table json" -- ${cur}) )
          else
            return 0
          fi
        fi
      ;;
      aggregate)
        if [ $COMP_CWORD -eq 2 ]; then
          AGG_COMMANDS="list show delete -h --help"
          COMPREPLY=( $(compgen -W "$AGG_COMMANDS" -- ${cur}) )        
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          if [[ $prev == 'show' ]] || [[ $prev == 'delete' ]]; then 
            COMPREPLY=( $(compgen -W "$(_sensu_aggregates)" -- ${cur}) )        
          else
            return 0
          fi
        elif [ $COMP_CWORD -eq 4 ]; then
            AGG_SHOW_ARGS="--id -i --limit -l --offset -o --help -h"  
            COMPREPLY=( $(compgen -W "$AGG_SHOW_ARGS" -- ${cur}) )        
            return 0
        fi
      ;;
      silence)
        if [ $COMP_CWORD -eq 2 ]; then
          COMPREPLY=( $(compgen -W "$(_sensu_clients)" -- ${cur}) )        
          return 0
        elif [[ $(($COMP_CWORD % 2 )) != 0 ]]; then
          # Cover most of the bases by only providing these options when on an odd
          # numbered argument, as each of them requires their own arg (on the even spot)
          SILENCE_OPTS="--check -k --owner -o --reason -r --expire -e --help -h"
          COMPREPLY=( $(compgen -W "$SILENCE_OPTS" -- ${cur}) )        
          return 0
        else
          # Otherwise we just return, we can't complete the OPTs above
          return 0
        fi
      ;;
      silenced)
        SILENCED_LIST_OPTS="--check -c --subscription -s --limit  -l --offset -o --subscription -s -h --help"
        SILENCED_CLEAR_OPTS="--id -i -c --check --subscription -s -h --help"
        SILENCED_CREATE_OPTS="-c --check -o --creator -r --reason -e --expire -f --expire-on-resolve -s --source --subscription -n -h --help"
        if [ $COMP_CWORD -eq 2 ]; then
          SILENCED_COMMANDS="list create clear -h --help"
          COMPREPLY=( $(compgen -W "$SILENCED_COMMANDS" -- ${cur}) )
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          if [[ $prev == 'list' ]]; then
            COMPREPLY=( $(compgen -W "$SILENCED_LIST_OPTS" -- ${cur}) )
            return 0
          elif [[ $prev == 'clear' ]]; then
            COMPREPLY=( $(compgen -W "$SILENCED_CLEAR_OPTS" -- ${cur}) )
            return 0
          elif [[ $prev == 'create' ]]; then
            COMPREPLY=( $(compgen -W "$SILENCED_CREATE_OPTS" -- ${cur}) )
            return 0
          fi
        elif [ $COMP_CWORD -gt 3 ]; then
          if [[ $prev == '--id' ]] || [[ $prev == '-i' ]]; then
            COMPREPLY=( $(compgen -W "$(_sensu_silenced_ids)" -- ${cur}) )
            return 0
          elif [[ $prev == '--check' ]] || [[ $prev == '-c' ]] && [[ ${COMP_WORDS[2]} == "clear" ]]; then
            COMPREPLY=( $(compgen -W "$(_sensu_silenced_checks)" -- ${cur}) )
            return 0
          elif [[ $prev == '--check' ]] || [[ $prev == '-c' ]] && [[ ${COMP_WORDS[2]} == "create" ]]; then
            COMPREPLY=( $(compgen -W "$(_sensu_checks)" -- ${cur}) )
            return 0
          elif [[ $prev == '--subscription' ]] || [[ $prev == '-s' ]] || [[ $prev == '-n' ]]; then
            COMPREPLY=( $(compgen -W "$(_sensu_silenced_subscriptions)" -- ${cur}) )
            return 0
          elif [[ ${COMP_WORDS[2]} -eq "list" ]]; then
            COMPREPLY=( $(compgen -W "$SILENCED_LIST_OPTS" -- ${cur}) )
            return 0
          elif [[ ${COMP_WORDS[2]} -eq "clear" ]]; then
            COMPREPLY=( $(compgen -W "$SILENCED_CLEAR_OPTS" -- ${cur}) )
            return 0
          elif [[ ${COMP_WORDS[2]} -eq "create" ]]; then
            COMPREPLY=( $(compgen -W "$SILENCED_CREATE_OPTS" -- ${cur}) )
            return 0
          else
            return 0
          fi
        fi
      ;;
      resolve)
        if [ $COMP_CWORD -eq 2 ]; then
          COMPREPLY=( $(compgen -W "$(_sensu_clients)" -- ${cur}) )
          return 0
        elif [ $COMP_CWORD -eq 3 ]; then
          # Try to complete the possible checks to resolve for this host
          COMPREPLY=( $(compgen -W "$(_sensu_checks)" -- ${cur}) )
          return 0
        fi 
      ;;
      health)
        if [[ $(($COMP_CWORD % 2 )) == 0 ]]; then
          HEALTH_COMMANDS="--consumers -c --messages -m --help -h"  
          COMPREPLY=( $(compgen -W "$HEALTH_COMMANDS" -- ${cur}) )
          return 0
        fi
      ;;
      *)
        return 0
      ;;
    esac
  fi

}
complete -F _sensu-cli sensu-cli
