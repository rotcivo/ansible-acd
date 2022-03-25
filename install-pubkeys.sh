#!/bin/bash
#
# clone beezwax public keys
#

#
# grab directory information
#
rp=`readlink -f "$0"`
rp=`dirname $rp`

pub_key_repo='git@github.com:beezwax/bz.pubkeys.git'
pub_key_dir="$rp/pubkeys"

#
# delete pubkeys if it exists already
#
[ -d "$pub_key_dir" ] && rm -rf $pub_key_dir

# 
# clone pub keys
# 
git clone $pub_key_repo $pub_key_dir
