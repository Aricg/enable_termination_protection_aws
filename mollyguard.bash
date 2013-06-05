#!/bin/bash
#########################
# How to use
# Naviage to the aws/securityCredentials page and generate a x.509 certificate
# take both the public and the private certificate file and place them in $keys (default is /etc/ssl/private/aws/)
# rename the public and private certificate foo.pub and foo.key respectivly
# you may provide this script with any number of certificate pairs
#
# What it does
# This script will enable termination protection on all of your machines. 
# Bascially it covers your ass.
#
# Aric Gardner 2013
#
# Copyleft Information
# Usage of the works is permitted provided that this instrument is retained with the works, so that any entity that uses the works is notified of this instrument.
# DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.
##########################

keys="/etc/ssl/private/aws/*"
version="1.0"

#Usage
usage () {
if [ "$1" = "-h" ] || [ "$1" = "-help" ] || [ "$1" = "--help" ] || [ "$1" = "" ] ;
then
cat << EOF

usage $0: [OPTIONS]
  -h      Show this message
  -x	Enable termination protection on all instances

$0 version "$version"

EOF
exit 0

fi

}

get_clients()
{
for x in $(find $keys -type f | grep ".key");
do
describe_instances "$@"
done
}

describe_instances() {

#Get a list of avaliable avaliablility zones
if [[ ! -e tmp_zones ]]; then
ec2-describe-regions -C ${x%.*}.pub -K ${x%.*}.key | awk '{ print $2 }' > tmp_zones
fi


for zone in $(cat tmp_zones)
	do

		key="--region "$zone" -C ${x%.*}.pub -K ${x%.*}.key"

	echo "Looking for "$(basename ${x%.*})"'s instances in $zone avaliablity zone"

	getinstance "$@"
	protectinstance "$@"
	done

}

getinstance() {
                getinstance=()
                 while read -d $'\n'; do
                        getinstance+=("$REPLY")
                 done < <(ec2-describe-instances $key | grep "INSTANCE"  | awk '{print $2 }')
}


protectinstance () {
	for instance in "${getinstance[@]}";
	do
		echo "ec2-modify-instance-attribute $key "$instance" --disable-api-termination true"
	done
}


usage "$@"
get_clients "$@"
