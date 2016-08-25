#!/bin/bash

echo -n "* * * * * /aws-scripts-mon/mon-put-instance-data.pl --from-cron --mem-util --mem-used --mem-avail --disk-path=/etc/hosts --disk-space-util --disk-space-avail --disk-space-used --auto-scaling" > /etc/crontab

# By default script gets creds automatically, but you can specify IAM role or creds
if [ -f "/awscreds" ] && [ "`cat "/awscreds" | grep 'AWSAccessKeyId'`" ] && [ "`cat "/awscreds" | grep 'AWSSecretKey'`" ]; then
  echo " --aws-credential-file=/awscreds" >> /etc/crontab
  echo "Found credentials file, skipping load"
elif [ "${AWS_ACCESS_KEY_ID}" ] && [ "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo " --aws-access-key-id=${AWS_ACCESS_KEY_ID} --aws-secret-key=${AWS_SECRET_ACCESS_KEY}" >> /etc/crontab
  echo "Found and substituted credentials from ENV"
elif [ "${AWS_IAM_ROLE}" ]; then
  echo " --aws-iam-role=${AWS_IAM_ROLE}" >> /etc/crontab
  echo "Fonnd IAM role"
fi

crontab /etc/crontab

# Run cron
crond -f
