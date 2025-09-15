#!/bin/sh
# inspiration source: https://gist.github.com/pkuczynski/8665367
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 11`
cyan=`tput setaf 6`
bold=`tput bold`
reset=`tput sgr0`

function parse_yaml() {
    local prefix=$2
    local settings_file_var="${2}settingsFileName"
    fileName="$(basename "$1")"
    if [ -z "${!settings_file_var}" ]
    then
        echo ${2}settingsFileName="${fileName}"
    else
        echo ${2}settingsFileName=\"${!settings_file_var} / $fileName\"
    fi
    local s='[[:space:]]*' w='[a-zA-Z0-9_-]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\(#.*$s\)\?\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\(#.*$s\)\?\$|\1$fs\2$fs\3|p"  "$1" |
        awk -F$fs '{
            indent = length($1)/2;
            vname[indent] = $2;
            for (i in vname) {if (i > indent) {delete vname[i]}}
                if (length($3) > 0) {
                    vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
                    gsub("-","",vn);
                    gsub("-","",$2);
                    printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
                }
            }'
}

function get_yaml_setting() {
    local varName=$1
    local yaml_path=$2
    error_count=$3
    local optional=$4

   # ${yaml_path#*_} = Delete shortest beginning match of pattern "*_" over yaml_path
   local prettyPrintYamlPath="${yaml_path#*_}"

   # ${yaml_path%%_*} = Delete longest trailing match of pattern "_*" over yaml_path
   local settings_file_var="${yaml_path%%_*}_settingsFileName"

   if [ -z "${!yaml_path}" ]
   then
       if [ -z "${optional}" ]
       then
           echo "   ${varName} = ${cyan}[WARN]:${reset} Failed getting value using path '${prettyPrintYamlPath}' in file(s): ${!settings_file_var}"
           error_count=$((error_count + 1))
       fi
   else
       eval $(echo "${varName}=\"${!yaml_path}\"")
       echo "   ${varName} = ${prettyPrintYamlPath} = \"${!yaml_path}\""
   fi
}


function now() {
    echo "[${cyan}$(date +"%d-%b-%Y %H:%M")${reset}]"
}

function executeCmd() {
    cmd="$1"

    echo
    echo "${cyan}${bold}[ $cmd ${cyan}]${reset}"
    echo

    if [ "$dryRunOption" != "true" ]
    then
        sh -c "$cmd"
    fi
}

function create_namespace() {

    local targetNamespace="$1"

    kubectl get namespace ${targetNamespace} > /dev/null 2>&1
    if [ $? -gt 0 ]
    then
        echo "Creating ${targetNamespace} namespace."
        executeCmd "kubectl create namespace ${targetNamespace}"
    else
        echo "Namespace ${targetNamespace} already exists."
    fi
}

function delete_namespace() {

    local targetNamespace="$1"

    echo "$(now) Deleting namespace $targetNamespace"
    kubectl get namespace ${targetNamespace} > /dev/null 2>&1
    if [ $? -gt 0 ] || [ "$dryRunOption" == "true" ]
    then
        echo "Namespace $targetNamespace not found."
    else
        echo
        read -p "${cyan}WARN:${reset} Found namespace ${targetNamespace}. Please confirm you want to delete it? (Y/N) " -n 1 -r
        echo 

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            #executeCmd "kubectl delete namespace ${targetNamespace}"
            if [ $? -gt 0 ]
            then
                echo
                echo "${red}ERROR:${reset} Error deleting namespace ${targetNamespace}"
                echo
                exit 1
            fi
        fi
    fi

}

function create_license_secret() {

    local targetNamespace="$1"
    local riskManagementPackagesDir="$2"
    local licenseSecret="$3"
    local licenseFile="$4"

    kubectl get secret ${licenseSecret} --namespace ${targetNamespace} > /dev/null 2>&1
    if [ $? -gt 0 ] || [ "$dryRunOption" == "true" ]
    then
        echo "$(now) Creating secrets '$licenseSecret' for license file '${riskManagementPackagesDir}/$licenseFile'"
        executeCmd "kubectl create secret generic ${licenseSecret} --from-file="${riskManagementPackagesDir}/${licenseFile}" --namespace ${targetNamespace}"
        if [ $? -ne 0 ]
        then
            echo
            echo "${red}ERROR:${reset} Error creating secret ${licenseSecret} in namespace ${targetNamespace}"
            echo
            exit 1
        fi
    else
        echo "Going to use secret ${licenseSecret} that already exists in namespace ${targetNamespace}"
    fi

}

function create_product_config_secret() {

    local targetNamespace="$1"
    local productConfigSecret="$2"
    local productConfigFile="$3"

    kubectl get secret ${productConfigSecret} --namespace ${targetNamespace} > /dev/null 2>&1
    if [ $? -gt 0 ] || [ "${dryRunOption}" == "true" ]
    then
        echo "$(now) Creating secret '$productConfigSecret' for product-config file '$productConfigFile'"
        executeCmd "kubectl create secret generic ${productConfigSecret} --from-file=product-config.xml="${productConfigFile}" --namespace ${targetNamespace}"
        if [ $? -ne 0 ]
        then
            echo
            echo "${red}ERROR:${reset} Error creating secret ${productConfigSecret} in namespace ${targetNamespace}"
            echo
            exit 1
        fi
    else
        echo "Going to use secret ${productConfigSecret} that already exists in namespace ${targetNamespace}"
    fi

}



function create_gcp_config_secret() {
    if [ ! -z ${gcpSecretName} ]
    then
    
        local targetNamespace="$1"
        local productPackageFullDir="$2"
        local gcpSecretName="$3"
        local gcpAccountFile="$4"

        kubectl get secret ${gcpSecretName} --namespace ${targetNamespace} > /dev/null 2>&1
        if [ $? -gt 0 ] || [ "${dryRunOption}" == "true" ]
        then
            echo "$(now) Creating secret '$gcpSecretName' for product-config file '$gcpAccountFile'"
            executeCmd "kubectl create secret generic ${gcpSecretName} --from-file=service-account.json="${riskManagementPackagesDir}/${gcpAccountFile}" --namespace ${targetNamespace}"
            if [ $? -ne 0 ]
            then
                echo
                echo "${red}ERROR:${reset} Error creating secret ${gcpSecretName} in namespace ${targetNamespace}"
                echo
                exit 1
            fi
        else
            echo "Going to use secret ${gcpSecretName} that already exists in namespace ${targetNamespace}"
        fi

    fi

}




function storage_cp() {

    local storageType="$1"
    local awsProfile="$2"
    local objectStorageEndPointParameter="$3"
    local copyFrom="$4"
    local copyTo="$5"
    local storageGsProjectID="$6"
    local recursive="$7"

    filteredPath=$(echo "${copyTo}" | sed 's|^s3://|s3/|')
    copyTo=$(echo "$filteredPath" | sed 's#//*#/#g')


    lastPart="${copyFrom##*/}"
      
    if [[ "$copyFrom" != */ && "$lastPart" != *.* ]]; then
       copyFrom="$copyFrom/"
    fi

    echo "Copying from local ${copyFrom} to ${copyTo}"

    if [ -z "$(find ${copyFrom} -type f)" ]
    then
        echo ""
        echo "${cyan}INFO:${reset} ${copyFrom} has no files. Nothing to copy.3 removed condition"
        echo ""
    else
        if [ "${storageType}" == "s3" ]
        then
            #executeCmd "aws ${objectStorageEndPointParameter} $awsProfile s3 cp ${recursive} "${copyFrom}" "${copyTo}""
            #if [[ "$copyFrom" == *"wpkg.yaml"* && "$copyTo" == *"startup"* ]]; then
               echo "Skipping the "
                   
	    executeCmd "mc cp ${copyFrom} ${copyTo} ${recursive}"
            
            executeCmd "sleep 20"

        elif [ "${storageType}" == "gs" ]
        then
            if [ ! -z "${recursive}" ]
            then
                recursive="-r"
            fi
            executeCmd "gsutil cp "${recursive}" "${copyFrom}" "${copyTo}""
        fi

        if [ $? -ne 0 ]
        then
            echo
            echo "${red}ERROR:${reset} Error copying  ${copyFrom} to ${copyTo}"
            echo
            exit 1
        fi
    fi
}

function storage_sync_to_cloud () {

    local storageType="$1"
    local awsProfile="$2"
    local objectStorageEndPointParameter="$3"
    local copyFrom="$4"
    local copyTo="$5"
    local storageGsProjectID="$6"
    local recursive="$7"

    echo "Sync from local ${copyFrom} to ${copyTo}"

    filteredPath=$(echo "${copyTo}" | sed 's|^s3://|s3/|')
    copyTo=$(echo "$filteredPath" | sed 's#//*#/#g')

    if [ -z "$(find ${copyFrom} -type f)" ]
    then
        echo "${cyan}INFO:${reset} ${copyFrom} has no files. Nothing to copy.4"
    else
        if [ "${storageType}" == "s3" ]
        then
            #executeCmd "aws ${objectStorageEndPointParameter} $awsProfile s3 sync "${copyFrom}" "${copyTo}""
            executeCmd "mc cp ${copyFrom} ${copyTo}"
            executeCmd "sleep 5"
			
        elif [ "${storageType}" == "gs" ]
        then
            if [ ! -z "${recursive}" ]
            then
                recursive="-r"
            fi
            executeCmd "gsutil rsync "${recursive}" "${copyFrom}" "${copyTo}""
        fi

        if [ $? -ne 0 ]
        then
            echo
            echo "${red}ERROR:${reset} Error running sync  ${copyFrom} to ${copyTo}"
            echo
            exit 1
        fi
    fi
}

function storage_rm() {

    local storageType="$1"
    local awsProfile="$2"
    local objectStorageEndPointParameter="$3"
    local toDelete="$4"
    local object="$5"
    local storageGsProjectID="$6"
    local recursive="$7"

    #toDelete=$(echo "${toDelete}" | sed 's|^s3://|s3/|')

    if [ ! -z "${object}" ]
    then
        local toDelete="${toDelete}/${object}"
    fi

    echo "Cleaning up ${toDelete}."
   
    toDelete=$(echo "${toDelete}" | sed 's|^s3://|s3/|')    

    if [ "${storageType}" == "s3" ]
    then
        #executeCmd "aws ${objectStorageEndPointParameter}  $awsProfile s3 rm ${recursive} "${toDelete}""
        executeCmd "mc rm  --recursive --force ${toDelete} "
        executeCmd "sleep 5"        

    elif [ "${storageType}" == "gs" ]
    then
        if [ ! -z "${recursive}" ]
        then
            recursive="-r"
        fi
        executeCmd "gsutil ls "${toDelete}""
        if [ $? -eq 0 ]
        then
            executeCmd "gsutil rm "${recursive}" "${toDelete}""
        else
            echo "${cyan}INFO:${reset} ${toDelete} not found in storage."
        fi
    fi


    if [ $? -ne 0 ]
    then
        echo
        echo "${red}ERROR:${reset} Error cleaning up ${toDelete}"
        echo
        exit 1
    fi

}

function helm_install() {

    local type=$1
    local deploymentName="$2"
    local targetNamespace="$3"
    local commonSettingsFile="$4"
    local productSettingsFile="$5"
    local satelliteSettingsFile="$6"
    local riskManagementPackagesDir="$7"
    local serverSettingsFile="$8"
    local helmInstallTimeout="$9"
    local aipChartFile="${10}"
    local imageVersion="${11}"
	local adjustPVCDeclaration="${12}"
	local pvcAdjustedFile="${13}"
	local storageSettingsFile="${14}"
	local openShiftSettingsFile="${15}"

    echo
    echo "$(now) Install ${deploymentName}..."
    echo "----"

    installStartSec=$(date +%s)

	executeCmd "helm install "${deploymentName}" -f "${commonSettingsFile}" $(if [ ! -z "${storageSettingsFile}" ]; then echo "-f ${storageSettingsFile}"; fi) $(if [ ! -z "${openShiftSettingsFile}" ]; then echo "-f ${openShiftSettingsFile}"; fi) -f "${productSettingsFile}" $(if [ "${type}" == "rafm-satellite" ]; then echo "-f ${satelliteSettingsFile}"; fi)  $(if [ "${adjustPVCDeclaration}" == "true" ]; then echo "-f ${pvcAdjustedFile}"; fi) $(if [ -n "${serverSettingsFile}" ]; then echo "-f ${riskManagementPackagesDir}/${serverSettingsFile}"; fi) --timeout ${helmInstallTimeout} -n "${targetNamespace}" "${riskManagementPackagesDir}/${aipChartFile}" --version "${imageVersion}""

    error_code=$?

    installEndSec=$(date +%s)
    durationSec=$(( ${installEndSec} - ${installStartSec} ))
    duration=$(date +%H:%M:%S -ud @${durationSec})

    if [ $error_code -ne 0 ]
    then
        echo
        echo "${red}ERROR:${reset} helm install failed for ${deploymentName} after ${duration}!"
        echo
        exit 1
    fi

    echo "----"
    echo "$(now) - ${deploymentName} install ended. Install duration: ${duration}" 
    echo ""
    echo "Going to Start deployment next soon...............!!!!!"
    executeCmd "sleep 420"
    echo

}

function helm_upgrade_reuse_values() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local riskManagementPackagesDir="$3"
    local helmUpgradeTimeout="$4"
    local aipChartFile="$5"
    local deploymentMode="$6"

    echo
    echo "$(now) Going to upgrade ${deploymentName}..."
    echo "----"

    upgradeStartSec=$(date +%s)

    executeCmd "helm upgrade "${deploymentName}" "${riskManagementPackagesDir}/${aipChartFile}" --reuse-values $(if [ ! -z "${deploymentMode}" ]; then echo "--set deployment.mode=patch"; fi) --timeout ${helmUpgradeTimeout} -n "${targetNamespace}""

    error_code=$?

    upgradeEndSec=$(date +%s)
    durationSec=$(( ${upgradeEndSec} - ${upgradeStartSec} ))
    duration=$(date +%H:%M:%S -ud @${durationSec})

    if [ $error_code -ne 0 ]
    then
        echo
        echo "${red}ERROR:${reset} helm upgrade failed for ${deploymentName} after ${duration}!"
        echo
        exit 1
    fi

    echo "----"
    echo "$(now) - ${deploymentName} helm upgrade ended. Duration: ${duration}" 
    echo

}


# Function to extract PVC YAML by name from the Upgrade Command
extract_pvc_yaml() {

    local helm_upgrade_cmnd="$1"
    local pvc_name="$2"
    eval "$helm_upgrade_cmnd" | awk -v target="$pvc_name" '
        BEGIN {RS="---"; ORS="---"}
        /kind: PersistentVolumeClaim/ && $0 ~ "name:[[:space:]]+"target {
            print
            found=1
        }
        END {if (!found) print "PVC " target " not found in Helm output" > "/dev/stderr"}
    ' | sed '/^[[:space:]]*$/d' >> "/tmp/"$pvc_name.yaml

    executeCmd "kubectl apply -f '/tmp/'$pvc_name.yaml"
    echo "$(now) - PVC created successfully: $pvc_name.yaml"
    echo ""
}


extract_svc_yaml() {
    local helm_upgrade_cmnd="$1"
    local svc_name="$2"
    [ -f '/tmp/'$svc_name.yaml ] && rm -f '/tmp/'$svc_name.yaml
    eval "$helm_upgrade_cmnd" | awk -v target="$svc_name" '
        BEGIN {RS="---"; ORS="---"}
        /kind: Service/ && $0 ~ "name:[[:space:]]+"target {
            print
            found=1
        }
        END {if (!found) print "SVC " target " not found in Helm output" > "/dev/stderr"}
    ' | sed '/^[[:space:]]*$/d' >> "/tmp/"$svc_name.yaml
    
    executeCmd "kubectl apply -f '/tmp/'$svc_name.yaml"
    echo "$(now) - SVC created successfully: $svc_name.yaml"
    echo ""
}


# Function to the New Pvc from the Upgrade Command
function detect_new_svc() {
    local helm_upgrade_cmnd=$1
    local targetNamespace=$2
    echo "${dryRunOption}"

    if [ "${dryRunOption}" != "true" ];
     then
       # Get list of PVC names
       svcList=$(eval "$helm_upgrade_cmnd" | awk '/kind: Service/{flag=1} flag && /name:/{print $2; flag=0}')

       for svc in $svcList; do

              echo "Detected the New SVC: $svc"
              extract_svc_yaml "$helm_upgrade_cmnd" "$svc"

        done
      fi

}




# Function to the New Pvc from the Upgrade Command
function detect_new_pvc() {

    local helm_upgrade_cmnd=$1
    local targetNamespace=$2
    echo "${dryRunOption}"

    if [ "${dryRunOption}" != "true" ];
     then
       # Get list of PVC names
       pvcList=$(eval "$helm_upgrade_cmnd" | awk '/kind: PersistentVolumeClaim/{flag=1} flag && /name:/{print $2; flag=0}')

       for pvc in $pvcList; do

           if kubectl get pvc "$pvc" -n "${targetNamespace}" &>/dev/null; then
              continue
           else
              echo ""
              echo "Detected the New PVC: $pvc"
              extract_pvc_yaml "$helm_upgrade_cmnd" "$pvc"
           fi

        done
      fi

}


function helm_upgrade_new_values() {

    local type=$1
    local deploymentName="$2"
    local targetNamespace="$3"
    local commonSettingsFile="$4"
    local productSettingsFile="$5"
    local satelliteSettingsFile="$6"
    local riskManagementPackagesDir="$7"
    local serverSettingsFile="$8"
    local helmUpgradeTimeout="$9"
    local aipChartFile="${10}"
    local imageVersion="${11}"
	local adjustPVCDeclaration="${12}"
	local pvcAdjustedFile="${13}"
	local storageSettingsFile="${14}"
	local openShiftSettingsFile="${15}"

    echo
    echo "$(now) Going to upgrade ${deploymentName}..."
    echo "----"

    upgradeStartSec=$(date +%s)

    helm_upgrade_cmnd="helm upgrade "${deploymentName}" "${riskManagementPackagesDir}/${aipChartFile}" -f "${commonSettingsFile}" $( [ -n "${storageSettingsFile}" ] && echo "-f ${storageSettingsFile}" ) $( [ -n "${openShiftSettingsFile}" ] && echo "-f ${openShiftSettingsFile}" ) \
            -f "${productSettingsFile}" $( [ "${type}" == "rafm-satellite" ] && echo "-f ${satelliteSettingsFile}" ) $( [ "${adjustPVCDeclaration}" == "true" ] && echo "-f ${pvcAdjustedFile}" ) -f "${riskManagementPackagesDir}/${serverSettingsFile}" \
            --timeout "${helmUpgradeTimeout}" --version "${imageVersion}" -n "${targetNamespace}" --dry-run 2>&1"

    detect_new_pvc "$helm_upgrade_cmnd" "${targetNamespace}"

    executeCmd "sleep 5"

    executeCmd "helm upgrade "${deploymentName}" "${riskManagementPackagesDir}/${aipChartFile}" -f "${commonSettingsFile}" $(if [ ! -z "${storageSettingsFile}" ]; then echo "-f ${storageSettingsFile}"; fi) $(if [ ! -z "${openShiftSettingsFile}" ]; then echo "-f ${openShiftSettingsFile}"; fi) -f "${productSettingsFile}" $(if [ "${type}" == "rafm-satellite" ]; then echo "-f ${satelliteSettingsFile}"; fi) $(if [ "${adjustPVCDeclaration}" == "true" ]; then echo "-f ${pvcAdjustedFile}"; fi)  -f "${riskManagementPackagesDir}/${serverSettingsFile}" --timeout ${helmUpgradeTimeout} --version "${imageVersion}" -n "${targetNamespace}""

    echo 
    echo "----"
    echo "$(now):  Creating the Services if not available"   

    detect_new_svc "$helm_upgrade_cmnd" "${targetNamespace}"
 
    error_code=$?

    upgradeEndSec=$(date +%s)
    durationSec=$(( ${upgradeEndSec} - ${upgradeStartSec} ))
    duration=$(date +%H:%M:%S -ud @${durationSec})

    if [ $error_code -ne 0 ]
    then
        echo
        echo "${red}ERROR:${reset} helm upgrade failed for ${deploymentName} after ${duration}!"
        echo
        exit 1
    fi

    echo "----"
    echo "$(now) - ${deploymentName} helm upgrade ended. Duration: ${duration}" 
    echo

}

function find_running_pod() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local type="$3"

    echo "Looking for a ${type} running pod for deployment ${deploymentName} in namespace ${targetNamespace}."

	if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
	then
		local deploymentNameAdjusted="${deploymentName}-rafm"
	else
		local deploymentNameAdjusted="${deploymentName}"
	fi
	
	runningPodName=$(kubectl get pods -l app.kubernetes.io/instance=${deploymentNameAdjusted} --field-selector status.phase=Running --no-headers=true -n ${targetNamespace} 2> /dev/null | awk '{print $1}')
	
    if [[ -z ${runningPodName} ]]
    then
        echo "${cyan}WARN:${cyan} No ${type} pods found running in namespace $targetNamespace for deployment ${deploymentName}."; echo
        return 1
    else		
		echo "Found the following pods running in namespace $targetNamespace:"
		echo "${green}${runningPodName}${reset}"; echo		
        return 0
    fi

}

function wait_pod_complete() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local type="$3"
    local runningPodName="$4"

    [ "${dryRunOption}" != "true" ] && [ $(sleep $podStartTimeout) ]
    local podFindResult=0

    if [ -z "${runningPodName}" ]
    then
        echo "$(now) Waiting ${type} pod to be ready for deployment ${deploymentName} in namespace ${targetNamespace}."
        if [ "${dryRunOption}" != "true" ]
        then
            find_running_pod "${deploymentName}" "${targetNamespace}" "${type}"
        fi
        podFindResult=$?
        if [ $podFindResult -eq 0 ]
        then
            echo "Found ${green}${runningPodName}${reset} pod running."
        else
            echo "${red}ERROR:${reset} Running pod not found for ${deploymentName}!"
            exit 1
         fi
     fi

     if [ $? -eq 0 ] && [ "${dryRunOption}" != "true" ]
     then
         echo "$(now) Waiting for ${runningPodName} to complete..."
         executeCmd  "kubectl get pods -n $targetNamespace --field-selector status.phase=Succeeded | grep -q ${runningPodName}"
         found=$?
         while [[ $found -eq 1 ]]
         do
             kubectl get pods -n $targetNamespace --field-selector status.phase=Failed | grep -q "${runningPodName}"
             if [ $? -eq 0 ]
             then
                 echo
                 echo "${red}ERROR:${reset} Pod ${runningPodName} failed!"
                 echo
                 exit 1
             else
                 printf "."
                 sleep 5
                 kubectl get pods -n $targetNamespace --field-selector status.phase=Succeeded | grep -q "${runningPodName}"
                 found=$?
             fi
         done
         echo;
         echo "$(now) ${runningPodName} pod completed in namespace ${targetNamespace}."
         echo
     fi

}
function wait_pod_ready() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local type="$3"
    local waitTimeout="$4"

    [ "${dryRunOption}" != "true" ] && [ $(sleep $podStartTimeout) ]
    echo "$(now) Waiting ${type} pods to be ready for deployment ${deploymentName} in namespace ${targetNamespace}."

    if [ "${dryRunOption}" != "true" ]
    then
        find_running_pod "${deploymentName}" "${targetNamespace}" "${type}"
    fi
    local podFindResult=$?


    if [ $podFindResult -eq 0 ]
    then
		
		echo "Following pods are running:"
		echo "${green}${runningPodName}${reset}"		
		echo "Waiting ${waitTimeout} for pods to be Ready ..."
		
		if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
		then
			local deploymentNameAdjusted="${deploymentName}-rafm"
		else
			local deploymentNameAdjusted="${deploymentName}"
		fi
			
		executeCmd "kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=${deploymentNameAdjusted},'!job-name' -n ${targetNamespace} --timeout=${waitTimeout}"		
        if [ $? -gt 0 ]
        then
            echo "${red}ERROR:${reset} Timeout ${waitTimeout} expired and pods are not Ready for deployment '${deploymentName}' in namespace '${targetNamespace}'!"
            exit 1
        fi
    else
        echo "${red}ERROR:${reset} Running pods not found for ${deploymentName}!"
        exit 1
    fi

}

function delete_secret() {
    local targetNamespace="$1"
    local secretName="$2"

    echo "$(now) Deleting license secret: ${secretName} in namespace ${targetNamespace}"
    executeCmd "kubectl -n ${targetNamespace} delete secret ${secretName}  --ignore-not-found"
}

function scale_down() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local type="$3"

    echo "Scaling down  ${targetNamespace} \ ${deploymentName}..."

    find_running_pod "${deploymentName}" "${targetNamespace}" "${type}"
    local podFindResult=$?

    if [ $podFindResult -eq 0 ]
    then
		
		echo "Following pods are running:"
		echo "${green}${runningPodName}${reset}"		
		echo "Going to scale down."
				
        if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
        then
            local deploymentNameAdjusted="${deploymentName}-rafm"
        else
            local deploymentNameAdjusted="${deploymentName}"
        fi

        if $(kubectl get deploy ${deploymentNameAdjusted} -n ${targetNamespace} > /dev/null 2>&1)
        then
            executeCmd "kubectl scale --replicas=0 deployment ${deploymentNameAdjusted} -n ${targetNamespace}"
        elif $(kubectl get statefulset ${deploymentNameAdjusted} -n ${targetNamespace} > /dev/null 2>&1)
        then
            executeCmd "kubectl scale --replicas=0 statefulset ${deploymentNameAdjusted} -n ${targetNamespace}"
        elif [ "${dryRunOption}" != "true" ]
        then
            echo "${red}ERROR:${reset} ${deploymentNameAdjusted} not found as either deploymet or statefulset!"
            exit 1
        fi

        if [ $? -eq 0 ] && [ "${dryRunOption}" != "true" ]
        then

            echo "$(now) Waiting for pods to stop in namespace ${targetNamespace} for deployment ${deploymentName}..."
			echo "${green}${runningPodName}${reset}"; echo	

			sleep $podStartTimeout
            while [[ $(kubectl get pods -l app.kubernetes.io/instance=${deploymentNameAdjusted},'!job-name' -n ${targetNamespace} 2> /dev/null) != "" ]]
            do
                printf "."
                sleep 2
            done
            echo; echo "$(now) Pods stopped in namespace ${targetNamespace} for deployment ${deploymentName}:"
			echo "${green}${runningPodName}${reset}"
            echo
        fi
    else
        read -p "${cyan}WARN:${reset} Running pod not found for ${deploymentName}! Continue? (Y/N) " -n 1 -r
        echo 

        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi

    fi
}

function scale_up {

    local deploymentName="$1"
    local targetNamespace="$2"
    local type="$3"
	local deploymentReplicas="$4"

    if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
    then
        local deploymentNameAdjusted="${deploymentName}-rafm"
    else
        local deploymentNameAdjusted="${deploymentName}"
    fi

    echo "Scaling up deployment ${deploymentNameAdjusted} in namespace ${targetNamespace}"

    if $(kubectl get deploy ${deploymentNameAdjusted} -n ${targetNamespace} > /dev/null 2>&1)
    then
        executeCmd "kubectl scale --replicas=${deploymentReplicas:-1} deployment ${deploymentNameAdjusted} -n ${targetNamespace}"
    elif $(kubectl get statefulset ${deploymentNameAdjusted} -n ${targetNamespace} > /dev/null 2>&1)
    then
        executeCmd "kubectl scale --replicas=${deploymentReplicas:-1} statefulset ${deploymentNameAdjusted} -n ${targetNamespace}"
    else
        echo "${red}ERROR:${reset} ${deploymentNameAdjusted} not found as either deployment or statefulset!"
        exit 1
    fi

    wait_pod_ready "$deploymentName" "$targetNamespace" "$type" "1800s"

    echo

}

function helm_uninstall() {

    local deploymentName="$1"
    local targetNamespace="$2"

    echo "----"
    echo "$(now) Running helm uninstall."

    local uninstallStartSec=$(date +%s)

    echo "Uninstalling ${deploymentName}..."
    executeCmd "helm uninstall "${deploymentName}" -n "${targetNamespace}" --timeout 10m --wait"

    error_code=$?

    local uninstallEndSec=$(date +%s)
    local durationSec=$(( ${uninstallEndSec} - ${uninstallStartSec} ))
    local duration=$(date +%H:%M:%S -ud @${durationSec})

    echo "----"
    if [ $error_code -ne 0 ]
    then

        echo "${cyan}WARN:${reset} Helm uninstall failed for ${deploymentName} after ${duration} with error $error_code!"
        echo
    else
        echo "$(now) helm uninstall ended for ${deploymentName}. Duration: ${duration}" 
        echo
    fi
}

function delete_k8s_resources() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local type="$3"
    local exclude="$4"
    local productSecrets="$5"

    if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
    then
        local resourcePattern="${deploymentName}-rafm-"
    else
        local resourcePattern="${deploymentName}-"
    fi

    if [ -z "${exclude}" ]
    then
        echo "Deleting pod's and services named *${resourcePattern}*"
        executeCmd "kubectl -n ${targetNamespace} get all,cm,secret | grep "${resourcePattern}" | awk '{print \$1}' | xargs -i kubectl -n ${targetNamespace} delete {}"
    else
        echo "Deleting pod's and services  named *${resourcePattern}* except ${exclude}"
        executeCmd "kubectl -n ${targetNamespace} get all,cm,secret | grep "${resourcePattern}" | grep -v "${exclude}" | awk '{print \$1}' | xargs -i kubectl -n ${targetNamespace} delete {}"
    fi

    if [ ! -z "${productSecrets}" ]
    then
        echo "Deleting secrets ${productSecrets}"
        executeCmd "kubectl -n ${targetNamespace} delete secret ${productSecrets}"
    fi

    if [ ! "${type}" == "portal" ]
    then
        echo "Deleting PVC associated with the ${deploymentName} deployment"
        executeCmd "kubectl -n ${targetNamespace} get pvc | grep ${resourcePattern} | awk '{print \$1}' | xargs -i kubectl -n ${targetNamespace} delete pvc {}"
    fi

}

function delete_pv() {

    local deploymentName="$1"
    local targetNamespace="$2"
    local target="$3"

    if [ "${target}" == "instance" ]
    then
        local resourcePrefix="${deploymentName}-rafm"
    else
        local resourcePrefix="data-${deploymentName}"
    fi

    echo "$(now) Looking for persistent volumes having claim name like '${resourcePrefix}' and Released."

    kubectl get persistentvolume -o custom-columns=":spec.claimRef.name,:spec.claimRef.namespace,:status.phase,:metadata.name" | \
        awk -F" " '
            ($1 ~ "^'${resourcePrefix}'" && $2 == "'${targetNamespace}'" && $3 == "Released") {print $4}' | while read pv
    do
        echo "Going to delete persistentvolume $pv"
        executeCmd "kubectl delete persistentvolume ${pv}"
    done
}

function notify_manual_db_clean_user_role_schema() {

    local deploymentName="$1"
    local productConfigFile="$2"

    eval $(parse_xml "${productConfigFile}" "")

    echo
    echo
    echo "Please login in the Database with the DBA user and execute the following script:

    --------------------------------------------------
    drop schema \"${DbUsersDatUser}\" cascade;
    drop schema \"${DbUsersAdmUser}\" cascade;
    drop schema \"${DbUsersAppUser}\" cascade;

    DROP ROLE \"${DbUsersDatUser}_SysPriv\";
    DROP ROLE \"${DbRolesDATReadAndWrite}\";
    DROP ROLE \"${DbRolesDATReadOnly}\";
    DROP ROLE \"${DbUsersAppUser}_SysPriv\";
    DROP ROLE \"${DbRolesReadAndWrite}\";
    DROP ROLE \"${DbRolesReadOnly}\";
    DROP ROLE \"${DbUsersAdmUser}_SysPriv\";

    DROP ROLE \"${DbUsersDatUser}\";
    DROP ROLE \"${DbUsersAdmUser}\";
    DROP ROLE \"${DbUsersAppUser}\";
    --------------------------------------------------"
    echo
    echo

}

function create_bitnami_pg_db() {

    local pgDeploymentName="$1"
    local pgNamespace="$2"
    local pgPassword="$3"
    local pgDatabase="$4"
    local pgPort="$5"
    local pgVersion="$6"
    local pgBitnamiSettingsFile="$7"

    echo "Adding bitnami repository..."
    executeCmd "helm repo add bitnami https://charts.bitnami.com/bitnami"

    cat << EOF > ${pgDeploymentName}-settings.yaml

global:
  postgresql:
    auth:
      postgresPassword: ${pgPassword}
      database: ${pgDatabase}
    service:
      ports:
        postgresql: ${pgPort}

EOF


    echo "Deploying ${pgDeploymentName}..."

    executeCmd "helm install ${pgDeploymentName} bitnami/postgresql ${pgVersion} -n ${pgNamespace} -f ${pgDeploymentName}-settings.yaml $(if [ ! -z "${pgBitnamiSettingsFile}" ]; then echo " -f ${riskManagementPackagesDir}/${pgBitnamiSettingsFile}"; fi)"

    rm ${pgDeploymentName}-settings.yaml

    wait_pod_ready ${pgDeploymentName} ${pgNamespace} "pg" "120s"

}

function create_bitnami_pg_part() {

    local pgDeploymentName="$1"
    local pgNamespace="$2"
    local pgPassword="$3"
    local pgDatabase="$4"
    local pgPort="$5"
    local pgBitnamiSettingsFile="$6"
    local pgTablespaceName="$7"

    local pgTablespaceDirectory=/bitnami/postgresql/data/${pgTablespaceName}
    # Not included in settings.yaml file because this will always be the postgres user.
    local pgUser=postgres
    local pgPod=${pgDeploymentName}-0


    if [ "${dryRunOption}" != "true" ]
    then
        kubectl exec ${pgPod} --namespace ${pgNamespace} -- ls -d ${pgTablespaceDirectory} > /dev/null 2>&1
    fi
    if [ $? -gt 0 ]
    then
        echo "Creating diretory ${pgTablespaceDirectory} on ${pgNamespace}\\${pgPod}..."
        executeCmd "kubectl exec ${pgPod} --namespace ${pgNamespace} -- mkdir ${pgTablespaceDirectory}"
    fi

    echo "Creating tablespace ${pgTablespaceName} on ${pgTablespaceDirectory}..."

    local pgClientPodName="ipostgresql-client-`date +"%Y%m%d%H%M%S"`"
    local createTablespaceCommand="\"create tablespace ${pgTablespaceName} location '${pgTablespaceDirectory}';\""

    executeCmd "kubectl run "${pgClientPodName}" --restart=Never --namespace ${pgNamespace}  --image docker.io/bitnami/postgresql:14.5.0-debian-11-r3 --env="PGPASSWORD=$pgPassword" $(if [ ! -z "${pgBitnamiSettingsFile}" ]; then echo " -f ${riskManagementPackagesDir}/${pgBitnamiSettingsFile}"; fi) -- psql --host ${pgDeploymentName} -U ${pgUser} -d "${pgDatabase}" -p "${pgPort}" -c ${createTablespaceCommand}"
	
	
  wait_pod_complete "" $pgNamespace "" $pgClientPodName
}

function create_k8s_service() {

    local targetDeployment="$1"
    local targetNamespace="$2"
    local type="$3"
    local serviceTypeAbrev="$4"
    local database="$5"
    local externalPort="$6"
    local targetPort="$7"
    local serviceName=""

    if [ "${serviceTypeAbrev}" == "np" ]
    then
        local serviceType="NodePort"
    else
        local serviceType="LoadBalancer"
    fi

	local serviceName=${targetDeployment}-${serviceTypeAbrev}
 
	if [ "${databaseOption}" == "false" ]
    then	
		local targetPort=$(kubectl get svc --namespace ${targetNamespace} ${targetDeployment} -o jsonpath="{.spec.ports[0].targetPort}")
		
		if ! [[ "${targetPort}" =~ ^[0-9]+$ ]]
		then
			local targetPort=$(kubectl get svc --namespace ${targetNamespace} ${targetDeployment} -o jsonpath="{.spec.ports[0].port}")
		fi
	fi
			
	
	if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ] || [ "${databaseOption}" == "true" ]
	then
	
		if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ]
		then
			local masterPodName="${targetDeployment}-rafm-0"
		fi
		if [ "${databaseOption}" == "true" ]
		then
			local masterPodName="${targetDeployment}-0"		
		fi

		echo "Looking for running pod ${masterPodName} for deployment ${targetDeployment} in namespace ${targetNamespace}."

		local runningMasterPod=$(kubectl get pod -l statefulset.kubernetes.io/pod-name=${masterPodName} --field-selector status.phase=Running --no-headers=true -n ${targetNamespace} 2> /dev/null | awk '{print $1}')

		if [ -z ${runningMasterPod} ] 
		then 		
			echo "${red}ERROR:${reset} Pod ${masterPodName} was not found running for deployment ${targetDeployment}!"
			exit 1
			
		else

			echo "Going to create now ${serviceType} Service for deployment ${targetDeployment} in pod ${runningMasterPod}!"
			echo "$(now) ${green}INFO${reset}: Going to create ${bold}${serviceType}${reset} service for ${bold}${targetDeployment}${reset} targetPort:externalPort = ${bold}${targetPort}:${externalPort}${reset}. Service name: ${bold}${serviceName}${reset}"
		
			overrideText="{\\
				\\\"apiVersion\\\": \\\"v1\\\",\\
					\\\"spec\\\":\\
					{\\\"ports\\\": \\
						[{\\\"port\\\":${targetPort},\\
						\\\"protocol\\\":\\\"TCP\\\",\\
						\\\"targetPort\\\":${targetPort},\\
						\\\"nodePort\\\":${externalPort}\\
						}]\\
					}\\
				}"		

			executeCmd "kubectl expose pod ${runningMasterPod} --type=${serviceType} --port=${targetPort} --name ${serviceName} --namespace ${targetNamespace} --overrides \"${overrideText}\""
		fi
		
	else

		echo "Looking for running pods for deployment ${targetDeployment} in namespace ${targetNamespace}."

		local runningPods=$(kubectl get pods -l app.kubernetes.io/instance=${targetDeployment},'!job-name' --field-selector status.phase=Running --no-headers=true -n ${targetNamespace} 2> /dev/null | awk '{print $1}')

		if [[ -z ${runningPods} ]] 
		then 		
			echo "${red}ERROR:${reset} No pods found running for deployment ${targetDeployment}!"
			exit 1
			
		else
	
			echo "Going to create now ${serviceType} Service for deployment ${targetDeployment}!"
			echo "$(now) ${green}INFO${reset}: Going to create ${bold}${serviceType}${reset} service for ${bold}${targetDeployment}${reset} targetPort:externalPort = ${bold}${targetPort}:${externalPort}${reset}. Service name: ${bold}${serviceName}${reset}"
		
			overrideText="{\\
				\\\"apiVersion\\\": \\\"v1\\\",\\
					\\\"spec\\\":\\
					{\\\"ports\\\": \\
						[{\\\"port\\\":${targetPort},\\
						\\\"protocol\\\":\\\"TCP\\\",\\
						\\\"targetPort\\\":${targetPort},\\
						\\\"nodePort\\\":${externalPort}\\
						}]\\
					}\\
				}"		
	
			executeCmd "kubectl expose deployment ${targetDeployment} --type=${serviceType} --port=${targetPort} --name ${serviceName} --namespace ${targetNamespace} --overrides \"${overrideText}\""	
	
		fi
	
	fi

    if [ $? -ne 0 ]
    then
        echo
        echo "${red}ERROR:${reset} Error creating ${serviceType} service for deployment ${targetDeployment} in namespace ${targetNamespace}."
        echo
    else
        echo "$(now) ${green}INFO${reset}: Created ${bold}${serviceType}${reset} service for ${bold}${targetDeployment}${reset} targetPort:externalPort = ${bold}${targetPort}:${externalPort}${reset}. Service name: ${bold}${serviceName}${reset}"

		if [ "${type}" == "rafm" ] || [ "${type}" == "rafm-satellite" ] || [ "${databaseOption}" == "true" ]
		then		
			local podNode=`kubectl get pod -n ${targetNamespace} ${runningMasterPod} -o jsonpath="{.spec.nodeName}"`
		else
			local podNode=`kubectl -n ${targetNamespace} get pods -l app.kubernetes.io/instance=${targetDeployment},'!job-name' -o jsonpath="{.items[0].spec.nodeName}"`
		fi
		
        local podNodeIP=`kubectl get node ${podNode} -o jsonpath="{.status.addresses[0].address}"`

        if [ "${serviceType}" == "LoadBalancer" ]
        then
            local lbIP=$(kubectl get service -n ${targetNamespace} ${serviceName} -o jsonpath="{.status.loadBalancer.ingress[0].ip}")
            if [ -z "${lbIP}" ]
            then
                echo "${yellow}WARNING${reset}: No EXTERNAL-IP found for service ${serviceName}. Check if Load Balancer service is running or use NodePort service instead."
            fi
        fi

        echo "For ssh session Port Forwarding use: "
        echo "         ${podNodeIP}:${externalPort}"
    fi
function create_k8s_service_headless() {

    local targetDeployment="$1"
    local targetNamespace="$2"
    local headless="$3"

    datetime=`date +"%Y%m%d%H%M%S"`
    file_orig_svc="svc_${targetDeployment}_${datetime}.yaml"
    file_new_svc="svc_${targetDeployment}${headless}_${datetime}.yaml"

    kubectl get service -n ${targetNamespace} ${targetDeployment} -o yaml > "$file_orig_svc"
    
    clusterIp=$(cat "$file_orig_svc" | grep clusterIP | head -1 | sed "s/.* \([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)/\1/")
    echo "${green}INFO${reset}: Found cluster IP: $clusterIp. Setting to \"None\" for new ${targetDeployment}${headless} headless service."

    cat "$file_orig_svc" | sed "s/${clusterIp}/None/g" | sed "s/name: ${targetDeployment}/name: ${targetDeployment}${headless}/g" > "$file_new_svc"

    kubectl apply -f "$file_new_svc"

    if [ $? -eq 0 ]
    then
        rm "$file_new_svc"
        rm "$file_orig_svc"
    else
        echo
        echo "${red}ERROR:${reset} Error creating headless service ${targetDeployment}${headless} in namespace ${targetNamespace}. Check for possible issues in file ${file_new_svc} "
        echo
    fi

}

}

function create_port_forward() {

    local targetDeployment="$1"
    local targetNamespace="$2"
    local type="$3"
    local externalPort="$4"
    local targetPort="$5"

    if [ "${databaseOption}" == "false" ]
    then

        find_running_pod "${targetDeployment}" "${targetNamespace}" "${type}"
        # sets runningPodName with pod name
        targetPort=$(kubectl get svc --namespace ${targetNamespace} ${targetDeployment} -o jsonpath="{.spec.ports[0].targetPort}")
		
		if ! [[ "${targetPort}" =~ ^[0-9]+$ ]]
		then
			targetPort=$(kubectl get svc --namespace ${targetNamespace} ${targetDeployment} -o jsonpath="{.spec.ports[0].port}")
		fi
    fi
    if [ ! -z "$targetPort" ]
    then
        cat /dev/null > nohup.out
        executeCmd "nohup kubectl port-forward service/${targetDeployment} ${externalPort}:${targetPort} --namespace ${targetNamespace} &"
        pfPID=$!

        echo "${green}INFO${reset}: k8s port-forward running with pid $pfPID"
        cat nohup.out
        echo "For ssh session Port Forwarding use: "
        echo "         localhost:${externalPort}"
    fi
}

function parse_xml_2array() {
    local xmlFile="$1"
    cat "${xmlFile}" | grep -v -e "<\!--.*-->" | grep -v -e "^[[:space:]]*$" | awk -F'[<>]' '
    {
        if ( $3 != "" ) {
            parameter=gensub(".*\"(.+)\"","\\1","g",$2);
            value=gensub("\"", "\\\\\"","g",$3)
            value=gensub(" ", "","g",value)
            print "\"\"" parameter "\"§\"" value "\"\""
        }
    }'
}

function parse_xml() {
    local xmlFile="$1"
    local prefix="$2"
    cat "${xmlFile}" | grep -v -e "^[[:space:]]*<\!--.*-->" | grep -v -e "^[[:space:]]*$" | awk -F'[<>]' '
    {
        if ( $3 != "" ) {
            parameter=gensub(".*\"(.+)\"","\\1","g",$2);
            value=gensub("\"", "\\\\\"","g",$3)
            value=gensub("{", "\\\\{","g",value)
            value=gensub("}", "\\\\}","g",value)
            print "local '${prefix}'" parameter "=\"" value "\""
        }
    }'
}

function audit_value() {

    local varName="$1"
    local expectedValue="$2"
    local alternative="$3"
    local alternative2="$4"

    local value="${!varName}"

    if [ -z "${value}" ]
    then


        if [ -z "$expectedValue" ] ||  [ -z "$alternative" ]
        then
            echo "   ${green}OK${reset}: $varName not found as expected"
        else
            echo
            echo "   ${red}VALUE AUDIT FAIL:${reset} no value found for ${bold}${varName}${reset}"

            echo "   Expected '$expectedValue' $([ ! -z $alternative ] && echo "or '$alternative' ") $([ ! -z $alternative2 ] && echo "or '$alternative2' ")"
													 
				
																		 
					
			  
        fi

    elif [ "${value}" != "${expectedValue}" ]
    then

        if [ ! -z "$alternative" ]
        then
            if [ "${value}" != "${alternative}" ]
            then
                
                if [ ! -z "$alternative2" ]
                then
                        if [ "${value}" != "${alternative2}" ]
                        then
                                echo
                                echo "   ${red}VALUE AUDIT FAIL:${reset} for ${bold}${varName}${reset}!"
                                echo "   Expected '$expectedValue' $([ ! -z $alternative ] && echo "or '$alternative' ") $([ ! -z $alternative2 ] && echo "or '$alternative2' ")"
                                echo "   Found:   '$value'"
                                echo
                        else
                            echo "   ${green}OK${reset}: $varName=${value}"
                        fi
                else
                        echo
                        echo "   ${red}VALUE AUDIT FAIL:${reset} for ${bold}${varName}${reset}!"
                        echo "   Expected '${expectedValue}' or '${alternative}'"
                        echo "   Found:   '$value'"
                        echo
                fi
            else
                echo "   ${green}OK${reset}: $varName=${value}"
            fi
        else
            echo
            echo "   ${red}VALUE AUDIT FAIL:${reset} for ${bold}${varName}${reset}!"
            echo "   Expected '${expectedValue}'"
            echo "   Found:   '$value'"
            echo
        fi
    else
        echo "   ${green}OK${reset}: $varName=${expectedValue}"
    fi

}
function audit_product_config_vs_aip_settings() {

    local productConfigFile="$1"

    echo
    echo "$(now) - Going to audit product config file to identify potential inconsistencies with aip install settings."
    echo "Product config file: $productConfigFile"
    echo

    eval $(parse_xml "${productConfigFile}" "")

    audit_value DbRdbms "Postgresql"

    if [ "${pgCreateDatabase}" == "true" ] || [ -z "${pgHost}" ]
    then
        audit_value DbHost "${pgDeploymentName}"
        if [ "$productNamespace" == "$pgNamespace" ]
        then
            audit_value DbJdbcUrl "jdbc:postgresql://${pgDeploymentName}:${pgPort}/${pgDatabase}" "jdbc:postgresql://${pgDeploymentName}.${pgNamespace}.svc.cluster.local:${pgPort}/${pgDatabase}"
        else
            audit_value DbJdbcUrl "jdbc:postgresql://${pgDeploymentName}.${pgNamespace}.svc.cluster.local:${pgPort}/${pgDatabase}"
        fi
    else
        audit_value DbHost "${pgHost}"
        audit_value DbJdbcUrl "jdbc:postgresql://${pgHost}:${pgPort}/${pgDatabase}"
    fi
    audit_value DbPort "${pgPort}"
    audit_value DbDatabase "${pgDatabase}"
    audit_value DbUsersDbaUser "${pgUsername}"

    if [ "$type" == "rafm" ] || [ "$type" == "rafm-satellite" ]
    then
        audit_value ServerHost "${deploymentName}.${productNamespace}.svc.cluster.local"
        audit_value PathToMainRafm "/opt/server"
        audit_value PathToInstance "/opt/server/instances/${deploymentName}"
        audit_value EventHubInternalBrokerDirectory "/shared/${deploymentName}/activemq"
        audit_value InstanceName "${deploymentName}"
        audit_value RaidrasInstanceName "${deploymentName}"
        if [ "${pgCreateDatabase}" == "true" ] || [ -z "${pgHost}" ]
        then
            if [ "$productNamespace" == "$portalPgNamespace" ]
            then
                audit_value PortalDbJdbcUrl "jdbc:postgresql://${portalPgDeploymentName}:${portalPgPort}/${portalPgDatabase}" "jdbc:postgresql://${portalPgDeploymentName}.${portalPgNamespace}.svc.cluster.local:${portalPgPort}/${portalPgDatabase}"
            else
                audit_value PortalDbJdbcUrl "jdbc:postgresql://${portalPgDeploymentName}.${portalPgNamespace}.svc.cluster.local:${portalPgPort}/${portalPgDatabase}"
            fi
        else
            audit_value PortalDbJdbcUrl "jdbc:postgresql://${portalPgHost}:${portalPgPort}/${portalPgDatabase}"
        fi
        if [ "$type" == "rafm-satellite" ]
        then
            audit_value Satellite "true"
        else
            audit_value DbRolesDATReadOnly "${DbUsersDatUser}_S"
            audit_value DbRolesDATReadAndWrite "${DbUsersDatUser}_SIUD"
            audit_value DbRolesReadOnly "${DbUsersAdmUser}_S"
            audit_value DbRolesReadAndWrite "${DbUsersAdmUser}_SIUD"
            audit_value Satellite "false" ""
        fi
    elif [ "$type" == "portal" ]
    then

        if [ "${pgCreateDatabase}" == "true" ]
        then
            if [ "$productNamespace" == "$pgNamespace" ]
            then
                audit_value PortalDbJdbcUrl "jdbc:postgresql://${pgDeploymentName}:${pgPort}/${pgDatabase}" "jdbc:postgresql://${pgDeploymentName}.${pgNamespace}.svc.cluster.local:${pgPort}/${pgDatabase}"
            else
                audit_value PortalDbJdbcUrl "jdbc:postgresql://${pgDeploymentName}.${pgNamespace}.svc.cluster.local:${pgPort}/${pgDatabase}"
            fi
        fi
        audit_value InstanceType "Portal"
        audit_value PORTAL_INSTANCE_NAME "${PORTAL_INSTANCE_NAME}" "${deploymentName}"
        audit_value PathToMainPortal "/opt/server"
        audit_value PathToPortalInstance "/opt/server/instances/${deploymentName}"
        audit_value WebServerHost "$\{env.DEPLOYMENT_NAME\}" "${deploymentName}"
    fi

    echo
    echo "Check any audit failures and apply any required fixes before proceeding."

}

function audit_storage_class() {

    pvStorageClass="$1"

    #executeCmd "kubectl get storageclasses ${pvStorageClass}"
    if [ $? -eq 0 ]
    then
        echo
        echo "${green}OK:${reset} Storage Class ${pvStorageClass} is available in cluster."
    else
        echo "${red}ERROR:${reset} Storage Class \"${pvStorageClass}\" not found in cluster."
        exit 1
    fi

}

function list_available_deployments()
{
	local riskManagementPackagesDir="${1}"
	local product="${2}"
	
	local error_count=0
	
	local arr=($(find "${riskManagementPackagesDir}" -type f -wholename "${riskManagementPackagesDir}"/${product}/aip_settings/${product}-settings.yaml  | \
	awk -F\/ 'BEGIN{OFS=";"}{ print "MAIN_SERVER",$NF,$0}'))
	
	arr+=($(find "${riskManagementPackagesDir}" -type d -regex "^${riskManagementPackagesDir}/${product}/aip_settings/\(sat[0-9]+\|presentation\)$" | \
	awk -F\/ '{print $NF}' | sort -V | \
	xargs -I '{}' find "${riskManagementPackagesDir}"/${product}/aip_settings/'{}' -type f -name ${product}-'{}'-override-settings.yaml | \
	awk -F\/ 'BEGIN{OFS=";"}{ print $(NF-1),$NF,$0}'))

	local i=""
	local lines_t=""

	for i in ${arr[@]}
	do
		local satid=$(echo "${i}" | awk -F\; '{print  $1}')
		local fname=$(echo "${i}" | awk -F\; '{print  $2}')
		local fpath=$(echo "${i}" | awk -F\; '{print  $3}')
		
		eval $(parse_yaml "${fpath}" ""${satid}"_")
		get_yaml_setting "${satid}"_deploymentName	"${satid}"_deployment_name $error_count 1> /dev/null
		
		local satDeploymentName="${satid}_deploymentName"
		
		if [ $error_count -gt 0 ]
		then
			error_count=0
		else
			lines_t+="${satid} | ${!satDeploymentName} | ${fname}\n"
		fi

	done

	if [ "${#lines_t}" -gt 0 ]
	then
	
		local header_t=" Satellite_ID | Deployment_Name | Settings_File\n"
		local separator_t=" ------------ | --------------- | -------------\n"
		
		echo
		echo "Available deployments for ${product}:"
		echo
		echo -e "${header_t}${separator_t}${lines_t}${separator_t}" | column -t
		
	else
	
		echo
		echo "No available deployments found for ${product}."
	
	fi
}
