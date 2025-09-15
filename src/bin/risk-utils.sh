#!/bin/sh

script=$(readlink -f "$0")
scriptPath=$(dirname "$script")
. $scriptPath/../lib/functions.sh

function print_help() {

	echo
    echo "To use $(basename $0): "
    echo
    echo "  ${bold}$(basename $0) <command> portal|<product> ${reset}"
    echo
    echo "${bold}<command>${reset}'s:"
    echo
    echo "      ${bold}list${reset}: lists available deployments (main server and satellites) for portal or <product> based on the respective yaml settings files."
	echo	
}

command="$1"
product="$2"
riskManagementPackagesDir="${scriptPath}/../packages"

commandList="list"
findCommand=$(echo "${command}" | grep -qE "^(${commandList})$"; echo $?)

if [ -z "${command}" ]
then
    print_help
    echo; echo "${red}ERROR:${reset} Please provide a command."; echo
    exit 1
elif [ -z "${product}" ]
then
    print_help
    echo; echo "${red}ERROR:${reset} ${bold}portal${reset} or ${bold}<product>${reset} is missing."; echo
    exit 1
elif [[ ! "${product}" =~ ^t[0-9]{2}|portal$ ]]
then
    print_help
    echo; echo "${red}ERROR:${reset} Product ${bold}${product}${reset} is not valid."; echo
    exit 1
elif [ "${findCommand}" -eq 1 ]
then
    print_help
    echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid."; echo
    exit 1
fi

shift 2
while [[ $# -gt 0 ]]
do
	leftOverParams="$leftOverParams $1"
	shift
done

if [ ! -z "$leftOverParams" ]
then
    echo; echo "${red}ERROR:${reset} Found invalid parameters: '${leftOverParams}'"; echo
    exit 1
fi


case "${command}" in
	"list")
		if  [ ! -d "${riskManagementPackagesDir}/${product}" ]
		then
			echo; echo "${red}ERROR:${reset} Product directory '${riskManagementPackagesDir}/${product}' not found."; echo
			exit 1
		else
			list_available_deployments "${riskManagementPackagesDir}" "${product}"
		fi
		;;
esac

exit 0