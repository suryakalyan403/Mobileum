#################################################################################
### Template script to install a RAID Module, Portal or RAID Satellite on top of AIP cluster
### Risk Management: 2022-02-05 Initial Version
#################################################################################

script=$(readlink -f "$0")
scriptPath=$(dirname "$script")
. $scriptPath/../lib/functions.sh

function print_help() {
    echo "To use $(basename $0): "
    echo
    echo "  ${bold}$(basename $0) <command> portal|<product> [<option>] [<satellite-id>] [--packages-dir <risk-management-packages-dir>] [--common-settings <filename>] [--product-settings <filename>] [--portal-settings <filename>] [--presentation-settings <filename>]${reset}"
    echo
    echo "${bold}<command>${reset}'s:"
    echo
    echo "      ${bold}install${reset}: Creates namespace and secrets (license and product config) and runs the helm install the portal or <product>."
    echo
    echo "      ${bold}install-all${reset}: Same as install but before install, drops namespaces (portal|<product> and database if different), creates namespaces again and creates the database and partition."
    echo
    echo "      ${bold}deploy-to-portal${reset}: Deploy <product> installation package in portal."
    echo
    echo "      ${bold}create-pg-db${reset}: PostgreSQL database deployment in cluster for provided portal|<product>."
    echo
    echo "      ${bold}create-pg-part${reset}: create partition in PostgreSQL Database for provided portal|<product>."
    echo
    echo "      ${bold}create-svc-np${reset}: create k8s service of type NodePort for portal|<product> or database if ${bold}database${reset} provided."
    echo
    echo "      ${bold}create-svc-lb${reset}: create k8s service of type LoadBalancer for portal|<product> or database if ${bold}database${reset} provided."
    echo
    echo "      ${bold}create-port-forward${reset}: Start a k8s PortForward to acccess the portal|<product> or database if ${bold}database${reset} provided."
    echo
    echo "      ${bold}deploy-package${reset}: Deploy a package in portal|<product>. This could be used to deploy custom configurations over an installed product. Not valid for packages affecting the pod filesystem objects. 'portal|<product>/upgrade' in cloud storage is deleted and replaced by the contents of packages/portal/portal_upgrade or packages/<product>/rafm_upgrade directory. Then the helm upgrade with option --reuse-values is executed deploying whatever was copied to cloud storage."
    echo
    echo "      ${bold}upgrade${reset}: Upgrades the portal|<product> pod. This should be useed to apply new AIP portal|<product> images, AIP image patches or change yaml deployment settings. It might be required run ${bold}restart${reset} after ${bold}upgrade${reset} is sucsessful. 'portal|<product>/upgrade' in cloud storage is deleted and replaced by the contents of packages/portal/portal_upgrade or packages/<product>/rafm_upgrade directory. Then the helm upgrade is executed deploying whatever was copied to cloud storage."
    echo
    echo "      ${bold}patch${reset}: Apply rafm platform or portal|<product> patches. If no option is provided patches will be deployed from portal|<portal>/patch directory. If option ${bold}startup${reset} is provided, then patches from rafm_startup or portal_startup are copied to cloud storage to be applied. If a patch is to applied during upgrade, then please use the ${bold}upgrade${reset} command."
    echo
    echo "      ${bold}scale-down${reset}: Execute a scale-down for the portal|<product>."
    echo
    echo "      ${bold}scale-up${reset}: Execute a scale-up for the portal|<product>."
    echo
    echo "      ${bold}restart${reset}: Execute a scale-down and scale-up for the portal|<product>."
    echo
    echo "      ${bold}update-secret${reset}: Update k8s secret for portal or <product>. Requires option ${bold}product-config${reset} or ${bold}license${reset} or ${bold}gcpAccount${reset}  to select which secret is to be updated."
    echo
    echo "      ${bold}drop${reset}: Drop the portal|<product> deployment but not the database. If ${bold}database${reset} option is provided, database will also be droped."
    echo
    echo "      ${bold}drop-ns${reset}: Drop the portal|<product> namespace."
    echo
    echo "${bold}<option>${reset}'s:"
    echo
    echo "      ${bold}satellite${reset} to manage <product> satellite pods. Requires the <satellite-id> argument to be set (e.g., sat1, sat2...). Can be used with the following commands:"
    echo "           ${bold}install${reset}: Install satellite of ${bold}<product>${reset}"
    echo "           ${bold}upgrade${reset}: Upgrade satellite pod."
    echo "           ${bold}drop${reset}: Drop satellite."
    echo "           ${bold}create-svc-np${reset}: Create k8s service of type NodePort targeting the portal|<product> ServerPort"
    echo "           ${bold}create-svc-lb${reset}: Create k8s service of type LoadBalancer targeting the portal|<product> ServerPort"
	echo "           ${bold}update-secret${reset}: Updates k8s for a satellite of ${bold}<product>${reset}"
    echo
    echo "      ${bold}database${reset} If set command will target the portal|<product> database. This cannot be used together with option ${bold}satellite${reset}. Can be used with the following commands:"
    echo "           ${bold}create-svc-np${reset}: Create NodePort service targeting the databse port if database is running in the cluster"
    echo "           ${bold}create-svc-lb${reset}: Create LoadBalancer service targeting the database port if database is running in the cluster"
    echo "           ${bold}create-port-forward${reset}: Create k8s PortForward targeting the database port if database is running in the cluster"
    echo "           ${bold}drop${reset}: When droping the portal or <product>, database will also be droped if set to be created in yaml settings."
    echo
    echo "      ${bold}product-config${reset} Use with ${bold}update-secret${reset} to update the product config file in the corresponding k8s secret."
    echo
    echo "      ${bold}license${reset} Use with ${bold}update-secret${reset} to update the license file in the corresponding k8s secret."
    echo
    echo "      ${bold}startup${reset} Use with ${bold}patch${reset} command to apply patches that required in startup deployment mode."
    echo
    echo "      ${bold}dry-run${reset} No action will take place and only the commands will be shown."
    echo
    echo "To override the default settings packages directory or settings files, use:"
    echo
    echo "      ${bold}--packages-dir <risk-mangement-packages-dir>${reset}"
    echo "          Default dir: ${scriptPath}/../packages."
    echo
    echo "      ${bold}--common-settings <file>${reset}"
    echo "          Default file: ${riskManagementPackagesDir}/common/aip_settings/common-settings.yaml"
    echo
    echo "      ${bold}--product-settings <file>${reset}"
    echo "          Default file: ${riskManagementPackagesDir}/<product>/aip_settings/<product>-settings.yaml"
    echo
    echo "      ${bold}--presentation-settings <file>${reset}"
    echo "   		Only used in rafm products instalations"
    echo "          Default file: ${riskManagementPackagesDir}/<product>/aip_settings/presentation/<product>-presentation-override-settings.yaml"
	echo
    echo "      ${bold}--portal-settings <file>${reset}"
    echo "          Default file: ${riskManagementPackagesDir}/portal/aip_settings/portal-settings.yaml"
    echo
    echo "  Settings files will be loaded in the following order: common, portal|product, satellite."
    echo
    echo "  If the same setting is available in two files the last value will prevail. E.g:"
    echo "      - Settings in product-settings.yaml will override the same if existing in common-settings.yaml."
    echo "      - A setting common to all deployments may be set in <common-settings.yaml>. There is no need to repeat it in the product or satellite settings files."
    echo
}

