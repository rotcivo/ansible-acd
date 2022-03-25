#!/bin/bash
#
# Set up SSH transport for SSM into beezwax machines
#

usage() {
  echo "$0: tag:hostname|private-ip [aws-ssm-options]"
}

#
# collect filter and argument parsing --
#
filter=$1; shift
regions=("us-west-1" "us-west-2")

#
# need something to filter
#
if [ -z "$filter" ]; then
  usage
  exit 1
fi


#
# loop through our known regions to find any instances
#
for region in ${regions[@]}; do
  if [[ "$filter" =~ (10|172)\.[0-9\.]+ ]]; then
    iid=$(aws ec2 describe-instances --region $region "$@" --filters "Name=private-ip-address,Values=$filter" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[InstanceId]' --output text)
    if [ ! -z "$iid" ]; then
      region_loc=$region
      break
    fi
  else
    iid=$(aws ec2 describe-instances --region $region "$@" --filters "Name=tag:hostname,Values=$filter" "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].[InstanceId]' --output text)
    if [ ! -z "$iid" ]; then
      region_loc=$region
      break
    fi
  fi
done

#
# if we can't find anything, notify
#
if [ -z "$iid" ]; then
  echo "unable to find $filter in any of the following regions:"
  printf "'%s'\n" "${regions[@]}"
  exit 1
fi

#
# start up ssm connection
#
aws ssm start-session "$@" \
    --target $iid \
    --region $region_loc \
