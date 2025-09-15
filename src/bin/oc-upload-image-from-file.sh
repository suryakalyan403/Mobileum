#################################################################################
### Template script to upload an image from a file to an OpenShift registry
### Risk Management: 2023-02-16 Initial Version 
#################################################################################

export imageName=$1
export imageTag=$2
export projectName=$3
export imageLocation=/home/mob/aip_1.1.1/packages/aip/images
export osServer=https://image-registry.openshift-image-registry.svc:5000
export osToken=sha256~BayQlE_soUQhRrRElPBtcEgLsctR8nHXNevCgB7xTQo

cd $imageLocation

# login into Openshift cluster
oc login --token=${osToken} --server=${osServer}

# get the Openshift Image Registry host on default-route (change it if other route is being used)
registry_host=$(oc get route default-route -n openshift-image-registry --template='{{.spec.host }}')
echo "Registry host: ${registry_host}"

# docker login into Openshift Image Registry
docker login -u user -p `oc whoami --show-token` $registry_host
echo "Login done!"

# load image from the filesystem into the local docker register
docker load -i ${imageName}-${imageTag}.tar.gz
echo "Image loaded!"

# tag the image with the Openshift Image Registry host and the project name (namespace)
docker tag aip/${imageName}:${imageTag} $registry_host/${projectName}/${imageName}:${imageTag}
echo "Image tagged!"

# upload the image and create a image stream
docker push $registry_host/${projectName}/${imageName}:${imageTag}
echo "Image push result: $?"
