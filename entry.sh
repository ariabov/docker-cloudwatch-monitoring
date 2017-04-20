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

ARGS=()

# Checks if ARGS already contains the given value
has_arg() {
  local element
  for element in "${@:2}"; do
    [ "${element}" == "${1}" ] && return 0
  done
  return 1
}
# Adds the given argument if not specified
add_arg() {
  local arg="${1}"
  [ $# -ge 1 ] && local val="${2}"
  if ! has_arg "${arg}" "${ARGS[@]}"; then
    ARGS+=("${arg}")
    [ $# -ge 1 ] && ARGS+=("${val}")
  fi
}
# Adds the given argument duplicates ok.
add_arg_simple() {
  local arg="${1}"
  [ $# -ge 1 ] && local val="${2}"
  ARGS+=("${arg}")
  [ $# -ge 1 ] && ARGS+=("${val}")
}

while getopts ':msd:' opt; do
  case "$opt" in
    m)
      add_arg "--mem-util"
      add_arg "--mem-used"
      add_arg "--mem-avail"
      ;;
    d)
      add_arg "--disk-space-util"
      add_arg "--disk-space-avail"
      add_arg "--disk-space-used"
      add_arg_simple "--disk-path=${OPTARG}"
      ;;
    s)
      add_arg "--swap-util"
      add_arg "--swap-used"
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
CRON_OUTPUT_BASE=(${CRON_OUTPUT_BASE[@]} ${ARGS[@]})
## Check for Cron arg
if [ "$CWM_CRON_TIME" ];then
  echo "${CWM_CRON_TIME}" "${CRON_OUTPUT_BASE[@]}" >> /etc/crontab
else
  echo "* * * * *" "${CRON_OUTPUT_BASE[@]}" >> /etc/crontab
fi

crontab /etc/crontab
crond -f
