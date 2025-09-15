# nattrmon

AIP Monitoring Metric producer

## Requirements

Kubernetes: `>=1.16.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://162015117822.dkr.ecr.eu-west-1.amazonaws.com/aip-charts | aip-common | 0.13.1 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalCatalogs | object | `{}` |  |
| automountServiceAccountToken | bool | `false` |  |
| caTrust.configmap | string | `nil` |  |
| caTrust.enabled | bool | `false` |  |
| caTrust.secret | string | `nil` |  |
| config.worker_count | int | `1` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.enabled | bool | `true` |  |
| containerSecurityContext.privileged | bool | `false` |  |
| customPodLabels | object | `{}` |  |
| deployment.CHANNEL_WNOTS.enabled | bool | `false` |  |
| deployment.CHANNEL_WNOTS.options.gzip | bool | `true` |  |
| deployment.CHANNEL_WNOTS.options.index | string | `""` |  |
| deployment.CHANNEL_WNOTS.options.multifile | bool | `true` |  |
| deployment.CHANNEL_WNOTS.options.secBucket | string | `""` |  |
| deployment.CHANNEL_WNOTS.options.secFile | string | `""` |  |
| deployment.CHANNEL_WNOTS.options.secKey | string | `""` |  |
| deployment.CHANNEL_WNOTS.type | string | `""` |  |
| deployment.DEBUG | bool | `false` |  |
| deployment.JVM_MEMMSPERC | string | `"50.0"` |  |
| deployment.JVM_MEMMXPERC | string | `"80.0"` |  |
| deployment.LIBS | string | `"s3.js"` |  |
| deployment.NAM_KUBE_RAID | string | `nil` |  |
| deployment.OAF_JARGS | string | `""` |  |
| deployment.PLUGSORDER | string | `"outputs,inputs,validations"` |  |
| deployment.isPortal | bool | `false` |  |
| deployment.port | int | `8090` |  |
| deployment.raidComponentPodName | string | `"^([a-zA-Z0-9]+-)?rafm-[0-9a-zA-Z]+$"` |  |
| hostAliases | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"aip/nattrmon"` |  |
| image.tag | string | `"0.3.4"` |  |
| livenessProbe.failureThreshold | int | `10` |  |
| livenessProbe.initialDelaySeconds | int | `120` |  |
| livenessProbe.path | string | `"/livez"` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| nattrmon.kubeMetrics | bool | `true` |  |
| nattrmon.podExec | bool | `true` |  |
| nodeAffinity | object | `{}` |  |
| podAffinity | object | `{}` |  |
| podAntiAffinity | object | `{}` |  |
| podSecurityContext.enabled | bool | `false` |  |
| readinessProbe.failureThreshold | int | `10` |  |
| readinessProbe.initialDelaySeconds | int | `120` |  |
| readinessProbe.path | string | `"/healthz"` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.timeoutSeconds | int | `30` |  |
| resources.limits.cpu | string | `"4"` |  |
| resources.limits.memory | string | `"2048Mi"` |  |
| resources.requests.cpu | string | `"2"` |  |
| resources.requests.memory | string | `"256Mi"` |  |
| service.ipFamilies[0] | string | `"IPv4"` |  |
| service.ipFamilyPolicy | string | `"SingleStack"` |  |
| service.nodePort | string | `""` |  |
| service.port | int | `8090` |  |
| service.type | string | `"ClusterIP"` |  |
| testAnnotation."helm.sh/hook" | string | `"test-success"` |  |
| testAnnotation."helm.sh/hook-delete-policy" | string | `"hook-succeeded"` |  |
