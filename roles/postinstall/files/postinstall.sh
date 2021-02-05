#!/bin/bash
#-------------------------------------------------------------
# Script Name   : postinstall.sh (version 1.0)
# Outputs       : Step by Step logging info will pop to STDOUT
# Err Outputs   :
# Created by    : lixin@IBM
#         on    : 20200922
# Updated by    :
#         on    :
# Return Code   : 0 = Sucess
#               : 1 = BootStrap Not Completed
#               : 2 = Install Not Completed
#-------------------------------------------------------------
#set -x

#############################
# Variables to be configured
#############################

# log & trace config
SCRIPT_DIR=$(cd $(dirname $0); pwd)
LOGPATH=${SCRIPT_DIR}
HOSTNAME=`hostname`
_LOG_LEVEL="_debug_"
_LOGFILE=${LOGPATH}/${HOSTNAME}_ocp_postinstall_report.log
os=`uname -a | awk -F' ' '{print $1}'`

#############################
# Set Openshift Envrionment
#############################
export KUBECONFIG=${SCRIPT_DIR}/install-dir/auth/kubeconfig
export PATH=${SCRIPT_DIR}/bin:$PATH

###############################
# misc functions
###############################

#---------------------------------------------------------
# Logging function (for Linux)
#---------------------------------------------------------
# crit(60) > error(50) > warn(40) > notice(30) > info(20) > debug(10)
# realted customized var: _LOG_LEVEL , _LOGFILE
# input parameters: log_level, log_message
#---------------------------------------------------------
logit(){

get_loglevel(){
 _TMP_LOG_LEVEL=$1
 case ${_TMP_LOG_LEVEL} in
        _debug_ | 10 )
                _TMP_LOG_LEVEL_NUM=10;;
        _info_ | 20 )
                _TMP_LOG_LEVEL_NUM=20;;
        _notice_ | 30 )
                _TMP_LOG_LEVEL_NUM=30;;
        _warn_ | 40)
                _TMP_LOG_LEVEL_NUM=40;;
        _error_ | 50 )
                _TMP_LOG_LEVEL_NUM=50;;
        _crit_ | 60 )
                _TMP_LOG_LEVEL_NUM=60;;
        *)
                _TMP_LOG_LEVEL_NUM=255
                echo "arguments error"
                exit 255;;
 esac
 echo ${_TMP_LOG_LEVEL_NUM}
}
_F_LOG_LEVEL=$1
_LOG_LEVEL_NUM=`get_loglevel ${_LOG_LEVEL}`
_F_LOG_LEVEL_NUM=`get_loglevel ${_F_LOG_LEVEL}`

if [ "${_LOG_LEVEL_NUM}" -le "${_F_LOG_LEVEL_NUM}" ]
then
      #echo `date +%F" "%H:%M` [${_F_LOG_LEVEL}]:"$2" |tee -a ${_LOGFILE}
      printf "%20s [%8s]: %s\n" "`date +%F' '%H:%M:%S`" "${_F_LOG_LEVEL}" "$2"  |tee -a ${_LOGFILE}
fi
}


#--------------------------------
# check complete <bootstrap/install>
#---------------------------------
#  return code:
#            0: Success
#            1: Unfinished
#--------------------------------
check-complete() {
 CHKITEM=$1
 RC=1
 logit _debug_ "--> Entering function: [check-complete ${CHKITEM}]"
 cd ${SCRIPT_DIR}/install-dir
 timeout 5 openshift-install wait-for ${CHKITEM}-complete --log-level=info >/dev/null 2>&1
 RC=$?
 if [ ${RC} -ne 0 ];then
  logit _debug_ "${CHKITEM} not completed."
 else
  logit _debug_ "${CHKITEM} completed! "
 fi
 return ${RC}
}

#--------------------------------
# check complete <bootstrap/install>
#---------------------------------
#  return code:
#            0: Processed
#            1: API not ready
#--------------------------------
check-approve-csr() {
 logit _debug_ "--> Entering function: [check-approve-csr]"
 timeout 15 oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' >/dev/null 2>&1
 if [ $? -ne 0 ];then
  logit _debug_ "openshift api server not ready to handle oc command"
  return 1
 else
  logit _debug_ "Find and auto approve pending csr..."
  oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}' | xargs oc adm certificate approve >/dev/null
  #oc get csr -o go-template='{{range .items}}{{if not .status}}{{.metadata.name}}{{"\n"}}{{end}}{{end}}'  >/dev/null
  return 0
 fi
}


########
# Main #
########
check-complete bootstrap
if [ ${RC} -ne 0 ];then
 exit 1
fi
check-complete install
if [ ${RC} -ne 0 ];then
 check-approve-csr
 exit 2
fi
exit 0
