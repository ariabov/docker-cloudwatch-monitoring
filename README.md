# Docker Cloudwatch Monitoring

This Docker container contains Amazon EC2 scripts to simplify reporting additional EC2 instance information to Cloudwatch. These Perl scripts comprise a fully functional examples that reports memory, swap, and disk space utilization metrics for a Linux instance. You can learn more about the scripts [here](http://docs.aws.amazon.com/AmazonCloudWatch/latest/DeveloperGuide/mon-scripts.html).

## Running it

Build and run it in `--privileged` mode. If you have correct IAM role associated with the instance, it will start working immediately.

See [Configuration](#Configuration) section for the ways to specify credentials.

## Configuration

You can specify credentials in the following ways:

### IAM role

IAM role is automatically taken from instance's metadata. Role may be also put into `AWS_IAM_ROLE` variable.

Instance's IAM role should have the following permissions:

- `cloudwatch:PutMetricData`
- `cloudwatch:GetMetricStatistics`
- `cloudwatch:ListMetrics`
- `ec2:DescribeTags`

### Credentials file

Create credentials file with the following content:

```
AWSAccessKeyId=YourAccessKeyID
AWSSecretKey=YourSecretAccessKey
```

Add it to the container to path `/awscreds`: `docker run -v ./aws_creds_file.txt:/awscreds`

### Environment

Use the following env. variables for credentials:

1. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
2. `AWS_IAM_ROLE` - IAM role name, used only if `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` not specified/empty.
