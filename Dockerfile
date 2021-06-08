ARG VERSION=0.15.15
FROM docker.scm.primary/smallstep/step-ca:${VERSION}

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
        openssl \
        expect

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
LABEL ar.com.matbarofex.ca-provisioner.maintainer="ISBA DevOps <devops@primary.com.ar>" \
      ar.com.matbarofex.ca-provisioner.license=GPL-3.0 \
      ar.com.matbarofex.ca-provisioner.build-date=${BUILD_DATE} \
      ar.com.matbarofex.ca-provisioner.vcs.url="${BUILD_PROJECT_URL}" \
      ar.com.matbarofex.ca-provisioner.vcs.ref.sha=${BUILD_VCS_REF} \
      ar.com.matbarofex.ca-provisioner.vcs.ref.name=${BUILD_VERSION} \
      ar.com.matbarofex.ca-provisioner.vcs.commiter="${BUILD_COMMITER_NAME} <${BUILD_COMMITER_MAIL}>"
##################################################