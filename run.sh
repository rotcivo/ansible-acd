#!/bin/bash
#
# wrapper for base deployment
#

#
# FUNCTIONS
#
join-by-char() {
  local IFS="$1"
  shift
  echo "$*"
}

#
# collect hostnames
#
passed_in_hosts=$1; shift
site_name=$1; shift
additional_args=("${@}")

#
# grab directory information
#
rp=`readlink -f "$0"`
rp=`dirname $rp`

#
# set playbook bits
#
play_name=$(basename $0 .sh)
playbook="$rp/$play_name.yml"
extra_vars_array=()

# 
# ignore site_name and throw it back if it's not 
#
if [ "$play_name" = 'base-deployment' ]; then
  additional_args+=("$site_name")
  unset site_name
fi

#
# set log file location
#
log_dir='/tmp'
log_file="$log_dir/$passed_in_hosts-$play_name.log"

#
# build our extra vars list
#
if [[ ! -z "$site_name" && "$site_name" != '--' ]]; then
  site_name_arr=(`echo $site_name | tr '.' ' '`)
  # only set site_prefix if this is not a third level domain
  if [ "${#site_name_arr[@]}" -gt 3 ]; then
    site_prefix="${site_name_arr[0]}"
    extra_vars_array+=( "--extra-vars site_prefix=$site_prefix" )
  fi
  extra_vars_array+=( "--extra-vars site_name=$site_name" )
fi
if [[ ! -z "$passed_in_hosts" ]]; then
  extra_vars_array+=( "--extra-vars passed_in_hosts=$passed_in_hosts" )
fi

#
# set the site prefix and the site name if we are in CodeDeploy
#
if [[ ! -z "$DEPLOYMENT_GROUP_NAME" ]]; then
    # set HOME if we're in codedeploy
    HOME='/root'
fi

extra_vars=$(join-by-char ' ' "${extra_vars_array[@]}")
if [ ${#extra_vars[@]} -ne 0 ]; then
  extra_vars_option="$extra_vars"
fi

#
# set our vault stuff
#
secrets_dir="$HOME/.secrets"
[[ -f "$secrets_dir/linode-vault-pw" ]] \
  && linode_vault="--vault-id linode_token@$secrets_dir/linode-vault-pw"
[[ -f "$secrets_dir/vmware-vault-pw" ]] \
  && vmware_vault="--vault-id vmware_pw@$secrets_dir/vmware-vault-pw"
[[ -f "$secrets_dir/zabbix-user-pw-apple" ]] \
  && zabbix_apple_vault="--vault-id zabbix_user_pw_apple@$secrets_dir/zabbix-user-pw-apple"
[[ -f "$secrets_dir/onepassword-vault-pw" ]] \
  && onepw_vault="--vault-id onepassword-vault@$secrets_dir/onepassword-vault-pw"
[[ -f "$secrets_dir/zabbix-user-api" ]] \
  && zabbix_api_vault="--vault-id zabbix_user_api@$secrets_dir/zabbix-user-api"

#
# let em know where we are running things
#
echo "logging playbook output to $log_file..."

#
# onepassword wants this export all the time?
#
export OP_DEVICE=63xtdvi4glvga6pxyxn5fcxugi

#
# run the playbook
#
ansible-playbook "${additional_args[@]}" $playbook \
  $onepw_vault $linode_vault $vmware_vault $zabbix_apple_vault $zabbix_api_vault \
  $extra_vars \
  |& tee $log_file
