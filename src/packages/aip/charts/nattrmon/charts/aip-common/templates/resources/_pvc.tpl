{{- define "aip.resources.pvc" -}}
  {{- $context := .context | default $ -}}
  {{- $template := .template | default list -}}
  {{- $name := $template.name | default (printf "%s-pvc" (include "aip.names.fullname" (dict "context" $context))) }}
  {{- if or $template.enabled (eq ($template.enabled | toString) "<nil>") }}
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata: {{ include "aip.pvc.metadata" ( dict "name" $name "context" $context "template" $template) | nindent 2 }}
spec: {{ include "aip.pvc.spec" ( dict "context" $context "template" $template) | nindent 2 }}
  {{- end }}
{{- end -}}
