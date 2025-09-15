# rafm

RAFM backend product

## Requirements

Kubernetes: `>=1.16.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://162015117822.dkr.ecr.eu-west-1.amazonaws.com/aip-charts | aip-common | 0.13.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| automountServiceAccountToken | bool | `false` |  |
| autoscaling.behaviors.enabled | bool | `false` |  |
| autoscaling.behaviors.scaleDown.enabled | bool | `false` |  |
| autoscaling.behaviors.scaleDown.percent.period | int | `60` |  |
| autoscaling.behaviors.scaleDown.percent.value | int | `0` |  |
| autoscaling.behaviors.scaleDown.pods.enabled | bool | `false` |  |
| autoscaling.behaviors.scaleDown.pods.period | int | `60` |  |
| autoscaling.behaviors.scaleDown.pods.value | int | `0` |  |
| autoscaling.behaviors.scaleDown.selectPolicy | string | `"Min"` |  |
| autoscaling.behaviors.scaleDown.stabilizationWindow | int | `300` |  |
| autoscaling.behaviors.scaleUp.enabled | bool | `false` |  |
| autoscaling.behaviors.scaleUp.percent.period | int | `60` |  |
| autoscaling.behaviors.scaleUp.percent.value | int | `0` |  |
| autoscaling.behaviors.scaleUp.pods.enabled | bool | `false` |  |
| autoscaling.behaviors.scaleUp.pods.period | int | `60` |  |
| autoscaling.behaviors.scaleUp.pods.value | int | `0` |  |
| autoscaling.behaviors.scaleUp.selectPolicy | string | `"Min"` |  |
| autoscaling.behaviors.scaleUp.stabilizationWindow | int | `300` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.kind | string | `"StatefulSet"` |  |
| autoscaling.maxReplicas | int | `3` |  |
| autoscaling.metrics.cpuPercent | int | `90` |  |
| autoscaling.metrics.custom | object | `{}` |  |
| autoscaling.metrics.customEnabled | bool | `false` |  |
| autoscaling.metrics.memoryPercent | int | `95` |  |
| autoscaling.minReplicas | int | `1` |  |
| caTrust.configmap | string | `nil` |  |
| caTrust.enabled | bool | `false` |  |
| caTrust.secret | string | `nil` |  |
| cacerts.configmap | string | `""` |  |
| cacerts.keystoreAlias | string | `""` |  |
| cacerts.keystorePassword | string | `""` |  |
| cacerts.secret | string | `""` |  |
| cleanupNodeAffinity | string | `nil` |  |
| cleanupPodAffinity | string | `nil` |  |
| cleanupPodAntiAffinity | string | `nil` |  |
| containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| containerSecurityContext.enabled | bool | `true` |  |
| containerSecurityContext.privileged | bool | `false` |  |
| customJobAnnotations | object | `{}` |  |
| customJobLabels | object | `{}` |  |
| customPodAnnotations | object | `{}` |  |
| customPodLabels | object | `{}` |  |
| dataPersistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| dataPersistence.enabled | bool | `false` |  |
| dataPersistence.existingClaim | string | `nil` |  |
| dataPersistence.size | string | `"1G"` |  |
| dataPersistence.storageClass | string | `nil` |  |
| dataPersistence.volumeName | string | `nil` |  |
| deployment.auditLogLevel | string | `"debug"` |  |
| deployment.base-dir | string | `nil` | Base directory |
| deployment.datamodelLogLevel | string | `"info"` |  |
| deployment.datastoreLogLevel | string | `"info"` |  |
| deployment.domain | string | `nil` |  |
| deployment.ha | bool | `false` |  |
| deployment.hkLogLevel | string | `"debug"` |  |
| deployment.interactive-setup | bool | `false` |  |
| deployment.license.secretName | string | `nil` | The license file secret name |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `120` |  |
| deployment.livenessProbe.periodSeconds | int | `60` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.lmLogLevel | string | `"info"` |  |
| deployment.logLevel | string | `"info"` |  |
| deployment.mode | string | `nil` |  |
| deployment.productConfig.secretName | string | `nil` | The product config secret name |
| deployment.readinessProbe.failureThreshold | int | `5` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `120` |  |
| deployment.readinessProbe.periodSeconds | int | `60` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.timeoutSeconds | int | `30` |  |
| deployment.replicas | int | `1` |  |
| deployment.resources.limits.cpu | string | `"2000m"` |  |
| deployment.resources.limits.memory | string | `"3Gi"` |  |
| deployment.resources.requests.cpu | string | `"100m"` |  |
| deployment.resources.requests.memory | string | `"1Gi"` |  |
| deployment.rootLogLevel | string | `"error"` |  |
| deployment.runLevel | string | `"info"` |  |
| deployment.safeToEvict | bool | `true` |  |
| deployment.smartTransformLogLevel | string | `"info"` |  |
| deployment.upload-target | string | `"portal"` |  |
| deployment.waitOnFailure | bool | `false` |  |
| deployment.waitOnFailureTimeout | string | `"60m"` |  |
| deployment.wpkgLegacyMode | string | `nil` |  |
| deployment.wpkgLogLevel | string | `"debug"` |  |
| deployment.wsLogLevel | string | `"info"` |  |
| deployment.xdtPort | int | `40353` |  |
| hostAliases | string | `nil` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `nil` |  |
| image.repository | string | `"aip/rafm-8.2.10"` |  |
| image.tag | string | `"4.0.0"` |  |
| logPersistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| logPersistence.enabled | bool | `false` |  |
| logPersistence.existingClaim | string | `nil` |  |
| logPersistence.size | string | `"1G"` |  |
| logPersistence.storageClass | string | `nil` |  |
| logPersistence.volumeName | string | `nil` |  |
| nodeAffinity | string | `nil` |  |
| podAffinity | string | `nil` |  |
| podAntiAffinity | string | `nil` |  |
| podDisruptionBudget | bool | `true` |  |
| podSecurityContext.enabled | bool | `false` |  |
| process.resources.limits.cpu | string | `"2000m"` |  |
| process.resources.limits.memory | string | `"6Gi"` |  |
| process.resources.requests.cpu | string | `"100m"` |  |
| process.resources.requests.memory | string | `"1Gi"` |  |
| processImage.pullPolicy | string | `nil` | Pull policy to use or nil to use the main one |
| processImage.registry | string | `nil` | Registry to use or nil to use the main one |
| processImage.repository | string | `nil` | Repository to use or nil to use the main one |
| processImage.tag | string | `nil` | Tag to use or nil to use the main one |
| processNodeAffinity | string | `nil` |  |
| processPodAffinity | string | `nil` |  |
| processPodAntiAffinity | string | `nil` |  |
| pvcInternalManagement | bool | `true` |  |
| registry.host | string | `"registry"` |  |
| registry.port | int | `8080` |  |
| service.ipFamilies[0] | string | `"IPv4"` |  |
| service.ipFamilyPolicy | string | `"SingleStack"` |  |
| service.type | string | `"ClusterIP"` |  |
| service.xdtPort | int | `40353` |  |
| skipSetup | bool | `false` |  |
| storage.azure.accountKey | string | `nil` |  |
| storage.azure.accountName | string | `nil` |  |
| storage.azure.connectionString | string | `nil` |  |
| storage.azure.container | string | `nil` |  |
| storage.gs.service-account.configmapName | string | `nil` |  |
| storage.gs.service-account.secretName | string | `nil` |  |
| storage.hdfs.authentication.kerberos.conf.configmapName | string | `nil` |  |
| storage.hdfs.authentication.kerberos.conf.secretName | string | `nil` |  |
| storage.hdfs.authentication.kerberos.keytab.configmapName | string | `nil` |  |
| storage.hdfs.authentication.kerberos.keytab.secretName | string | `nil` |  |
| storage.hdfs.authentication.kerberos.principal | string | `nil` |  |
| storage.hdfs.authentication.type | string | `nil` |  |
| storage.hdfs.configmapName | string | `nil` |  |
| storage.hdfs.secretName | string | `nil` |  |
| storage.hdfs.user | string | `nil` |  |
| storage.s3.access-key-id | string | `nil` |  |
| storage.s3.credentials-file.configmapName | string | `nil` |  |
| storage.s3.credentials-file.secretName | string | `nil` |  |
| storage.s3.credentials-type | string | `"default"` |  |
| storage.s3.endpoint | string | `"http://s3.amazonaws.com"` |  |
| storage.s3.region | string | `"us-east-1"` |  |
| storage.s3.secret-access-key | string | `nil` |  |
| storage.s3.secretName | string | `nil` |  |
| storage.s3.session-token | string | `nil` |  |
| storage.s3.signatureVersion | string | `"s3v4"` |  |
| storage.type | string | `"local"` |  |
| vault.role | string | `""` |  |
| vault.type | string | `"NONE"` |  |
| vault.url | string | `""` |  |
| volumePermissions.image.pullPolicy | string | `"IfNotPresent"` |  |
| volumePermissions.image.registry | string | `nil` | Registry to use or nil to use the main one |
| volumePermissions.image.repository | string | `"aip/base"` |  |
| volumePermissions.image.tag | string | `"0.5.2"` |  |
| volumePermissions.resources.limits.cpu | string | `"200m"` |  |
| volumePermissions.resources.limits.memory | string | `"128Mi"` |  |
| volumePermissions.resources.requests.cpu | string | `"100m"` |  |
| volumePermissions.resources.requests.memory | string | `"64Mi"` |  |
| volumePermissions.securityContext.runAsUser | int | `0` |  |
