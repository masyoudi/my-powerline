# Define this here so it can be used by all of the Powerline themes
THEME_CHECK_SUDO=${THEME_CHECK_SUDO:=true}

case $TERM in
        xterm*)
        TITLEBAR="\[\033]0;\w\007\]"
        ;;
        *)
        TITLEBAR=""
        ;;
esac

function set_color {
  set +u
  if [[ "${1}" != "-" ]]; then
    fg="38;5;${1}"
  fi
  if [[ "${2}" != "-" ]]; then
    bg="48;5;${2}"
    [[ -n "${fg}" ]] && bg=";${bg}"
  fi
  echo -e "\[\033[${fg}${bg}m\]"
}

function __my_powerline_user_info_prompt {
  local user_info=""
  local color=${USER_INFO_THEME_PROMPT_COLOR}

  if [[ "${THEME_CHECK_SUDO}" = true ]]; then
    if sudo -n uptime 2>&1 | grep -q "load"; then
      color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
    fi
  fi

  case "${MY_POWERLINE_PROMPT_USER_INFO_MODE}" in
    "sudo")
      if [[ "${color}" = "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
        user_info="!"
      fi
      ;;
    *)
      if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_CONNECTION}" ]]; then
        user_info="┌─╢ ${USER_INFO_SSH_CHAR}${USER}"
      else
        user_info="┌─╢ ${USER}"
      fi
      ;;
  esac
  [[ -n "${user_info}" ]] && echo "${user_info}|${color}"
}

function __my_powerline_ruby_prompt {
  local ruby_version=""

  if _command_exists rvm; then
    ruby_version="$(rvm_version_prompt)"
  elif _command_exists rbenv; then
    ruby_version=$(rbenv_version_prompt)
  fi

  [[ -n "${ruby_version}" ]] && echo "${RUBY_CHAR}${ruby_version}|${RUBY_THEME_PROMPT_COLOR}"
}

function __my_powerline_python_venv_prompt {
  set +u
  local python_venv=""

  if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
    python_venv="${CONDA_DEFAULT_ENV}"
    PYTHON_VENV_CHAR=${CONDA_PYTHON_VENV_CHAR}
  elif [[ -n "${VIRTUAL_ENV}" ]]; then
    python_venv=$(basename "${VIRTUAL_ENV}")
  fi

  [[ -n "${python_venv}" ]] && echo "${PYTHON_VENV_CHAR}${python_venv}|${PYTHON_VENV_THEME_PROMPT_COLOR}"
}

function __my_powerline_scm_prompt {
  local color=""
  local scm_prompt=""

  scm_prompt_vars

  if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
    if [[ "${SCM_DIRTY}" -eq 3 ]]; then
      color=${SCM_THEME_PROMPT_STAGED_COLOR}
    elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
      color=${SCM_THEME_PROMPT_UNSTAGED_COLOR}
    elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
      color=${SCM_THEME_PROMPT_DIRTY_COLOR}
    else
      color=${SCM_THEME_PROMPT_CLEAN_COLOR}
    fi
    if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
    elif [[ "${SCM_P4_CHAR}" == "${SCM_CHAR}" ]]; then
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
    fi
    echo "\$([[ -n \$(git branch 2> /dev/null) ]] && echo \" on \") ${scm_prompt}${scm}|${color}"
  fi
}

function __my_powerline_cwd_prompt {
  local cwd=$(pwd | sed "s|^${HOME}|~|")

  echo "at（ \W ）|${CWD_THEME_PROMPT_COLOR}"
}

function __my_powerline_hostname_prompt {
    echo "$(hostname -s)|${HOST_THEME_PROMPT_COLOR}"
}

function __my_powerline_wd_prompt {
  echo "\w|${CWD_THEME_PROMPT_COLOR}"
}

