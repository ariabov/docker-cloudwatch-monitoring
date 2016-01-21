# Docker Cloudwatch Monitoring

This Docker container contains Amazon EC2 scripts to simplify reporting additional EC2 instance information to Cloudwatch. These Perl scripts comprise a fully functional examples that reports memory, swap, and disk space utilization metrics for a Linux instance. You can learn more about the scripts [here](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/mon-scripts.html).

## Getting started

1. Create `awscreds.template` with your IAM credentials. You can jumpstart the process by copying and modifying the example file with `cp awscreds.template.example awscreds.template`. For more information regarding creating new IAM role or modifying existing IAM role for your EC2 instance go [here](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/mon-scripts.html#mon-scripts-getstarted).

2. Create `crontab` to specify what metrics and when you would like reported to CloudWatch. Again, you can speed up development with copying and modifying the example file with `cp crontab.example crontab`. The example cron task reports instance memory and disk usage to CloudWatch every minute. To find the list of all options and what they mean, refer to the official documentation [here](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/mon-scripts.html#mon-scripts-using). While modifying the options per your requirements, make sure to keep the following in mind:

Unless you move the AWS credential file, the following path should remain the same

```
--aws-credential-file=/aws-scripts-mon/awscreds.template
```

Correct `disk-path` is required to successfully report disk usage. For simpler configuration, `/etc/hosts` should suffice but feel free to double check if you see any issues.

## Debugging

If you are encountering any issues with reporting EC2 metrics in production, you may try the included debugging `crontab` file. Copy and modify the debugging example file with `cp crontab.example-debugging crontab`. The two key differences is that the output of cron job is verbose and written to `/var/log/cron.log` file.
