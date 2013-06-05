#!/bin/bash
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
