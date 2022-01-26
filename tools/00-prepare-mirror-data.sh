#!/bin/bash
#-------------------------------------------------------------
# Script Name   : 00-prepare-mirror-data.sh (version 1.0)
# Dependencies  : - Make sure you have internet access
#                 - You have a stored secret file include your pull secret for both redhat and local registry
# Outputs       : Step by Step logging info will pop to STDOUT
# Err Outputs   :
# Created by    : lixin@IBM
#         on    : 20210811
# Updated by    :
#         on    :
# Parameters    : { -v <openshift version> [-o <ova version>] }
# Return Code   : 0 = Sucess
#               : 1 =
#               : 2 =
#               : 3 =
#               : 4 =
#-------------------------------------------------------------
#set -x

# log & trace config
SCRIPT_DIR=$(cd $(dirname $0); pwd)
LOGPATH=${SCRIPT_DIR}/logs; [ -d ${LOGPATH} ] || mkdir -p ${LOGPATH}
_LOG_LEVEL="_debug_"
_LOGFILE=${LOGPATH}/prepare-mirror-data_"`date +%F_%H%M%S`".log


#---------------------------------------------------------
# Usage function
#---------------------------------------------------------
usage()
{
 echo " "
 echo "Usage:"
 echo "----------------------------------------------------------------------------------------------"
 echo "`basename $0` { -v <openshift version> [ -o ] [ -d <directory> ] }                            "
 echo "                                                                                              "
 echo "      -v Openshift-Version                                                                    "
 echo "           Select which openshift version you are going to install, this tool will help you   "
 echo "           create the image mirror data and relevant openshift client into local directory.   "
 echo "                                                                                              "
 echo "      -o                                                                                      "
 echo "           Optional, When specified, the script will download the redhat coreos ova template  "
 echo "           file into the target directory. default version will be the highest version that   "
 echo "           is less than or equal to the selected openshift release version.                   "
 echo "           (This is only required for openshift 4.6+)                                         "
 echo "                                                                                              "
 echo "      -d Directory                                                                            "
 echo "           Optional, decided where you want to store the mirror data file.                    "
 echo "           Default location is <script_dir>/ocp<Openshift-Version>                            "
 echo "                                                                                              "
 echo " Examples                                                                                     "
 echo " 1  Prepare the image mirror data for openshift release v4.6.31, download coreos v4.6.8 ova   "
 echo "    file, file will be store in the directory /mirror-data/ocp4.6.31) :                       "
 echo "      `basename $0` -v 4.6.31 -o -d /mirror-data                                              "
 echo " 2  Prepare the image mirror data for openshift release v4.6.42, download coreos v4.6.40 ova  "
 echo "    file, file will be store in the default location (<script_dir>/ocp4.6.42) :               "
 echo "      `basename $0` -v 4.6.42 -o                                                              "
 echo " 3  Create mirror data for openshift release v4.6.16, download the latest 4.6 coreos, and     "
 echo "    store them into /data/mirror-data :                                                       "
 echo "      `basename $0` -v 4.6.16 -d /data/mirror-data                                            "
 echo "                                                                                              "
 echo "----------------------------------------------------------------------------------------------"
 exit 65
}



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


#---------------------------------------------------------
# Parse Arguments function
#---------------------------------------------------------

parsearg()
{
 V_FLAG=0;OCP_RELEASE=""
 O_FLAG=0;OVA_RELEASE=""
 D_FLAG=0;TARGETDIR=""

 while getopts ":v:a:od:" Option
 do
 case $Option in
 v) V_FLAG=1;OCP_RELEASE=$OPTARG;MAJOR_VERSION=`echo ${OCP_RELEASE}|cut -f 1-2 -d .`;;
 a) A_FLAG=1;PULLSECRET=$OPTARG;;
 o) O_FLAG=1;;
 d) D_FLAG=1;TARGETDIR=$OPTARG;;
 ?) usage ;;
 esac
 done
 shift $(($OPTIND - 1))
 [ $# -gt 0 ] && usage

if [ ${V_FLAG} -eq 0 ];then
  echo " "
  echo "--------------------------------------------------------------------"
  echo "Please specify the openshift release version after -v arg !"
  echo "--------------------------------------------------------------------"
  echo " "
  usage
fi

if [[ ${A_FLAG} -eq 0 ]] && [[ 0"${PULLSECRET}" == "0" ]];then
  echo " "
  echo "--------------------------------------------------------------------"
  echo "Please specify the redhat pull secret file location with -a arg !"
  echo " or "
  echo "export PULLSECRET=<YOUR SECRET LOCATION> before you run the script."
  echo "--------------------------------------------------------------------"
  exit 65
  #usage
fi

[ "${TARGETDIR}" == "" ] && TARGETDIR=${SCRIPT_DIR}/ocp${OCP_RELEASE}

# log args report
logit _debug_ "Selected Openshift Release Version       :      ${OCP_RELEASE}"
logit _debug_ "Pull Secret location                     :      ${PULLSECRET}"
if [ ${O_FLAG} -eq 1 ];then
  logit _debug_ "Selected RHCOS template download         :      YES"
else
  logit _debug_ "Selected RHCOS template download         :      NO"
fi

if [ ${D_FLAG} -eq 1 ];then
  logit _debug_ "Specified mirror data location           :      ${TARGETDIR}"
else
  logit _debug_ "Use default mirror data location         :      ${TARGETDIR}"
fi
return 0
}

