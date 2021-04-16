#!/bin/bash
SCRIPT_DIR=$(cd $(dirname $0); pwd)
LOGDIR=${SCRIPT_DIR}/logs
CURDATETIME=`date +%Y%m%d-%H%M%S`
[ ! -d ${LOGDIR} ] && mkdir -p ${LOGDIR}
export ANSIBLE_LOG_PATH=${LOGDIR}/deployment-${CURDATETIME}.log

if [ $# -ne 1 ];then
  echo "Please input the cluster config file."
  echo "eg. `basename $0` mycluster-config.yml"
  exit 2
fi

CONFIGYML=$1

if [ ! -s ${CONFIGYML} ];then
  echo "cluster config file ${CONFIGYML} not found."
  exit 3
fi
ansible-playbook ${SCRIPT_DIR}/infra_start.yml -e @${CONFIGYML} -e '{restricted_network: true}'
