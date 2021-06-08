ARG VERSION=0.15.15
FROM smallstep/step-ca:${VERSION}

USER root
WORKDIR /home/step
ADD extras/entrypoint.sh /app/entrypoint.sh
ADD extras/logger.sh /app/logger.sh

ENV STEP=/home/step \
    STEPPATH=/home/step \
    CONFIGPATH=${STEPPATH}/config/ca.json \
    PWDPATH=${ROOT_CA_PASS:-${STEPPATH}/secrets/password}

RUN apk add --no-cache \
        jq \
        openssl

RUN chmod a+x /app/entrypoint.sh

USER step

ENTRYPOINT ["/bin/bash"]
CMD ["/app/entrypoint.sh"]

################### Don't move ###################
ARG BUILD_DATE
ARG BUILD_VCS_REF
ARG BUILD_VERSION
ARG BUILD_PROJECT_URL
ARG BUILD_COMMITER_NAME
ARG BUILD_COMMITER_MAIL
LABEL ar.com.scabb-island.ca-provider-api.maintainer="Manuel Andres Garcia Vazquez <mvazquez@scabb-island.com.ar>" \
      ar.com.scabb-island.ca-provider-api.license=GPL-3.0 \
      ar.com.scabb-island.ca-provider-api.build-date=${BUILD_DATE} \
      ar.com.scabb-island.ca-provider-api.vcs.url="${BUILD_PROJECT_URL}" \
      ar.com.scabb-island.ca-provider-api.vcs.ref.sha=${BUILD_VCS_REF} \
      ar.com.scabb-island.ca-provider-api.vcs.ref.name=${BUILD_VERSION} \
      ar.com.scabb-island.ca-provider-api.vcs.commiter="${BUILD_COMMITER_NAME} <${BUILD_COMMITER_MAIL}>"
##################################################