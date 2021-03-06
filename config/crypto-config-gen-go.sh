#!/usr/bin/env bash

CURRENT="$(dirname $(readlink -f ${BASH_SOURCE}))"

crypto_config_file="$CURRENT/crypto-config.yaml"

CONFIG_JSON="$CURRENT/orgs.json"
COMPANY=$1
if [ -z "$COMPANY" ]; then
	echo "missing company param"
	exit 1
fi
remain_params=""
for ((i = 2; i <= $#; i++)); do
	j=${!i}
	remain_params="$remain_params $j"
done
while getopts "i:j:" shortname $remain_params; do
	case $shortname in
	i)
		echo "set crypto config yaml file (default: $crypto_config_file) ==> $OPTARG"
		crypto_config_file="$OPTARG"
		;;
	j)
		echo "set config json file (default: $CONFIG_JSON) ==> $OPTARG"
		CONFIG_JSON=$OPTARG
		;;
	?)
		echo "unknown argument"
		exit 1
		;;
	esac
done

orgsConfig=$(jq -r ".$COMPANY.orgs" $CONFIG_JSON)
orgNames=$(echo $orgsConfig | jq -r "keys")
COMPANY_DOMAIN=$(jq -r ".$COMPANY.domain" $CONFIG_JSON)

###################
orderer_container_name=$(jq -r ".$COMPANY.orderer.containerName" $CONFIG_JSON)




rm $crypto_config_file
>$crypto_config_file
yaml w -i $crypto_config_file OrdererOrgs[0].Name OrdererCrytoName
yaml w -i $crypto_config_file OrdererOrgs[0].Domain $COMPANY_DOMAIN
yaml w -i $crypto_config_file OrdererOrgs[0].Specs[0].Hostname ${orderer_container_name}

for ((i = 0; i < $(echo $orgsConfig| jq "length" ); i++)); do
	orgName=$(echo $orgNames| jq -r ".[$i]")
	yaml w -i $crypto_config_file PeerOrgs[$i].Name $orgName
	yaml w -i $crypto_config_file PeerOrgs[$i].Domain "$orgName.$COMPANY_DOMAIN"

	peerCount=$(echo $orgsConfig| jq ".$orgName.peers|length")
	userCount=$(echo $orgsConfig| jq ".$orgName.userCount")
	yaml w -i $crypto_config_file PeerOrgs[$i].Template.Count $peerCount
	yaml w -i $crypto_config_file PeerOrgs[$i].Template.Start 0
	yaml w -i $crypto_config_file PeerOrgs[$i].Users.Count $userCount
#	${org_domain}/users/User{index}@${org_domain}
done