command="$1"
product="$2"

satelliteSettingsFile="" # mandatory as argument if using
riskManagementPackagesDir="${scriptPath}/../packages"
database="false"

commandList="install|install-all|deploy-to-portal|upgrade|patch|drop|drop-with-db|create-pg-db|create-pg-part|create-svc-np|create-svc-lb|create-ns|scale-down|scale-up|restart|create-port-forward|drop-ns|update-secret|deploy-package"
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
elif [ "${findCommand}" -eq 1 ]
then
    print_help
    echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid."; echo
    exit 1
fi


if [ "${product}" == "portal"  ]
then
    type="portal"
elif [[ "${product}" =~ ^t[0-9]{2} ]]
then
    type="rafm"
else
	type="util"
fi

databaseOption="false"
licenseOption="false"
productConfigOption="false"


installPresentation="false"
portalWithHighAvailability="false"

shift 2
while [[ $# -gt 0 ]]; do
    case ${1,} in
        "satellite")
            if [ "${type}" == "rafm" ]
            then
				if [ $# -eq 1 ] || [ "${2:0:2}" == "--" ] || [[ ! "${2}" =~ ^sat[0-9]+|presentation$ ]]
				then
					echo; echo "${red}ERROR:${reset} Satellite identifier missing or incorrect after '$1' option. Satellite identifier examples: sat1, sat2..."; echo
					exit 1
				else
					type="rafm-satellite"
					satelliteId="$2"
					shift 2
				fi
            else
                echo; echo "${red}ERROR:${reset} 'satellite' option is not available for ${product}"; echo
                exit 1
            fi
            ;;
        "database")
			if [ "${type}" == "util" ]
			then
				echo; echo "${red}ERROR:${reset} 'database' option is not available for ${product}"; echo
                exit 1
			else
				databaseOption="true"
				shift
			fi
            ;;
        "product-config")
			if [ "${type}" == "util" ]
			then
				echo; echo "${red}ERROR:${reset} 'product-config' option is not available for ${product}"; echo
                exit 1
			else
				productConfigOption="true"
				shift
			fi
            ;;
        "license")
			if [ "${type}" == "util" ]
			then
				echo; echo "${red}ERROR:${reset} 'license' option is not available for ${product}"; echo
                exit 1
			else			
				licenseOption="true"
				shift
			fi
            ;;
		"gcpAccount")
            gcpAccountOption="true"
            shift
            ;;
        "startup")
			if [ "${type}" == "util" ]
			then
				echo; echo "${red}ERROR:${reset} 'startup' option is not available for ${product}"; echo
                exit 1
			else
				startupOption="true"
				shift
			fi
            ;;
        "dry-run")
            dryRunOption="true"
            shift
            ;;
        "--common-settings")
            if [ $# -eq 1 ] || [ "${2:0:2}" == "--" ]
            then
                echo; echo "${red}ERROR:${reset} Missing parameter after $1"; echo
                exit 1
            else
                commonSettingsFile="$2"
                shift 2
            fi
            ;;
        "--product-settings")
            if [ $# -eq 1 ] || [ "${2:0:2}" == "--" ]
            then
                echo; echo "${red}ERROR:${reset} Missing parameter after $1"; echo
                exit 1
            else
                productSettingsFile="$2"
                shift 2
            fi
            ;;
        "--presentation-settings")
			if [ "${type}" == "util" ] || [ "${type}" == "portal" ]
			then
				echo; echo "${red}ERROR:${reset} '--presentation-settings' is not available for product '${product}'"; echo
                exit 1				
			elif [ "${command}" != "install" ] && [ "${command}" != "install-all" ]
			then
				echo; echo "${red}ERROR:${reset} '--presentation-settings' is not available for Command ${bold}${command}${reset}"; echo
                exit 1		
            elif [ $# -eq 1 ] || [ "${2:0:2}" == "--" ]
            then
                echo; echo "${red}ERROR:${reset} Missing parameter after $1"; echo
                exit 1
			else			
				presentationSettingsFile="$2"
				shift 2
            fi
            ;;
        "--portal-settings")
			if [ "${type}" == "util" ]
			then
				echo; echo "${red}ERROR:${reset} '--portal-settings' is not available for ${product}"; echo
                exit 1
            elif [ $# -eq 1 ] || [ "${2:0:2}" == "--" ]
            then
                echo; echo "${red}ERROR:${reset} Missing parameter after $1"; echo
                exit 1
            else
                portalSettingsFile="$2"
                shift 2
            fi
            ;;
        "--packages-dir")
            if [ $# -eq 1 ] || [ "${2:0:2}" == "--" ]
            then
                echo; echo "${red}ERROR:${reset} Missing parameter after $1"; echo
                exit 1
            else
                riskManagementPackagesDir="$2"
                shift 2
            fi
            ;;
        *)
            leftOverParams="$leftOverParams $1" # save positional arg
            shift # past argument
            ;;
    esac
done

if [ ! -z "${presentationSettingsFile}" ] && [ "${type}" == "rafm-satellite" ]
then
	echo; echo "${red}ERROR:${reset} '--presentation-settings' is not available for product '${product}' of type '${type}'"; echo
	exit 1
fi

if  [ ! -d "${riskManagementPackagesDir}" ]
then
    echo; echo "${red}ERROR:${reset} Risk Management Packages directory '${riskManagementPackagesDir}' not found."; echo
    exit 1
fi

productPackageDir="${riskManagementPackagesDir}/${product}"
if [ ! -d "${productPackageDir}" ]
then
    echo; echo "${red}ERROR:${reset} ${product} directory '${productPackageDir}' not found."; echo
    exit 1
fi

if [ -z "$commonSettingsFile" ]
then
    commonSettingsFile="${riskManagementPackagesDir}/common/aip_settings/common-settings.yaml"
fi
if [ -z "$productSettingsFile" ]
then
    productSettingsFile="${riskManagementPackagesDir}/${product}/aip_settings/${product}-settings.yaml"
fi
if [ -z "$portalSettingsFile" ]
then
    portalSettingsFile="${riskManagementPackagesDir}/portal/aip_settings/portal-settings.yaml"
fi
if [ -z "$pvcAdjustedFile" ]
then
    pvcAdjustedFile="${riskManagementPackagesDir}/${product}/aip_settings/adjusted-pvc-settings.yaml"
fi



if [ ! -z "$leftOverParams" ]
then
    echo; echo "${red}ERROR:${reset} Found invalid parameters: '${leftOverParams}'"; echo
    exit 1
fi

