{{/*
Global Service
*/}}
{{- define "aip.service.dualstack" -}}
  {{- $context := .service -}}
  {{- if $context.ipFamilyPolicy }}
ipFamilyPolicy: {{ $context.ipFamilyPolicy | quote }}
  {{- else }}
ipFamilyPolicy: "SingleStack"
  {{- end }}
  {{- if $context.ipFamilies }}
ipFamilies:
    {{- range $context.ipFamilies }}
  - "{{ . }}"
    {{- end }}
  {{- else }}
ipFamilies: ["IPv4"]
  {{- end }}
{{- end -}}