#---------------------------------------------------------
# Download oc client for selected release
#---------------------------------------------------------
download-occlient()
{
  [ ! -d "${TARGETDIR}" ] && mkdir -p ${TARGETDIR}
  CMD="curl -kLo ${TARGETDIR}/oc_client.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_RELEASE}/openshift-client-linux.tar.gz"
  logit _debug_ "Starting download the openshift client for release ${OCP_RELEASE}:"
  logit _debug_ "[${CMD}]"
  eval ${CMD}

  CMD="curl -kLo ${TARGETDIR}/openshift_install.tar.gz https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_RELEASE}/openshift-install-linux.tar.gz"
  logit _debug_ "Starting download the openshift install binary for release ${OCP_RELEASE}:"
  logit _debug_ "[${CMD}]"
  eval ${CMD}

}



#---------------------------------------------------------
# mirror openshift release function
#---------------------------------------------------------
mirror-release()
{
  if [ ! -f "${TARGETDIR}/oc_client.tar.gz" ];then
    logit _warn_ "Openshift Client package not found, Please check if download successfully."
    #exit 2
  else
    logit _debug_ "Found Openshift Client package."
  fi
  logit _debug_ "Extracting oc command..."
  tar xvf ${TARGETDIR}/oc_client.tar.gz -C ${SCRIPT_DIR}
  PRODUCT_REPO='openshift-release-dev'
  RELEASE_NAME="ocp-release"
  ARCHITECTURE='x86_64'
  CMD="${SCRIPT_DIR}/oc adm release mirror -a ${PULLSECRET} --to-dir=${TARGETDIR}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}"
  logit _debug_ "Starting mirror the openshift release image:"
  logit _debug_ "[${CMD}]"
  eval ${CMD}
}

findrhcosversion()
{
  logit _notice_ "Searching availabile rhcos version ..."
  OVA_RELEASE=""
  for line in `curl --silent https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${MAJOR_VERSION}/ | grep -o 'href=".*">' |grep -v "dependencies/rhcos"|grep -v Description| sed 's/href="//'  |cut -f 1 -d '/'|grep ${MAJOR_VERSION} | sort -rV`
  do
    if [ "$(printf '%s\n' "${line}" "${OCP_RELEASE}" | sort -V | head -n1)" = "${line}" ]; then
       # echo "Greater than or equal to ${line}"
      logit _debug_ "Found RHCOS template Version             :      ${line}"
      OVA_RELEASE=${line}
      break
    fi
  done

}

download-ova()
{
  if [ ${O_FLAG} -eq 0 ];then
    logit _notice_ "Running without -o option, Ignore rhcos template download."
    return 0
  fi
  if [ "${OVA_RELEASE}" == "" ];then
    logit _warn_ "Not able to find a suitable rhcos version for openshift release ${OCP_RELEASE}"
    logit _warn_ "Exit ova download."
    return 2
  fi
  OVA_DOWNLOAD_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/${MAJOR_VERSION}/${OVA_RELEASE}/rhcos-vmware.x86_64.ova"
  logit _debug_ "OVA download url:       ${OVA_DOWNLOAD_URL}"
  mkdir -p ${TARGETDIR}
  CMD="curl -kLo ${TARGETDIR}/rhcos-vmware.ova ${OVA_DOWNLOAD_URL}"
  logit _debug_ "Start download the rhcos ${OVA_RELEASE} ova template:"
  logit _debug_ "[$CMD]"
  eval ${CMD}
  return 0
}

package-report()
{
  logit _debug_ "Packaging mirror data..."
  CMD="cd ${TARGETDIR} && tar cvf image_mirror_ocp_release_${OCP_RELEASE}.tar ./mirror rhcos-vmware.ova oc_client.tar.gz openshift_install.tar.gz"
  eval ${CMD}
  logit _notice_ "`cat <<EOF

                                  Preparation for Openshift v${OCP_RELEASE} Completed.
                                  Release mirror data stored in : ${TARGETDIR}/mirror
                                  Openshift Client Package      : ${TARGETDIR}/oc_client.tar.gz
                                  Openshift Install Binary      : ${TARGETDIR}/openshift_install.tar.gz
                                  RHCOS ova template            : ${TARGETDIR}/rhcos-vmware.ova

                                  All required data stored in   : ${TARGETDIR}/image_mirror_ocp_release_${OCP_RELEASE}.tar

EOF`"
}

###############################
# Main Function
###############################

parsearg $@
download-occlient
mirror-release
findrhcosversion
download-ova
package-report
