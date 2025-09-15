{{/*
Security Context
*/}}
{{- define "aip.security.context" -}}
  {{- $securityContext := .securityContext -}}
{{- if $securityContext.enabled }}
{{- $_ := unset $securityContext "enabled" }}
{{- $_ := set $securityContext "runAsNonRoot" true }}
{{- $_ := set $securityContext "readOnlyRootFilesystem" true }}
{{- $_ := set $securityContext "privileged" false }}
{{- $_ := set $securityContext "allowPrivilegeEscalation" false }}
{{- $runAsUser := $securityContext.runAsUser -}} 
{{- if eq ($runAsUser | toString) "auto" }}
{{- $_ := unset $securityContext "runAsUser" }}
{{- end }}
{{- $securityContext | toYaml -}}
{{- end }}
{{- end }}




