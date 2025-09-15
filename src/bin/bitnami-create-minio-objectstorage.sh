#################################################################################
### Template script to create a lightweight minio object storage using Bitnami Helm chart
### Risk-Management: 2022-09-13 Initial Version 
#################################################################################

export minioDeploymentName=minio
export minioNamespace=risk-global
export minioUser=adm
export minioPassword=Password1
export minioDefaultBucketToCreate=aipdeployments
export minioApiPort=9000
export minioConsolePort=9001

helm repo add bitnami https://charts.bitnami.com/bitnami

kubectl create namespace ${minioNamespace}

helm install ${minioDeploymentName} bitnami/minio -n ${minioNamespace} \
--set auth.rootUser=${minioUser} \
--set auth.rootPassword=${minioPassword} \
--set defaultBuckets=${minioDefaultBucketToCreate} \
--set service.ports.api=${minioApiPort} \
--set service.ports.console=${minioConsolePort}


cat <<EOF > risk-global-minio-svc.yaml
## service
apiVersion: v1
kind: Service
metadata:
  name: minio-svc
  namespace: risk-global
  labels:
    app: minio-svc
spec:
  type: NodePort
  ports:
    - name: server-port
      port: 9000
      targetPort: 9000
      protocol: TCP
      nodePort: 30090
    - name: console-port
      port: 9001
      targetPort: 9001
      protocol: TCP
      nodePort: 30091
  selector:
   app.kubernetes.io/instance: minio
   app.kubernetes.io/name: minio
EOF

kubectl create -f risk-global-minio-svc.yaml

exit 0