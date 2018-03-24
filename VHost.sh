#!/bin/bash

. ./config.sh
. ./functions.sh

while getopts c:e:p:i:d:hv OPT
do
	case "${OPT}" in
		c)
                        readonly DIR_NAME="${OPTARG}"
			;;
		e)
			readonly EXTENSION_SUFFIX="${OPTARG}"
			;;
		p)
			readonly PORT_VALUE="${OPTARG}"
			;;
		i)
			readonly IP_VALUE="${OPTARG}"
			;;
		d)
			deleteFolderConf "${OPTARG}"
			exit
			;;
		h)
			usage
			exit
			;;
		v)
			version
			exit
			;;
		*)
			echo "INVALID OPTION"
			exit
			;;
	esac
done

if [ -z "${DIR_NAME}" ];then
	create_new_conf "${@}"
fi
