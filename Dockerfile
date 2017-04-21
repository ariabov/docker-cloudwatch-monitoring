FROM alpine:3.5

ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_IAM_ROLE=""

RUN apk add --update \
  coreutils \
  wget \
  unzip \
  bash \
  ca-certificates \
  perl-datetime perl-libwww perl-lwp-protocol-https
RUN rm -rf /var/cache/apk/*
RUN update-ca-certificates

RUN wget http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip && \
  unzip CloudWatchMonitoringScripts-1.2.1.zip && \
  rm CloudWatchMonitoringScripts-1.2.1.zip && \
  /bin/sed -i 's#/proc/meminfo#/host/proc/meminfo#g' /aws-scripts-mon/mon-put-instance-data.pl

WORKDIR aws-scripts-mon

ADD ./entry.sh /entry.sh
RUN chmod +x /entry.sh
ENTRYPOINT ["/entry.sh"]
CMD ["-m", "-d", "/etc/hosts"]
