{{/*
Kubernetes recommended labels (https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels)
*/}}
{{- define "aip.labels.standard" -}}
  {{- $context := .context | default $ -}}
  {{- include "aip.labels.matchLabels" (dict "context" $context) -}}
  {{- if $context.Chart.AppVersion }}
app.kubernetes.io/version: {{ $context.Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ $context.Release.Service | quote }}
app.kubernetes.io/part-of: "AIP_Active-Intelligence-Platform"
helm.sh/chart: {{ include "aip.names.chart" (dict "context" $context) }}
  {{- $global := $context.Values.global | default dict -}}
  {{- if $global.labels }}
{{ printf "%s" (include "aip.renderer" (dict "value" $global.labels "context" $context)) }}
  {{- end }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "aip.labels.matchLabels" -}}
  {{- $context := .context | default $ -}}
app.kubernetes.io/name: {{ include "aip.names.name" (dict "context" $context) }}
app.kubernetes.io/instance: {{ include "aip.names.fullname" (dict "context" $context) }}
{{- end -}}
