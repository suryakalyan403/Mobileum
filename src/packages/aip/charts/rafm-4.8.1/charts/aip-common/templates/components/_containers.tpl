{{/*
Standard environment variables used on all containers
*/}}
{{- define "aip.env.standard" -}}
- name: TZ
  value: {{ .Values.timezone | default "UTC" | quote }}
  {{- $global := .Values.global | default dict -}}
  {{- if $global.envs }}
  # render global envs
{{ printf "%s" (include "aip.env.renderer" (dict "value" $global.envs "context" $)) }}
  {{- end }}
{{- end -}}

{{/*
Resources requests to each container
*/}}
{{- define "aip.resources.requests" -}}
  {{- $context := .context | default $ -}}
  {{- $default := $context.Values.resources | default dict -}}
  {{- $resources := .resources | default $default -}}
  {{- $requests := $resources.requests | default $default.requests | default dict -}}
  {{- $limits := $resources.limits | default $default.limits | default dict -}}
requests: {{- include "aip.renderer" (dict "value" $requests "context" $context) | nindent 2 }}
limits: {{- include "aip.renderer" (dict "value" $limits "context" $context) | nindent 2 }}
{{- end -}}
