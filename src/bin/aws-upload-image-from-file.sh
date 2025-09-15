#################################################################################
### Template script to upload an image from a file to an AWS ECR
### Risk Management: 2022-09-13 Initial Version 
#################################################################################

## USAGE
##  set the awsRegionName and awsAccountID and imageLocation then run
##  ./aws-upload-image-from-file.sh rafm-8.2.6 1.1.0
##

export imageLocation=/projects/apps/aip_1.0.4_20220919/AIP_1.0.5/images
export imageName=$1
export imageTag=$2
export awsRegionName=eu-west-1
export awsAccountID=359623030854

cd $imageLocation

docker load -i ${imageName}-${imageTag}.tar.gz

docker tag aip/${imageName}:${imageTag} ${awsAccountID}.dkr.ecr.${awsRegionName}.amazonaws.com/aip/${imageName}:${imageTag}

aws ecr get-login-password --region ${awsRegionName} | docker login --username AWS --password-stdin ${awsAccountID}.dkr.ecr.${awsRegionName}.amazonaws.com

aws ecr describe-repositories --repository-name aip/${imageName} 

if [ ! $? -eq 0 ]
then
aws ecr create-repository --repository-name aip/${imageName}
fi



docker push ${awsAccountID}.dkr.ecr.${awsRegionName}.amazonaws.com/aip/${imageName}:${imageTag}