if [ "${productConfigOption}" == "true" ]
then
    validCommands="update-secret"
    findCommand=$(echo "${command}" | grep -qE "^(${validCommands})$"; echo $?)
    if [ "${findCommand}" -eq 1 ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid with option ${bold}product-config${reset}."; echo
        exit 1
    fi
fi

if [ "${licenseOption}" == "true" ]
then
    validCommands="update-secret"
    findCommand=$(echo "${command}" | grep -qE "^(${validCommands})$"; echo $?)
    if [ "${findCommand}" -eq 1 ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid with option ${bold}license${reset}."; echo
        exit 1
    fi
fi

if [ "${startupOption}" == "true" ]
then
    validCommands="patch"
    findCommand=$(echo "${command}" | grep -qE "^(${validCommands})$"; echo $?)
    if [ "${findCommand}" -eq 1 ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid with option ${bold}startup${reset}."; echo
        exit 1
    fi
fi

if [ "${command}" == "patch" ]
then

    if [ "${startupOption}" == "true" ]
    then
        if [ "${type}" == "portal" ]
        then
            patchDir="${productPackageDir}/portal_startup/patches"
        else
            patchDir="${productPackageDir}/rafm_startup/patches"
        fi
    else
        patchDir="${productPackageDir}/patch/patches"
    fi

    if [ ! -d "${patchDir}" ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} ${patchDir} not found for ${product}. Please create directory and include the desired patches to he deployed."; echo
        exit 1
    fi

fi


if [ "${type}" == "util" ]
then

	validCommands="install|drop|create-svc-np|scale-down|scale-up|restart"
	findCommand=$(echo "${command}" | grep -qE "^(${validCommands})$"; echo $?)
	if [ ${findCommand} -eq 1 ]
	then
        print_help
        echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid for ${product}."; echo
        exit 1
    fi

fi


if [ "${type}" == "rafm-satellite" ]
then
	if [ "${satelliteId}" == "presentation" ]
	then
		validCommands="upgrade|drop|update-secret|create-svc-np|create-svc-lb|scale-down|scale-up|restart"	
	else
		validCommands="install|upgrade|drop|update-secret|create-svc-np|create-svc-lb|scale-down|scale-up|restart"	
	fi
    findCommand=$(echo "${command}" | grep -qE "^(${validCommands})$"; echo $?)
    if [ "${findCommand}" -eq 1 ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid on a" $(if [ "${satelliteId}" == "presentation" ]; then echo "${satelliteId}"; fi) "satellite."; echo
        exit 1
    fi

	satelliteSettingsFile="${riskManagementPackagesDir}/${product}/aip_settings/${satelliteId}/${product}-${satelliteId}-override-settings.yaml"

elif [ "${command}" == "deploy-to-portal" ] && [ "${product}" == "portal" ]
then
    print_help
    echo; echo "${red}ERROR:${reset} Cannot use ${bold}deploy-to-portal${reset} with ${bold}${product}${reset}. Please use with a ${bold}rafm${reset} product."; echo
    exit 1
fi

if [ "${command}" == "update-secret" ] && [ "${productConfigOption}" != "true" ] && [ "${licenseOption}" != "true" ] && [ "${gcpAccountOption}" != "true" ]
then
    print_help
    echo; echo "${red}ERROR:${reset} ${bold}${command}${reset} command requires one of the options ${bold}product-config${reset} or ${bold}license${reset} or ${bold}gcpAccount${reset}."; echo
    exit 1
fi

if [ ! -e "${commonSettingsFile}" ]
then
    echo; echo "${red}ERROR:${reset} Common settings file '${commonSettingsFile}' not found."; echo
    exit 1
elif [ ! -e "${productSettingsFile}" ]
then
    echo; echo "${red}ERROR:${reset} Product settings file '${productSettingsFile}' not found."; echo
    exit 1
elif [ "${type}" == "rafm-satellite" ] && [ ! -e "${satelliteSettingsFile}" ]
then
    echo; echo "${red}ERROR:${reset} Satellite settings file '${satelliteSettingsFile}' not found."; echo
    exit 1
elif [ ! "${type}" == "rafm-satellite" ] && [ ! -e  "${portalSettingsFile}" ]
then
    echo; echo "${red}ERROR:${reset} Portal settings file '${portalSettingsFile}' not found."; echo
    exit 1
fi

echo
echo "$(now) Starting: ${bold}$command${reset} over ${bold}$product${reset} of type ${bold}$type${reset}"
echo

echo; echo "Reading common settings from ${commonSettingsFile}:"
eval $(parse_yaml "${commonSettingsFile}" "risk_")

if [ "${type}" == "portal" ]
then
    productSettingsFile="${portalSettingsFile}"
    echo "Reading portal settings from ${productSettingsFile}:"
else
    productSettingsFile="${productSettingsFile}"
    echo "Reading ${product} settings from ${productSettingsFile}:"
fi
eval $(parse_yaml "${productSettingsFile}" "risk_")

if [ "${type}" == "rafm-satellite" ]
then
    echo "Reading Satellite settings from ${satelliteSettingsFile}:"
    eval $(parse_yaml "${satelliteSettingsFile}" "risk_")
fi

echo

error_count=0

if [ "${type}" != "util" ]
then

	get_yaml_setting deploymentName             risk_deployment_name $error_count
	get_yaml_setting storageType                risk_storage_type $error_count
	
	# 'base-dir' becomes basedir: parse yaml eliminates '-' as these aren't valid for variable names
	get_yaml_setting aipDeploymentsRepository   risk_deployment_basedir $error_count
	#remove one "/" character at the start and at the end of the string (replicates AIP behaviour)
	aipDeploymentsRepository="$(echo "${aipDeploymentsRepository}" | sed 's/^\///;s/\/$//')"
	
	get_yaml_setting licenseSecret              risk_deployment_license_secretName $error_count
	get_yaml_setting productConfigSecret        risk_deployment_productConfig_secretName $error_count
	
	get_yaml_setting serverSettingsFile         risk_riskProduct_server $error_count
	
	get_yaml_setting licenseFile                risk_riskProduct_license $error_count

	get_yaml_setting adjustAipInstall			risk_riskProduct_adjustaipinstall $error_count Optional
	get_yaml_setting adjustPVCDeclaration   	risk_riskProduct_adjustpvcdeclaration $error_count Optional

	if [ "${type}" == "rafm" ]
	then
	
		if [ ${command} == "install" ] || [ ${command} == "install-all" ]
		then

			get_yaml_setting installPresentation		risk_riskProduct_installPresentation $error_count Optional
	
			installPresentation=${installPresentation:-false}
		fi
	fi

	if [ "${type}" == "portal" ]
	then
		
		get_yaml_setting portalWithHighAvailability risk_riskProduct_ha $error_count Optional
			
		portalWithHighAvailability=${portalWithHighAvailability:-false}
		
		get_yaml_setting caddySettingsFile risk_riskProduct_caddySettingsFile $error_count Optional
		
	fi

fi

get_yaml_setting imageVersion               risk_image_tag $error_count

get_yaml_setting productNamespace           risk_riskProduct_namespace $error_count

get_yaml_setting aipChartFile               risk_riskProduct_aipChart $error_count
get_yaml_setting helmInstallTimeout         risk_riskProduct_helmInstallTimeout $error_count
get_yaml_setting helmUpgradeTimeout         risk_riskProduct_helmUpgradeTimeout $error_count
get_yaml_setting podStartTimeout            risk_riskProduct_podStartTimeout $error_count Optional

# podStartTimeout defaults to 20 if not set in settings file
podStartTimeout=${podStartTimeout:-20}

if [ "${type}" != "util" ]
then
	get_yaml_setting pgCreateDatabase       risk_riskDatabase_createDatabase $error_count Optional
	
	# set pgCreateDatabase to false if not set in settings file
	pgCreateDatabase=${pgCreateDatabase:-false}
	
	# convert to lowercase
	pgCreateDatabase=${pgCreateDatabase,,}
	
	if [ ! "$pgCreateDatabase" == "true" ] && [ ! "$pgCreateDatabase" == "false" ]
	then
		echo; echo "${red}ERROR:${reset} Invalid value '$pgCreateDatabase' for riskDatabase.createDatabase"; echo
		exit 1
	fi
	
	if [ "${pgCreateDatabase}" == "true" ]
	then
		get_yaml_setting pgDeploymentName           risk_riskDatabase_deploymentName $error_count
		get_yaml_setting pgNamespace                risk_riskDatabase_namespace $error_count
		get_yaml_setting pgVersion                  risk_riskDatabase_version $error_count
		get_yaml_setting pgTablespaceName           risk_riskDatabase_tablespaceName $error_count
	else
		get_yaml_setting pgHost                     risk_riskDatabase_host $error_count
	fi
	
	get_yaml_setting pgUsername                 risk_riskDatabase_username $error_count
	get_yaml_setting pgPassword                 risk_riskDatabase_password $error_count
	get_yaml_setting pgDatabase                 risk_riskDatabase_databaseName $error_count
	get_yaml_setting pgPort                     risk_riskDatabase_port $error_count

fi

if [ "${type}" == "util" ]
then
	get_yaml_setting deploymentReplicas			   risk_replicaCount $error_count Optional
else
	get_yaml_setting deploymentReplicas            risk_deployment_replicas $error_count Optional
fi

if [ "${installPresentation}" == "true" ]
then
		
	if [ -z "$presentationSettingsFile" ]
	then
		presentationSettingsFile="${riskManagementPackagesDir}/${product}/aip_settings/presentation/${product}-presentation-override-settings.yaml"
	fi

	if [ ! -e "${presentationSettingsFile}" ]
	then
		echo; echo "${red}ERROR:${reset} Presentation settings file '${presentationSettingsFile}' not found."; echo
		exit 1
	else

		echo "Reading Presentation settings from ${presentationSettingsFile}:"
		eval $(parse_yaml "${presentationSettingsFile}" "pres_")
	
		get_yaml_setting pres_deploymentName             pres_deployment_name $error_count
		get_yaml_setting pres_productConfigSecret        pres_deployment_productConfig_secretName $error_count	
		get_yaml_setting pres_serverSettingsFile         pres_riskProduct_server $error_count
	fi
fi


if [ $error_count -gt 0 ]
then
    echo; echo "${red}ERROR:${reset} $error_count settings missing. Please fix and try again."; echo
    exit $error_count
fi


get_yaml_setting openShiftDeploy		risk_riskProduct_openShiftDeploy $error_count optional

if [ "${openShiftDeploy}" == "true" ]
then

	get_yaml_setting openShiftSettingsFile		risk_riskProduct_openShiftSettingsFile $error_count
	
	if [ $error_count -gt 0 ]
	then		
		echo; echo "${red}ERROR:${reset} OpenShift Settings File parameter missing. Please fix and try again."; echo
		exit $error_count
	fi
	
	openShiftSettingsFile="${riskManagementPackagesDir}/${openShiftSettingsFile}"
	
	if [ ! -e "${openShiftSettingsFile}" ]
	then
		echo; echo "${red}ERROR:${reset} OpenShift settings file '${openShiftSettingsFile}' not found."; echo
		exit 1
	fi
	
	echo; echo "Reading OpenShift settings from ${openShiftSettingsFile}:"

	eval $(parse_yaml ${openShiftSettingsFile} "openshift_")
	
	get_yaml_setting pgBitnamiSettingsFile		openshift_riskDatabase_bitnamiPostgreSQLSettings $error_count optional

	if  [ "${pgCreateDatabase}" == "true" ] && [ "${type}" != "util" ]
	then	
		if [ "${command}" == "install-all" ] || [ "${command}" == "create-pg-db"  ] || [ "${command}" == "create-pg-part" ]
		then
			if [ -z "${pgBitnamiSettingsFile}" ]
			then
				echo; echo "${red}ERROR:${reset} Setting riskDatabase.bitnamiPostgreSQLSettings is missing. Please fix and try again."; echo
				exit 1
			fi

			if [ ! -e "${riskManagementPackagesDir}/${pgBitnamiSettingsFile}" ]
			then
				echo; echo "${red}ERROR:${reset} File '${riskManagementPackagesDir}/${pgBitnamiSettingsFile}' not found."; echo
				exit 1	
			fi
		fi
	fi
fi


if [ "${databaseOption}" == "true" ]
then
    if [ "${type}" == "rafm-satellite" ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} Database option not available together with satellite."; echo
        exit 1
    fi
    if [ -z "$pgHost" ]
    then
        validCommands="drop|create-svc-np|create-svc-lb|create-port-forward"
    else
        validCommands="drop"
        errorTextAdd="that is outside of the cluster."
    fi
    findCommand=$(echo "${command}" | grep -qE "^(${validCommands})$"; echo $?)
    if [ "${findCommand}" -eq 1 ]
    then
        print_help
        echo; echo "${red}ERROR:${reset} Command ${bold}${command}${reset} is not valid on a database ${errorTextAdd}."; echo
        exit 1
    fi
fi

if [ "${type}" != "util" ]
then

	if [ "${storageType}" == "s3" ]
	then
	
		get_yaml_setting storageSettingsFile risk_riskProduct_storageS3SettingsFile $error_count
		
		if [ $error_count -gt 0 ]
		then		
			echo; echo "${red}ERROR:${reset} S3 Storage Settings File parameter missing. Please fix and try again."; echo
			exit $error_count
		fi
		
		storageSettingsFile="${riskManagementPackagesDir}/${storageSettingsFile}"
		
		if [ ! -e "${storageSettingsFile}" ]
		then
			echo; echo "${red}ERROR:${reset} S3 Storage settings file '${storageSettingsFile}' not found."; echo
			exit 1
		fi

		echo; echo "Reading S3 Storage settings from ${storageSettingsFile}:"

		eval $(parse_yaml ${storageSettingsFile} "st_")
		
		echo
		get_yaml_setting storageS3Endpoint st_storage_s3_endpoint $error_count
		if [ $error_count -gt 0 ]
		then
			echo; echo "${red}ERROR:${reset} S3 Storage endpoint missing. Please fix and try again."; echo
			exit $error_count
		fi
		get_yaml_setting awsProfile st_riskProduct_awsProfile $error_count
		if [ $error_count -gt 0 ]
		then
			echo
			echo "${cyan}WARN${reset}: no specific aws profile found in settings."
			error_count=0
			awsProfile=""
		else
			awsProfile="--profile ${awsProfile}"
		fi
	elif [ "${storageType}" == "gs" ]
	then
		
		get_yaml_setting storageSettingsFile risk_riskProduct_storageGcSettingsFile $error_count

		if [ $error_count -gt 0 ]
		then		
			echo; echo "${red}ERROR:${reset} Google Cloud Storage Settings File parameter missing. Please fix and try again."; echo
			exit $error_count
		fi

		storageSettingsFile="${riskManagementPackagesDir}/${storageSettingsFile}"
		
		if [ ! -e "${storageSettingsFile}" ]
		then
			echo; echo "${red}ERROR:${reset} Google Cloud Storage settings file '${storageSettingsFile}' not found."; echo
			exit 1
		fi
	
		echo; echo "Reading Google Cloud Storage settings from ${storageSettingsFile}:"

		eval $(parse_yaml ${storageSettingsFile} "st_")
	
		echo
		get_yaml_setting storageGsProjectID st_storage_gs_projectid $error_count
		if [ $error_count -gt 0 ]
		then
			echo; echo "${red}ERROR:${reset} Google Cloud Storage (gs) project ID missing. Please fix and try again."; echo
			exit $error_count
		fi

		get_yaml_setting gcpAccountFile		st_riskProduct_gcpAccountFile $error_count Optional
		get_yaml_setting gcpSecretName		st_riskProduct_gcpSecretName $error_count Optional
				
	else
		echo; echo "${red}ERROR:${reset} Storage type '${storageType}' is not supported!"; echo
		exit 1
	fi
	
fi

echo

if [ "${type}" != "util" ]
then

	if [ "${type}" == "rafm-satellite" ]
	then		
		productConfigFile="${productPackageDir}/support_files/${satelliteId}/product-config-${satelliteId}.xml"		
	else	
		productConfigFile="${productPackageDir}/support_files/product-config.xml"	
	fi

	if [ "${installPresentation}" == "true" ]
	then
	
		pres_productConfigFile="${productPackageDir}/support_files/presentation/product-config-presentation.xml"
	
	fi
fi

if [ $error_count -gt 0 ]
then
    echo; echo "${red}ERROR:${reset} $error_count settings missing. Please fix and try again."; echo
    exit $error_count
fi

if [ ! -e "${riskManagementPackagesDir}/${serverSettingsFile}" ] && [ "${type}" != "util" ]
then
    echo; echo "${red}ERROR:${reset} File '${riskManagementPackagesDir}/${serverSettingsFile}' not found."; echo
    exit 1
elif [ ! -e "${riskManagementPackagesDir}/${pres_serverSettingsFile}" ] && [ "${installPresentation}" == "true" ]
then
	echo; echo "${red}ERROR:${reset} File '${riskManagementPackagesDir}/${pres_serverSettingsFile}' not found."; echo
    exit 1
elif [ ! -e "${riskManagementPackagesDir}/${aipChartFile}" ]
then
    echo; echo "${red}ERROR:${reset} File '${riskManagementPackagesDir}/${aipChartFile}' not found."; echo
    exit 1
elif [ ! -e "${riskManagementPackagesDir}/${licenseFile}" ] && [ "${type}" != "util" ]
then
    echo; echo "${red}ERROR:${reset} File '${riskManagementPackagesDir}/${licenseFile}' not found."; echo
    exit 1
elif [ ! -e "${productConfigFile}" ] && [ "${type}" != "util" ]
then
    echo; echo "${red}ERROR:${reset} File '${productConfigFile}' not found."; echo
    exit 1
elif [ ! -e "${pres_productConfigFile}" ] && [ "${installPresentation}" == "true" ]
then
    echo; echo "${red}ERROR:${reset} File '${pres_productConfigFile}' not found."; echo	
	exit 1
elif [ "${type}" == "rafm-satellite" ] && [ $(grep -q '<boolean name="Satellite">true</boolean>' "${productConfigFile}"; echo $?) -ne 0 ]
then
    echo; echo "${red}ERROR:${reset} Product config not valid for Satellite installation. <boolean name=\"Satellite\">true</boolean> not found in ${productConfigFile} -  "; echo
    exit 1
elif [ "${installPresentation}" == "true" ] && [ $(grep -q '<boolean name="Satellite">true</boolean>' "${pres_productConfigFile}"; echo $?) -ne 0 ]
then
    echo; echo "${red}ERROR:${reset} Product config not valid for Presentation Server installation. <boolean name=\"Satellite\">true</boolean> not found in ${pres_productConfigFile} -  "; echo
	exit
fi

objectStorageEndPointParameter="--endpoint-url ${storageS3Endpoint}"

if [ "${portalWithHighAvailability}" == "true" ]
then

	if [ -z "$caddySettingsFile" ]
	then
		caddySettingsFile="${riskManagementPackagesDir}/caddy/aip_settings/caddy-settings.yaml"
	else
		caddySettingsFile="${riskManagementPackagesDir}/${caddySettingsFile}"
	fi
		
	if [ ! -e "${caddySettingsFile}" ]
	then
		echo; echo "${red}ERROR:${reset} Caddy settings file '${caddySettingsFile}' not found."; echo
		exit 1
	fi

    echo; echo "Reading caddy settings from ${caddySettingsFile}:"

    eval $(parse_yaml ${caddySettingsFile} "caddy_")
		
	error_count=0

	get_yaml_setting caddyAipChartFile			caddy_riskProduct_aipChart $error_count
	get_yaml_setting caddyImageVersion			caddy_image_tag $error_count		

    if [ $error_count -gt 0 ]
    then
        echo; echo "${red}ERROR:${reset} $error_count settings missing. Please fix and try again."; echo
        exit $error_count
    fi
	
	if [ ! -e "${riskManagementPackagesDir}/${caddyAipChartFile}" ]
	then
		echo; echo "${red}ERROR:${reset} File '${riskManagementPackagesDir}/${caddyAipChartFile}' not found."; echo
		exit 1
	fi

fi


if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ] 
then
    echo; echo "Reading storage class for auditing"
    get_yaml_setting pvStorageClass             risk_persistence_common__claim_storageClass $error_count

    audit_storage_class "$pvStorageClass"

    echo; echo "Reading common settings again for Portal from ${commonSettingsFile}"
    eval $(parse_yaml ${commonSettingsFile} "portal_")
    echo "Reading portal settings from ${portalSettingsFile}"
    eval $(parse_yaml ${portalSettingsFile} "portal_")
    echo

    error_count=0
    get_yaml_setting portalDeploymentsRepository    portal_deployment_basedir $error_count
    get_yaml_setting portalDeploymentName           portal_deployment_name $error_count
    get_yaml_setting portalChartFile                portal_riskProduct_aipChart $error_count
    get_yaml_setting portalHelmUpgradeTimeout       portal_riskProduct_helmUpgradeTimeout $error_count
    get_yaml_setting portalNamespace                portal_riskProduct_namespace $error_count
    get_yaml_setting portalServerSettingsFile       portal_riskProduct_server $error_count
    get_yaml_setting portalImageVersion             portal_image_tag $error_count
	get_yaml_setting portaldeploymentReplicas		portal_deployment_replicas $error_count Optional

    get_yaml_setting portalPgCreateDatabase         portal_riskDatabase_createDatabase $error_count Optional
    # set portalPgCreateDatabase to false if not set in settings file
    portalPgCreateDatabase=${portalPgCreateDatabase:-false}

    # convert to lowercase
    portalPgCreateDatabase=${portalPgCreateDatabase,,}

    if [ ! "$portalPgCreateDatabase" == "true" ] && [ ! "$portalPgCreateDatabase" == "false" ]
    then
        echo; echo "${red}ERROR:${reset} Invalid value '$portalPgCreateDatabase' for riskDatabase.createDatabase"; echo
        exit 1
    fi

    if [ "${portalPgCreateDatabase}" == "true" ]
    then
        get_yaml_setting portalPgDeploymentName         portal_riskDatabase_deploymentName $error_count
        get_yaml_setting portalPgNamespace              portal_riskDatabase_namespace $error_count
    else
        get_yaml_setting portalPgHost                   portal_riskDatabase_host $error_count Optional
    fi
    get_yaml_setting portalPgDatabase               portal_riskDatabase_databaseName $error_count
    get_yaml_setting portalPgPort                   portal_riskDatabase_port $error_count
    if [ $error_count -gt 0 ]
    then
        echo; echo "${red}ERROR:${reset} $error_count settings missing. Please fix and try again."; echo
        exit $error_count
    fi

	#remove one "/" character at the start and at the end of the string (replicates AIP behaviour)
	portalDeploymentsRepository="$(echo "${portalDeploymentsRepository}" | sed 's/^\///;s/\/$//')"

fi


if [ "${type}" != "util" ]
then
	audit_product_config_vs_aip_settings "${productConfigFile}"
fi


if [ "${type}" == "util" ]
then
	deploymentName="${product}"
fi


echo
echo; echo "$(now) ${green}INFO${reset}: All information collected! Ready to execute the '${command}' command for ${product}" $(if [ "${type}" == "rafm-satellite" ]; then echo " satellite ${satelliteId}"; fi) " !!!"
echo
read -p "Do you want to continue? (Y/N) " -n 1 -r
echo 

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

if [ "${command}" == "drop-ns" ] || [ "${command}" == "install-all" ]
then

    delete_namespace "${productNamespace}"

    if [ "${command}" == "install-all" ] && [ "$pgNamespace" != "$productNamespace" ] && [ "${pgCreateDatabase}" == "true" ]
    then
        delete_namespace "${pgNamespace}"
    fi

fi

if [ "${command}" == "create-pg-db" ] || [ "${command}" == "install-all" ]
then

    if [ "${pgCreateDatabase}" == "true" ]
    then
        create_namespace "${pgNamespace}"
        create_bitnami_pg_db "${pgDeploymentName}" "${pgNamespace}" "${pgPassword}" "${pgDatabase}" "${pgPort}" "${pgVersion}" "${pgBitnamiSettingsFile}"
    else
        echo "${cyan}WARN:${reset} Database not set for creation by risk-man. Skipping database create."
    fi
fi

if [ "${command}" == "create-pg-part" ] || [ "${command}" == "install-all" ]
then
    if [ "${pgCreateDatabase}" == "true" ]
    then
        create_bitnami_pg_part "${pgDeploymentName}" "${pgNamespace}" "${pgPassword}" "${pgDatabase}" "${pgPort}" "${pgBitnamiSettingsFile}" "${pgTablespaceName}"
    else
        echo "${cyan}WARN:${reset} Database not set for creation by risk-man. Skipping partition create."
    fi
fi

if [ "${command}" == "install" ] || [ "${command}" == "install-all" ]
then
    create_namespace "${productNamespace}"

	if [ "${type}" != "util" ]
	then
		storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "" "${storageGsProjectID}" "--recursive"
		create_license_secret "${productNamespace}" "${riskManagementPackagesDir}" "${licenseSecret}" "${licenseFile}"
	
		create_product_config_secret "${productNamespace}" "${productConfigSecret}" "${productConfigFile}"
		
		create_gcp_config_secret "${productNamespace}" "${productPackageDir}" "${gcpSecretName}" "${gcpAccountFile}"
	
		if [ "${adjustAipInstall}" == "true" ]
		then
			aipFolderAdjustment="/installproduct/"
		fi
		
	fi	
	
    if [ "${type}" == "rafm" -o "${type}" == "rafm-satellite" ]
    then
        storage_cp "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${productPackageDir}/rafm_setup" \
            "${aipDeploymentsRepository}/${deploymentName}/setup${aipFolderAdjustment}" \
            "${storageGsProjectID}" \
            "--recursive"

        storage_cp "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${productPackageDir}/rafm_startup" \
            "${aipDeploymentsRepository}/${deploymentName}/startup${aipFolderAdjustment}" \
            "${storageGsProjectID}" \
            "--recursive"
			
		if [ "${adjustAipInstall}" == "true" ]
		then
			storage_cp "${storageType}" "${awsProfile}" \
				"${objectStorageEndPointParameter}" \
				"${riskManagementPackagesDir}/common/support_files/wpkg.yaml" \
				"${aipDeploymentsRepository}/${deploymentName}/setup${aipFolderAdjustment}" \
				"${storageGsProjectID}" 
			storage_cp "${storageType}" "${awsProfile}" \
				"${objectStorageEndPointParameter}" \
				"${riskManagementPackagesDir}/common/support_files/wpkg.yaml" \
				"${aipDeploymentsRepository}/${deploymentName}/startup${aipFolderAdjustment}" \
				"${storageGsProjectID}" 
		fi

    fi

    helm_install "${type}" "${deploymentName}" "${productNamespace}" "${commonSettingsFile}" "${productSettingsFile}" "${satelliteSettingsFile}" "${riskManagementPackagesDir}" "${serverSettingsFile}" "${helmInstallTimeout}" "${aipChartFile}" "${imageVersion}" "${adjustPVCDeclaration}" "${pvcAdjustedFile}" "${storageSettingsFile}" "${openShiftSettingsFile}"

    wait_pod_ready "${deploymentName}" "${productNamespace}" "${type}" "600s"

	if [ ! -z "${headless}" ]
    then
        echo; echo "$(now) ${green}INFO${reset}: Going to create headless service for ${deploymentName} as ${deploymentName}${headless}."
        create_k8s_service_headless "${deploymentName}" "${productNamespace}" "${headless}"
    fi
						 
    echo; echo "$(now) ${deploymentName} install is finished!"; echo

	if [ "${installPresentation}" == "true" ] 
	then
		
		storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${pres_deploymentName}" "" "${storageGsProjectID}" "--recursive"

		create_product_config_secret "${productNamespace}" "${pres_productConfigSecret}" "${pres_productConfigFile}"

		storage_cp "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${productPackageDir}/rafm_setup" \
            "${aipDeploymentsRepository}/${pres_deploymentName}/setup" \
            "${storageGsProjectID}" \
            "--recursive"

        storage_cp "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${productPackageDir}/rafm_startup" \
            "${aipDeploymentsRepository}/${pres_deploymentName}/startup" \
            "${storageGsProjectID}" \
            "--recursive"

		helm_install "rafm-satellite" "${pres_deploymentName}" "${productNamespace}" "${commonSettingsFile}" "${productSettingsFile}" "${presentationSettingsFile}" "${riskManagementPackagesDir}" "${serverSettingsFile}" "${helmInstallTimeout}" "${aipChartFile}" "${imageVersion}" "${adjustPVCDeclaration}" "${pvcAdjustedFile}" "${storageSettingsFile}" "${openShiftSettingsFile}"

		wait_pod_ready "${pres_deploymentName}" "${productNamespace}" "rafm-satellite" "600s"

		echo; echo "$(now) ${pres_deploymentName} install is finished!"; echo
		
	
	fi 
	
	if [ "${portalWithHighAvailability}" == "true" ] 
	then	
		
		helm_install "" "caddy" "${productNamespace}" "${commonSettingsFile}" "${caddySettingsFile}" "" "${riskManagementPackagesDir}" "" "${helmInstallTimeout}" "${caddyAipChartFile}" "${caddyImageVersion}" "" "" "" "${openShiftSettingsFile}"

		wait_pod_ready "caddy" "${productNamespace}" "" "600s"
		
		echo; echo "$(now) caddy install is finished!"; echo
	fi
	
    if [ "${type}" == "rafm" ]
    then
        echo
        echo "${green}Check if installation was sucessful. ${reset}"
        echo
        read -p "Do you want to deploy ${deploymentName} to portal (Y/N)? " -n 1 -r
        echo 

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi

        command="deploy-to-portal"
    fi
fi

if [ "${command}" == "upgrade" ]
then

	if [ "${type}" != "util" ]
	then

		storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "upgrade" "${storageGsProjectID}" "--recursive"
	
		if [ ${adjustAipInstall} == "true" ]
		then
			aipFolderAdjustment="/installproduct/"
		fi
	fi

    if [ "${type}" == "rafm" -o "${type}" == "rafm-satellite" ]
    then
        if [ -d "${productPackageDir}/rafm_upgrade" ]
        then
            storage_cp "${storageType}" "${awsProfile}" \
                "${objectStorageEndPointParameter}" \
                "${productPackageDir}/rafm_upgrade" \
                "${aipDeploymentsRepository}/${deploymentName}/upgrade${aipFolderAdjustment}" \
                "${storageGsProjectID}" \
                "--recursive"
        fi
    elif [ -d "${productPackageDir}/portal_upgrade" ]
    then
        storage_cp "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${productPackageDir}/portal_upgrade" \
            "${aipDeploymentsRepository}/${deploymentName}/upgrade${aipFolderAdjustment}" \
            "${storageGsProjectID}" \
            "--recursive"
    fi
	
	
			
		if [ "${adjustAipInstall}" == "true" ]
		then
		    storage_cp "${storageType}" "${awsProfile}" \
				"${objectStorageEndPointParameter}" \
				"${riskManagementPackagesDir}/common/support_files/wpkg.yaml" \
				"${aipDeploymentsRepository}/${deploymentName}/upgrade${aipFolderAdjustment}" \
				"${storageGsProjectID}" 
           
		fi
	
    scale_down "${deploymentName}" "${productNamespace}" "${type}"

    helm_upgrade_new_values "${type}" "${deploymentName}" "${productNamespace}" "${commonSettingsFile}" "${productSettingsFile}" "${satelliteSettingsFile}" "${riskManagementPackagesDir}" "${serverSettingsFile}" "${helmUpgradeTimeout}" "${aipChartFile}" "${imageVersion}" "${adjustPVCDeclaration}" "${pvcAdjustedFile}" "${storageSettingsFile}" "${openShiftSettingsFile}"

    scale_up "${deploymentName}" "${productNamespace}" "${type}" "${deploymentReplicas}"


	if [ "${type}" != "util" ]
	then
		storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "upgrade" "${storageGsProjectID}" "--recursive"
	fi

fi

if [ "${command}" == "deploy-package" ]
then

    storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "upgrade" "${storageGsProjectID}" "--recursive"
	
	if [ ${adjustAipInstall} == "true" ]
	then
		aipFolderAdjustment="/installproduct/"
	fi

    storage_cp "${storageType}" "${awsProfile}" \
        "${objectStorageEndPointParameter}" \
        "${productPackageDir}/rafm_upgrade" \
        "${aipDeploymentsRepository}/${deploymentName}/upgrade${aipFolderAdjustment}" \
        "${storageGsProjectID}" \
        "--recursive"
		
		if [ "${adjustAipInstall}" == "true" ]
		then
		    storage_cp  "${storageType}" "${awsProfile}" \
			"${objectStorageEndPointParameter}" \
			"${riskManagementPackagesDir}/common/support_files/wpkg.yaml" \
			"${aipDeploymentsRepository}/${deploymentName}/upgrade${aipFolderAdjustment}" \
			"${storageGsProjectID}"           
		fi	
		

    scale_down "${deploymentName}" "${productNamespace}" "${type}"

    helm_upgrade_reuse_values "${deploymentName}" "${productNamespace}" "${riskManagementPackagesDir}" "${helmUpgradeTimeout}" "${aipChartFile}" ""

    scale_up "${deploymentName}" "${productNamespace}" "${type}" "${deploymentReplicas}"

    storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "upgrade" "${storageGsProjectID}" "--recursive"

fi

if [ "${command}" == "drop" ]
then

    scale_down "${deploymentName}" "${productNamespace}" "${type}"

    helm_uninstall "${deploymentName}" "${productNamespace}"

    if [ "${type}" == "rafm-satellite" ]
    then
        delete_k8s_resources "${deploymentName}" "${productNamespace}" "${type}" "postgresql" "${productConfigSecret}"
    else
        delete_k8s_resources "${deploymentName}" "${productNamespace}" "${type}" "postgresql" "${productConfigSecret} ${licenseSecret}"
    fi

	if [ "${type}" != "util" ]
	then
		delete_pv "${deploymentName}" "${productNamespace}" "instance"

		storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "" "${storageGsProjectID}" "--recursive"
	fi

    if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
    then

        storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${portalDeploymentsRepository}/${portalDeploymentName}" "shares/RAFM-${deploymentName}-mashup-portlets.war" ""

        echo "${cyan}WARN:${reset} To complete drop of ${deploymentName} deployment in the portal, please do the following:"
        echo "  - login in the Portal and manually delete any sites associated with the ${deploymentName} deployment."
        echo "  - run ${bold}${script} restart portal${reset} to relaunch the ${portalDeploymentName} without references to ${deploymentName}."

    fi

    if [ "${databaseOption}" == "true" ] && [ "${pgCreateDatabase}" == "true" ]
    then

        helm_uninstall "${pgDeploymentName}" "${pgNamespace}"

        delete_k8s_resources "${pgDeploymentName}" "${pgNamespace}" "postgresql" "" ""

        delete_pv "${pgDeploymentName}" "${pgNamespace}" "db"

    elif [ "$type" == "rafm" ]
    then
        notify_manual_db_clean_user_role_schema "${deploymentName}" "${productPackageDir}/support_files/${productConfigFile}"
    fi

fi

if [ "${command:0:10}" == "create-svc" ] || [ "${command}" == "create-port-forward" ]
then

    serviceTypeAbrev=${command:11}
    error_count=0
    if [ "$databaseOption" == "true" ]
    then
        get_yaml_setting externalPort risk_riskDatabase_externalPort $error_count
        get_yaml_setting targetPort risk_riskDatabase_port $error_count
        targetDeployment="${pgDeploymentName}"
        targetNamespace="${pgNamespace}"
    else
        get_yaml_setting externalPort risk_riskProduct_externalPort $error_count
        targetDeployment="${deploymentName}"
        targetNamespace="${productNamespace}"
    fi

    if [ $error_count -gt 0 ]
    then
        echo; echo "${red}ERROR:${reset} $error_count settings missing. Please fix and try again."; echo
        exit $error_count
    fi

    if [ "${command}" == "create-port-forward" ]
    then
        create_port_forward "${targetDeployment}" "${targetNamespace}" "${type}" "${externalPort}" "${targetPort}"
    else
        create_k8s_service "${targetDeployment}" "${targetNamespace}" "${type}" "${serviceTypeAbrev}" "${databaseOption}" "${externalPort}" "${targetPort}"
    fi


fi


if [ "${command}" == "deploy-to-portal" ]
then

    storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${portalDeploymentsRepository}/${portalDeploymentName}" "upgrade" "${storageGsProjectID}" "--recursive"
	
	if [ "${adjustAipInstall}" == "true" ]
	then
		aipFolderAdjustment="/installproduct/"
	fi
	
	if [ -d ${productPackageDir}/portal_update ]
	then
		mkdir -p ${productPackageDir}/portal_upgrade/
		cp ${productPackageDir}/portal_update/*.tar.gz ${productPackageDir}/portal_upgrade/
	fi

    storage_cp "${storageType}" "${awsProfile}" \
        "${objectStorageEndPointParameter}" \
        "${productPackageDir}/portal_upgrade" \
        "${portalDeploymentsRepository}/${portalDeploymentName}/upgrade${aipFolderAdjustment}" \
        "${storageGsProjectID}" \
        "--recursive"
	if [ ${adjustAipInstall} == "true" ]	
	then
	    storage_cp "${storageType}" "${awsProfile}" \
        "${objectStorageEndPointParameter}" \
        "${riskManagementPackagesDir}/common/support_files/wpkg.yaml" \
        "${portalDeploymentsRepository}/${portalDeploymentName}/upgrade${aipFolderAdjustment}" \
        "${storageGsProjectID}" 
	fi	
	

    helm_upgrade_reuse_values "${portalDeploymentName}" "${portalNamespace}" "${riskManagementPackagesDir}" "${portalHelmUpgradeTimeout}" "${portalChartFile}" ""

    scale_down "${portalDeploymentName}" "${portalNamespace}" "portal"

    scale_up "${portalDeploymentName}" "${portalNamespace}" "portal" "${portaldeploymentReplicas}"

    storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${portalDeploymentsRepository}/${portalDeploymentName}" "upgrade" "${storageGsProjectID}" "--recursive"

fi

if [ "${command}" == "patch" ]
then

    if [ "${startupOption}" == "true" ]
    then

        storage_sync_to_cloud "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${patchDir}" \
            "${aipDeploymentsRepository}/${deploymentName}/startup/patches" \
            "${storageGsProjectID}" \
            "--recursive"

        command="restart"

    else

        storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "patches" "${storageGsProjectID}" "--recursive"

        storage_cp "${storageType}" "${awsProfile}" \
            "${objectStorageEndPointParameter}" \
            "${patchDir}" \
            "${aipDeploymentsRepository}/${deploymentName}/patch/patches" \
            "${storageGsProjectID}" \
            "--recursive"

        scale_down "${deploymentName}" "${productNamespace}" "${type}"

        helm_upgrade_reuse_values "${deploymentName}" "${productNamespace}" "${riskManagementPackagesDir}" "${helmUpgradeTimeout}" "${aipChartFile}" "patch"

        scale_up "${deploymentName}" "${productNamespace}" "${type}" "${deploymentReplicas}"
 
        executeCmd "mkdir -p \"${patchDir}_done\""

        executeCmd "cp -r \"${patchDir}\" \"${patchDir}_done\""

        executeCmd "find \"${patchDir}\" -type f -exec rm {} \;"

        storage_rm "${storageType}" "${awsProfile}" "${objectStorageEndPointParameter}" "${aipDeploymentsRepository}/${deploymentName}" "patch" "${storageGsProjectID}" "--recursive"

    fi

fi

if [ "${command}" == "scale-down" ] || [ "${command}" == "restart" ]
then
    scale_down "${deploymentName}" "${productNamespace}" "${type}"
fi

if [ "${command}" == "scale-up" ] || [ "${command}" == "restart" ]
then
    scale_up "${deploymentName}" "${productNamespace}" "${type}" "${deploymentReplicas}"
fi

if [ "${command}" == "update-secret" ]
then
    if [ "${productConfigOption}" == "true" ]
    then
        delete_secret "$productNamespace" "$productConfigSecret"

        create_product_config_secret "${productNamespace}" "${productConfigSecret}" "${productConfigFile}"
    elif [ "${licenseOption}" == "true" ]
    then
        delete_secret "$productNamespace" "$licenseSecret"

        create_license_secret "${productNamespace}" "${riskManagementPackagesDir}" "${licenseSecret}" "${licenseFile}"
	elif [ "${gcpAccountOption}" == "true" ]
	then
		delete_secret "$productNamespace" "$gcpSecretName"
        
		create_license_secret "${productNamespace}" "${riskManagementPackagesDir}" "${gcpSecretName}" "${gcpAccountFile}"

	
    fi
fi


exit 0
