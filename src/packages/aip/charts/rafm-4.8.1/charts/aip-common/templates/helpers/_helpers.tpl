{{- define "aip.names.tolerations" -}}
- key: "node"
  operator: "Equal"
  value: "FMS"
  effect: "NoSchedule"
{{- end }}
~

