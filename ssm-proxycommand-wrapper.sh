#!/bin/bash
#
# creates an ssh session using AWS systems manager. Systems Manager must be
# installed.
# 
# can also be used with SSH ProxyCommand. Example SSH config:
# Host munisafe.beezwax.net
#   ProxyCommand ~/bin/ssm-proxycommand-wrapper.sh munisafe.beezwax.net beezwax-mfa us-west-1
#
# if you use this for an SSH config block, it might make sense to copy it
# outside of where this repo is installed.
#

#
# collect filter, profile and region
#
filter=$1; shift
profile=$1; shift
region=$1; shift

#
# collect ec2 instance id
#
aws_instanceid=$(aws ec2 describe-instances --region $region --profile $profile "$@" --filters "Name=tag:hostname,Values=$filter" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[InstanceId]' --output text)

#
# connect to instance id
#
aws ssm start-session --profile $profile --region $region --target $aws_instanceid --document-name AWS-StartSSHSession --parameters 'portNumber=22'
