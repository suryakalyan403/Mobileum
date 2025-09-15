# keycloak

A Helm chart for keycloak 1.0

## Requirements

Kubernetes: `>=1.21.0-0`

| Repository | Name | Version |
|------------|------|---------|
| oci://162015117822.dkr.ecr.eu-west-1.amazonaws.com/aip-charts | aip-common | 0.4.3 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| automountServiceAccountToken | bool | `false` |  |
| buildEnvs.JAVA_OPTS | string | `"-XX:InitialRAMPercentage=25.0 -XX:MaxRAMPercentage=90.0"` |  |
| cache.enabled | bool | `true` |  |
| config.contextPath | string | `""` |  |
| config.defaultTheme | string | `""` |  |
| config.keycloak_password | string | `"Password1"` |  |
| config.keycloak_user | string | `"admin"` |  |
| config.log.format | string | `"json"` |  |
| config.log.level | string | `"info"` |  |
| config.log.options | string | `"console,file"` |  |
| config.replica_count | int | `1` |  |
| config.resources.limits.cpu | string | `"500m"` |  |
| config.resources.limits.memory | string | `"2048Mi"` |  |
| config.resources.requests.cpu | string | `"250m"` |  |
| config.resources.requests.memory | string | `"1024Mi"` |  |
| customPodLabels | object | `{}` |  |
| db.database_url | string | `""` |  |
| db.database_vendor | string | `"postgres"` |  |
| db.dbMigration | bool | `false` |  |
| db.db_host | string | `"postgres.default.svc.cluster.local"` |  |
| db.db_name | string | `"postgres"` |  |
| db.db_password | string | `"postgres"` |  |
| db.db_port | string | `"5432"` |  |
| db.db_username | string | `"postgres"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"aip/keycloak"` |  |
| image.tag | string | `"0.4.0"` |  |
| logPersistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| logPersistence.enabled | bool | `true` |  |
| logPersistence.existingClaim | string | `nil` |  |
| logPersistence.size | string | `"1G"` |  |
| logPersistence.storageClass | string | `nil` |  |
| logPersistence.volumeName | string | `nil` |  |
| nodeAffinity | object | `{}` |  |
| podAffinity | object | `{}` |  |
| podAntiAffinity | object | `{}` |  |
| preAnnotation."helm.sh/hook" | string | `"pre-install,pre-upgrade"` |  |
| preAnnotation."helm.sh/hook-delete-policy" | string | `"before-hook-creation"` |  |
| preAnnotation."helm.sh/hook-weight" | string | `"-5"` |  |
| probe.failureThreshold | int | `5` |  |
| probe.initialDelaySeconds | int | `60` |  |
| probe.periodSeconds | int | `30` |  |
| probe.successThreshold | int | `1` |  |
| probe.timeoutSeconds | int | `30` |  |
| rbac.enabled | bool | `true` |  |
| realm | object | `{}` |  |
| realmImport.configmap | string | `""` |  |
| realmImport.secret | string | `""` |  |
| service.annotation | object | `{}` |  |
| service.labels | object | `{}` |  |
| service.nodePort | string | `""` |  |
| service.type | string | `"ClusterIP"` |  |
| testAnnotation."helm.sh/hook" | string | `"test-success"` |  |
| testAnnotation."helm.sh/hook-delete-policy" | string | `"hook-succeeded"` |  |
| tls.enabled | bool | `false` |  |
| tls.selfSigned | bool | `false` |  |
| tls.url | string | `""` |  |
| tls.userDefined.configmap | string | `""` |  |
| tls.userDefined.enabled | bool | `false` |  |
| tls.userDefined.secret | string | `""` |  |
