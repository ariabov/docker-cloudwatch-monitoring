#!/bin/bash

_CRED_OPT=''
# By default script gets creds automatically, but you can specify IAM role or creds
if [ -f "/awscreds" ] && [ "$(grep 'AWSAccessKeyId' /awscreds)" ]  && [ "$(grep 'AWSSecretKey' /awscreds)" ]; then
  _CRED_OPT="--aws-credential-file=/awscreds"
  echo "Found credentials file, skipping load"
elif [ "${AWS_ACCESS_KEY_ID}" ] && [ "${AWS_SECRET_ACCESS_KEY}" ]; then
  _CRED_OPT="--aws-access-key-id=${AWS_ACCESS_KEY_ID} --aws-secret-key=${AWS_SECRET_ACCESS_KEY}"
  echo "Found and substituted credentials from ENV"
elif [ "${AWS_IAM_ROLE}" ]; then
  _CRED_OPT="--aws-iam-role=${AWS_IAM_ROLE}"
  echo "Fonnd IAM role"
fi

echo -n '' > /etc/crontab

CRON_OUTPUT_BASE[0]="/aws-scripts-mon/mon-put-instance-data.pl --auto-scaling"

if [ "$_CRED_OPT" ]; then
  CRON_OUTPUT_BASE+=("${_CRED_OPT}")
fi

while getopts ':msd:' opt; do
  case "$opt" in
    m)
      ARGS=()
      ARGS+=("--mem-util")
      ARGS+=("--mem-used")
      ARGS+=("--mem-avail")
      if [ ! "$CWM_CRON_DEBUG" ];then
        ARGS+=(">")
        ARGS+=("/dev/null")
      fi
      MEM_OUTPUT=(${CRON_OUTPUT_BASE[@]} ${ARGS[@]})
      ## Check for Cron arg
      if [ "$CWM_CRON_TIME" ];then
        echo "${CWM_CRON_TIME}" "${MEM_OUTPUT[@]}" >> /etc/crontab
      else
        echo "* * * * *" "${MEM_OUTPUT[@]}" >> /etc/crontab
      fi
      ;;
    d)
      ARGS=()
      ARGS+=("--disk-space-util")
      ARGS+=("--disk-space-avail")
      ARGS+=("--disk-space-used")
      ARGS+=("--disk-path=${OPTARG}")
      if [ ! "$CWM_CRON_DEBUG" ];then
        ARGS+=(">")
        ARGS+=("/dev/null")
      fi
      DISK_OUTPUT=(${CRON_OUTPUT_BASE[@]} ${ARGS[@]})
      if [ "$CWM_CRON_TIME" ];then
        echo "${CWM_CRON_TIME}" "${DISK_OUTPUT[@]}" >> /etc/crontab
      else
        echo "* * * * *" "${DISK_OUTPUT[@]}" >> /etc/crontab
      fi
      ;;
    s)
      ARGS=()
      ARGS+=("--swap-util")
      ARGS+=("--swap-used")
      if [ ! "$CWM_CRON_DEBUG" ];then
        ARGS+=(">")
        ARGS+=("/dev/null")
      fi
      SWAP_OUTPUT=(${CRON_OUTPUT_BASE[@]} ${ARGS[@]})
      if [ "$CWM_CRON_TIME" ];then
        echo "${CWM_CRON_TIME}" "${SWAP_OUTPUT[@]}" >> /etc/crontab
      else
        echo "* * * * *" "${SWAP_OUTPUT[@]}" >> /etc/crontab
      fi
      ;;
    \?)
      set +x
      echo "Need parameter for -${OPTARG}"
      ;;
    :)
      set +x
      echo "Unsupported option -${OPTARG}"
      ;;
  esac
done

# Get rid of processed options from Array
shift "$((OPTIND-1))"
# store remaining arguments for future use possibly
#USER_ARGS=("${@}")

crontab /etc/crontab
crond -f
