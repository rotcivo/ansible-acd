#!/bin/bash
#
# simple wrapper for installing roles and collections
#

#
# get working dir
#
rp=`readlink -f "$0"`
rp=`dirname $rp`

#
# file bits
#
roles_path="$rp/roles"
role_file="$roles_path/requirements.yml"
collections_path="$rp/collections"
collections_file="$collections_path/requirements.yml"

#
# install 'em
#
ansible-galaxy role install \
  --role-file $role_file \
  --roles-path $roles_path \
  --force
ansible-galaxy collection install \
  -p $collections_path \
  -r $collections_file
