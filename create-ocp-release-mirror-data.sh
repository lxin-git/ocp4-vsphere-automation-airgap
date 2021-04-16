#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
OCP_RELEASE=$1
MIRRORDIR=${SCRIPT_DIR}/ocp${OCP_RELEASE}
mkdir -p ${MIRRORDIR}
export LOCAL_REGISTRY='xbox-mirror.fyre.ibm.com:5000'
export LOCAL_REPOSITORY='ocp4/openshift4'
export PRODUCT_REPO='openshift-release-dev'
export LOCAL_SECRET_JSON='/data/images/mirror-data/pull-secret.json'
export RELEASE_NAME="ocp-release"
export ARCHITECTURE='x86_64'


curl -kLo ${MIRRORDIR}/openshift-client-linux.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_RELEASE}/openshift-client-linux.tar.gz
tar xvf ${MIRRORDIR}/openshift-client-linux.tar.gz
./oc adm release mirror -a ${LOCAL_SECRET_JSON}  \
     --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} \
     --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} \
     --to-release-image=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}:${OCP_RELEASE}-${ARCHITECTURE} --dry-run


./oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${MIRRORDIR}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}
