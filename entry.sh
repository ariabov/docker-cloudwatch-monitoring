#!/bin/bash

_CRED_OPT=''
# By default script gets creds automatically, but you can specify IAM role or creds
if [ -f "/awscreds" ] && [ "`cat "/awscreds" | grep 'AWSAccessKeyId'`" ] && [ "`cat "/awscreds" | grep 'AWSSecretKey'`" ]; then
  _CRED_OPT="--aws-credential-file=/awscreds"
  echo "Found credentials file, skipping load"
elif [ "${AWS_ACCESS_KEY_ID}" ] && [ "${AWS_SECRET_ACCESS_KEY}" ]; then
  _CRED_OPT="--aws-access-key-id=${AWS_ACCESS_KEY_ID} --aws-secret-key=${AWS_SECRET_ACCESS_KEY}" >> /etc/crontab
  echo "Found and substituted credentials from ENV"
elif [ "${AWS_IAM_ROLE}" ]; then
  _CRED_OPT="--aws-iam-role=${AWS_IAM_ROLE}" >> /etc/crontab
  echo "Fonnd IAM role"
fi

echo -n '' > /etc/crontab
while getopts ':msd:' opt; do
  case "$opt" in
    m)
      echo "* * * * * /aws-scripts-mon/mon-put-instance-data.pl --auto-scaling ${_CRED_OPT} --mem-util --mem-used --mem-avail" >> /etc/crontab
    ;;
    d)
      echo "* * * * * /aws-scripts-mon/mon-put-instance-data.pl --auto-scaling ${_CRED_OPT} --disk-path=${OPTARG} --disk-space-util --disk-space-avail --disk-space-used" >> /etc/crontab
    ;;
    s)
      echo "* * * * * /aws-scripts-mon/mon-put-instance-data.pl --auto-scaling ${_CRED_OPT} --swap-util --swap-used" >> /etc/crontab
    ;;
    :)
      echo "Need parameter for -${OPTARG}"
    ;;
    ?)
      echo "Unsupported option -${OPTARG}"
    ;;
  esac
done

crontab /etc/crontab
crond -f
