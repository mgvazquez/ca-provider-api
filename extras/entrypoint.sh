#!/usr/bin/env bash

export CI_DEBUG_TRACE=${CI_DEBUG_TRACE:-false}
source /app/logger.sh

export CA_PROVIDER_LONG_NAME=${CA_PROVIDER_LONG_NAME:-'Dummy Ltd'}
export CA_PROVIDER_SHORT_NAME=${CA_PROVIDER_SHORT_NAME:-'dummy'}
export CA_PROVIDER_URL=${CA_PROVIDER_URL:-'localhost,127.0.0.1'}
export CA_PROVIDER_MAIL=${CA_PROVIDER_MAIL:-'ca@dummy.int'}
export CA_PROVIDER_CONFIG=${CA_PROVIDER_CONFIG:-${STEPPATH}/config/ca.json}
export CA_PROVIDER_DEFAULT=${CA_PROVIDER_DEFAULT:-${STEPPATH}/cconfig/defaults.json}

export MAX_CERT_DURATION='26280h'
export DEFAULT_CERT_DURATION='2160h'

export ROOT_CA_PATH=${ROOT_CA_PATH:-'/certs'}
export ROOT_CA_PASS="${ROOT_CA_PASS:-${ROOT_CA_PATH}/password}"
export ROOT_CA_CERT="${ROOT_CA_CERT:-${ROOT_CA_PATH}/rootca.crt}"
export ROOT_CA_KEY="${ROOT_CA_KEY:-${ROOT_CA_PATH}/rootca.key}"
export ROOT_CA_DUMMY="${ROOT_CA_DUMMY:-false}"

export STEP_PARAMS

# Valida la preexistencia de los archivos rootca.<crt|key|pass>
function rootCaChk() {
  local _exit=false
  local _crt=false; local _crtChk="${FT_BOLD}${FC_GREEN}OK${FT_NORM}"
  local _key=false; local _keyChk="${FT_BOLD}${FC_GREEN}OK${FT_NORM}"
  local _pass=false; local _passChk="${FT_BOLD}${FC_GREEN}OK${FT_NORM}"
  mkdir -p ${STEPPATH}/secrets
  if ${ROOT_CA_DUMMY}; then
    if [[ ! -f ${ROOT_CA_PASS} ]]; then
      local _password="$(openssl rand -base64 32)"
      echo "${_password}" > ${ROOT_CA_PASS}
      echo -e "Auto-Generated RootCA Key Password: ${FT_BOLD}${FC_RED}${_password}${FT_NORM}" | info
    fi
    export STEP_PARAMS=""
  else
    [[ -f "${ROOT_CA_CERT}" ]] || { _crtChk="${FT_BOLD}${FC_RED}FAIL${FT_NORM}";  _exit=true; }
    [[ -f "${ROOT_CA_KEY}"  ]] || { _keyChk="${FT_BOLD}${FC_RED}FAIL${FT_NORM}";  _exit=true; }
    [[ -f "${ROOT_CA_PASS}" ]] || { _passChk="${FT_BOLD}${FC_RED}FAIL${FT_NORM}"; _exit=true; }
    echo -e "RootCA (crt)  validation: ${_crtChk} [${ROOT_CA_CERT}]" | info
    echo -e "RootCA (key)  validation: ${_keyChk} [${ROOT_CA_KEY}]" | info
    echo -e "RootCA (pass) validation: ${_passChk} [${ROOT_CA_PASS}]" | info
    if ${_exit}; then exit 1; fi
    cat "${ROOT_CA_PASS}" > ${STEPPATH}/secrets/password
    export ROOT_CA_PASS=${STEPPATH}/secrets/password
    export STEP_PARAMS="--root=${ROOT_CA_CERT} --key=${ROOT_CA_KEY}"
  fi
  return 0
}

function stepInit() {
  if [[ ! -f "${CA_PROVIDER_CONFIG}" ]] && [[ ! -f "${CA_PROVIDER_DEFAULT}" ]]; then
    step ca init \
    --address=:443 \
    --name="${CA_PROVIDER_LONG_NAME}" \
    --dns="${CA_PROVIDER_URL}" \
    --issuer="${CA_PROVIDER_LONG_NAME}"\
    --provisioner=${CA_PROVIDER_MAIL} \
    --password-file=${ROOT_CA_PASS} \
    --provisioner-password-file=${ROOT_CA_PASS} \
    ${STEP_PARAMS} | info
  fi
  return 0
}

function stepAddAcmeProvider(){
  local _maxCertificateDuration=${MAX_CERT_DURATION:-'26280h'}
  local _DefaultCertificateDuration=${DEFAULT_CERT_DURATION:-'2160h'}
  if [[ "x$(jq --arg provider "${CA_PROVIDER_SHORT_NAME}" '.authority.provisioners[] | select(.name == $provider)' ${CA_PROVIDER_CONFIG})" == "x" ]]; then
    step ca provisioner add "${CA_PROVIDER_SHORT_NAME}" --type ACME
  fi
  echo $( cat "${CA_PROVIDER_CONFIG}" | jq \
    --arg provider "${CA_PROVIDER_SHORT_NAME}" \
    --arg maxcertdur "${_maxCertificateDuration}" \
    --arg defcertdur "${_DefaultCertificateDuration}" \
    '.authority.provisioners |= map(if .name == $provider then . + {"claims":{"maxTLSCertDuration":$maxcertdur,"defaultTLSCertDuration":$defcertdur}} else . end)' ) > ${CA_PROVIDER_CONFIG}
  return $?
}

rootCaChk
stepInit
stepAddAcmeProvider
exec /usr/local/bin/step-ca --password-file ${ROOT_CA_PASS} ${CA_PROVIDER_CONFIG}