function __my_powerline_clock_with_sudo_prompt {
  local clock_info=""
  local color=${CLOCK_THEME_PROMPT_COLOR}

  if [[ "${THEME_CHECK_SUDO}" = true ]]; then
    if sudo -n uptime 2>&1 | grep -q "load"; then
      color=${CLOCK_THEME_PROMPT_COLOR_SUDO}
    fi
  fi

  case "${MY_POWERLINE_PROMPT_CLOCK_MODE}" in
    "sudo")
      if [[ "${color}" = "${CLOCK_THEME_PROMPT_COLOR_SUDO}" ]]; then
        clock_info="!"
      fi
      ;;
    *)
      if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_CONNECTION}" ]]; then
        clock_info="┌─[$(date +"${THEME_CLOCK_FORMAT}")"
      else
        clock_info="┌─[$(date +"${THEME_CLOCK_FORMAT}")"
      fi
      ;;
  esac
  [[ -n "${clock_info}" ]] && echo "${clock_info}|${color}"
}

function __my_powerline_clock_prompt {
  echo "$(date +"${THEME_CLOCK_FORMAT}")|${CLOCK_THEME_PROMPT_COLOR}"
}

function __my_powerline_battery_prompt {
  local color=""
  local battery_status="$(battery_percentage 2> /dev/null)"

  if [[ -z "${battery_status}" ]] || [[ "${battery_status}" = "-1" ]] || [[ "${battery_status}" = "no" ]]; then
    true
  else
    if [[ "$((10#${battery_status}))" -le 5 ]]; then
      color="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
    elif [[ "$((10#${battery_status}))" -le 25 ]]; then
      color="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
    else
      color="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}"
    fi
    ac_adapter_connected && battery_status="${BATTERY_AC_CHAR}${battery_status}"
    echo "${battery_status}%|${color}"
  fi
}

function __my_powerline_in_vim_prompt {
  if [ -n "$VIMRUNTIME" ]; then
    echo "${IN_VIM_THEME_PROMPT_TEXT}|${IN_VIM_THEME_PROMPT_COLOR}"
  fi
}

function __my_powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local separator_char="${MY_POWERLINE_LEFT_SEPARATOR}"
  local separator=""

  if [[ "${SEGMENTS_AT_LEFT}" -gt 0 ]]; then
    separator="$(set_color ${LAST_SEGMENT_COLOR} ${params[1]})${separator_char}${normal}"
  fi
  LEFT_PROMPT+="${separator}$(set_color - ${params[1]}) ${params[0]} ${normal}"
  LAST_SEGMENT_COLOR=${params[1]}
  (( SEGMENTS_AT_LEFT += 0 ))
}

function __my_powerline_last_status_prompt {
  [[ "$1" -ne 0 ]] && echo "${1}|${LAST_STATUS_THEME_PROMPT_COLOR}"
}

function __my_powerline_prompt_command {
  local last_status="$?" ## always the first
  local separator_char="${MY_POWERLINE_PROMPT_CHAR}"

  LEFT_PROMPT=""
  SEGMENTS_AT_LEFT=0
  LAST_SEGMENT_COLOR=""


  if [[ -n "${POWERLINE_PROMPT_DISTRO_LOGO}" ]]; then
      LEFT_PROMPT+="$(set_color ${PROMPT_DISTRO_LOGO_COLOR} ${PROMPT_DISTRO_LOGO_COLORBG})${PROMPT_DISTRO_LOGO}$(set_color - -)"
  fi

  ## left prompt ##
  for segment in $MY_POWERLINE_PROMPT; do
  local info="$(__my_powerline_${segment}_prompt)"
  [[ -n "${info}" ]] && __my_powerline_left_segment "${info}"
  done

  [[ "${last_status}" -ne 0 ]] && __my_powerline_left_segment $(__my_powerline_last_status_prompt ${last_status})
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${separator_char}${normal}"

  PS1="${TITLEBAR}\n${LEFT_PROMPT}\n └─➤ "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT \
        SEGMENTS_AT_LEFT
}

