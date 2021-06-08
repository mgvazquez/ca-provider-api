#!/bin/echo "Warning: this library should be sourced!"

############## Logging Variables #############
declare -x ESC_CHAR=${ESC_CHAR:-"\033"} # If the colors fail, replace the '\033' to '\E' or '\e'

# Font Types
declare -x FT_NORM="${ESC_CHAR}[0m"
declare -x FT_BOLD="${ESC_CHAR}[1m"
declare -x FT_UNDERLINE="${ESC_CHAR}[4m"
declare -x FT_BLINK="${ESC_CHAR}[5m"

# Font Color
declare -x FC_BLACK="${ESC_CHAR}[30m"
declare -x FC_RED="${ESC_CHAR}[31m"
declare -x FC_GREEN="${ESC_CHAR}[32m"
declare -x FC_YELLOW="${ESC_CHAR}[33m"
declare -x FC_BLUE="${ESC_CHAR}[34m"
declare -x FC_VIOLET="${ESC_CHAR}[35m"
declare -x FC_CYAN="${ESC_CHAR}[36m"
declare -x FC_WHITE="${ESC_CHAR}[37m"

# Font Background Color
declare -x FB_BLACK="${ESC_CHAR}[40m"
declare -x FB_RED="${ESC_CHAR}[41m"
declare -x FB_GREEN="${ESC_CHAR}[42m"
declare -x FB_YELLOW="${ESC_CHAR}[43m"
declare -x FB_BLUE="${ESC_CHAR}[44m"
declare -x FB_VIOLET="${ESC_CHAR}[45m"
declare -x FB_CYAN="${ESC_CHAR}[46m"
declare -x FB_WHITE="${ESC_CHAR}[47m"
##############################################

################# DEBUG MODE #################
# Set debug parameters base on 'CI_DEBUG_TRACE' value
if echo "${CI_DEBUG_TRACE}" | grep -q '^[Tt]rue$'; then
  set -xe -o pipefail
  export LOG_LEVEL="${LOG_LEVEL:-DEBUG}"
else
  set -e -o pipefail
  export LOG_LEVEL="${LOG_LEVEL:-INFO}"
fi
##############################################

############## Loggers Handlers ##############

# Name: __projGetVersion
# Type: Private
# Note: Don't use directly - Use debug, info, warn or error
function __utils_log() {
    [[ -z ${1} ]] && local _severity="DEBUG" || local _severity="${1^^}"; shift;
    [[ -z ${FUNCNAME[2]} ]] && local _father="MAIN" || local _father="${FUNCNAME[2]^^}"
    LOG_LEVEL="${LOG_LEVEL^^}"
    local _data
    local _typeColor
    local _date="${FT_BOLD}$(date "+%Y/%m/%d %T")${FT_NORM}"
    while read _data
    do
        case ${LOG_LEVEL}_${_severity} in
            DEBUG_* | INFO_INFO | INFO_WARN | INFO_ERROR | WARN_WARN | WARN_ERROR | ERROR_ERROR )
                case ${_severity} in
                  ERROR ) local _typeColor="${FT_BOLD}${FC_RED}";;
                  WARN  ) local _typeColor="${FT_BOLD}${FC_YELLOW}";;
                  INFO  ) local _typeColor="${FT_BOLD}${FC_GREEN}";;
                  DEBUG ) local _typeColor="${FT_BOLD}${FC_CYAN}";;
                esac
                echo -e "${_date} [${FT_BOLD}${_father}${FT_NORM}]\t[${_typeColor}${_severity}${FT_NORM}]\t${_data}";;
            NONE_* | ERROR_* | WARN_* | INFO_* ) continue;;
            * ) echo -e "${_date} [${FT_BOLD}${_father}${FT_NORM}]\t[${FT_BOLD}${FC_RED}ERROR${FT_NORM}]\t\"${LOG_LEVEL}\", isn't valid as logging level. (Try DEBUG, INFO, ERROR or NONE)\
                          \n[${FT_BOLD}${_father}${FT_NORM}]\t[${FT_BOLD}${FC_GREEN}INFO${FT_NORM}]\t${0##*/}";;
        esac
    done
}

# Name: debug
# Type: Public
# Use: <command> | debug
# Note: The return/exit code of the logged command can be gained from vector PIPESTATUS at index 0 -> ${PIPESTATUS[0]}
function debug() { local _data; while read _data; do echo "${_data}" | __utils_log debug; done }

# Name: info
# Type: Public
# Use: <command> | info
# Note: The return/exit code of the logged command can be gained from vector PIPESTATUS at index 0 -> ${PIPESTATUS[0]}
function info() { local _data; while read _data; do echo "${_data}" | __utils_log info; done }

# Name: warn
# Type: Public
# Use: <command> | warn
# Note: The return/exit code of the logged command can be gained from vector PIPESTATUS at index 0 -> ${PIPESTATUS[0]}
function warn() { local _data; while read _data; do echo "${_data}" | __utils_log warn; done }

# Name: error
# Type: Public
# Use: <command> | error
# Note: The return/exit code of the logged command can be gained from vector PIPESTATUS at index 0 -> ${PIPESTATUS[0]}
function error() { local _data; while read _data; do echo "${_data}" | __utils_log error; done }
##############################################