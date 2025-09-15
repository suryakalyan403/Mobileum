# aip-common

Library for AIP based charts

## Requirements

Kubernetes: `>=1.16.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.behaviors.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleDown.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleDown.percent.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleDown.percent.period | int | `15` |  |
| autoscaling.behaviors.scaleDown.percent.value | int | `100` |  |
| autoscaling.behaviors.scaleDown.pods.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleDown.pods.period | int | `15` |  |
| autoscaling.behaviors.scaleDown.pods.value | int | `4` |  |
| autoscaling.behaviors.scaleDown.selectPolicy | string | `"Max"` |  |
| autoscaling.behaviors.scaleDown.stabilizationWindow | int | `50` |  |
| autoscaling.behaviors.scaleUp.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleUp.percent.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleUp.percent.period | int | `15` |  |
| autoscaling.behaviors.scaleUp.percent.value | int | `100` |  |
| autoscaling.behaviors.scaleUp.pods.enabled | bool | `true` |  |
| autoscaling.behaviors.scaleUp.pods.period | int | `15` |  |
| autoscaling.behaviors.scaleUp.pods.value | int | `4` |  |
| autoscaling.behaviors.scaleUp.selectPolicy | string | `"Max"` |  |
| autoscaling.behaviors.scaleUp.stabilizationWindow | int | `50` |  |
| autoscaling.enabled | bool | `true` |  |
| autoscaling.kind | string | `"Deployment"` |  |
| autoscaling.maxReplicas | int | `6` |  |
| autoscaling.metrics.cpuPercent | int | `70` |  |
| autoscaling.metrics.customEnabled | string | `nil` |  |
| autoscaling.metrics.custom[0].resource.name | string | `"network"` |  |
| autoscaling.metrics.custom[0].resource.targetAverageUtilization | int | `99` |  |
| autoscaling.metrics.custom[0].type | string | `"Resource"` |  |
| autoscaling.metrics.memoryPercent | int | `90` |  |
| autoscaling.minReplicas | int | `3` |  |
| global.annotations | object | `{}` |  |
| global.envs | object | `{}` |  |
| global.fullname | string | `""` |  |
| global.labels | object | `{}` |  |
| global.name | string | `""` |  |
| image.registry | string | `""` |  |
| image.repository | string | `""` |  |
| image.tag | string | `""` |  |
| nodeAffinity.rules[0].expressions[0].key | string | `"myKey"` |  |
| nodeAffinity.rules[0].expressions[0].operator | string | `"myOperator"` |  |
| nodeAffinity.rules[0].expressions[0].values[0] | string | `"a"` |  |
| nodeAffinity.rules[0].expressions[0].values[1] | string | `"b"` |  |
| nodeAffinity.rules[0].weight | int | `1` |  |
| nodeAffinity.terms.expressions[0].key | string | `"myKey"` |  |
| nodeAffinity.terms.expressions[0].operator | string | `"myOperator"` |  |
| nodeAffinity.terms.expressions[0].values[0] | string | `"a"` |  |
| nodeAffinity.terms.expressions[0].values[1] | string | `"b"` |  |
| nodeAffinity.type | string | `"hard"` |  |
| podAffinity.rules[0].expressions[0].key | string | `"myKey"` |  |
| podAffinity.rules[0].expressions[0].operator | string | `"myOperator"` |  |
| podAffinity.rules[0].expressions[0].values[0] | string | `"a"` |  |
| podAffinity.rules[0].expressions[0].values[1] | string | `"b"` |  |
| podAffinity.rules[0].labels.a | string | `"b"` |  |
| podAffinity.rules[0].labels.c | string | `"d"` |  |
| podAffinity.rules[0].weight | int | `1` |  |
| podAffinity.selectors[0].expressions[0].key | string | `"myKey"` |  |
| podAffinity.selectors[0].expressions[0].operator | string | `"myOperator"` |  |
| podAffinity.selectors[0].expressions[0].values[0] | string | `"a"` |  |
| podAffinity.selectors[0].expressions[0].values[1] | string | `"b"` |  |
| podAffinity.selectors[0].labels.a | string | `"b"` |  |
| podAffinity.selectors[0].labels.c | string | `"d"` |  |
| podAffinity.type | string | `"hard"` |  |
| podAntiAffinity.rules[0].expressions[0].key | string | `"myKey"` |  |
| podAntiAffinity.rules[0].expressions[0].operator | string | `"myOperator"` |  |
| podAntiAffinity.rules[0].expressions[0].values[0] | string | `"a"` |  |
| podAntiAffinity.rules[0].expressions[0].values[1] | string | `"b"` |  |
| podAntiAffinity.rules[0].labels.a | string | `"b"` |  |
| podAntiAffinity.rules[0].labels.c | string | `"d"` |  |
| podAntiAffinity.rules[0].weight | int | `1` |  |
| podAntiAffinity.selectors[0].expressions[0].key | string | `"myKey"` |  |
| podAntiAffinity.selectors[0].expressions[0].operator | string | `"myOperator"` |  |
| podAntiAffinity.selectors[0].expressions[0].values[0] | string | `"a"` |  |
| podAntiAffinity.selectors[0].expressions[0].values[1] | string | `"b"` |  |
| podAntiAffinity.selectors[0].labels.a | string | `"b"` |  |
| podAntiAffinity.selectors[0].labels.c | string | `"d"` |  |
| podAntiAffinity.type | string | `"hard"` |  |
| resources.limits.cpu | string | `"500m"` |  |
| resources.limits.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"64Mi"` |  |
| tls.configmap.name | string | `"configmap"` |  |
| tls.enabled | bool | `true` |  |
| tls.secret.name | string | `"secret"` |  |
| tls.secret.path | string | `"/path/to/file.crt"` |  |
