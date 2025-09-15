{{/*
Common annotations shared across objects
*/}}

{{- define "aip.annotations.basic" -}}
app.aip/owner: "AIP_Active-Intelligence-Platform"
{{- end -}}

{{- define "aip.annotations.standard" -}}
  {{- $context := .context | default $ -}}
app.aip/deployment-time: {{ now | date "2006-01-02T15:04:05-0700" | quote}}
app.aip/deployment-epoch: {{ now | unixEpoch | quote}}
app.aip/owner: "AIP_Active-Intelligence-Platform"
  {{- if $context.Release.IsInstall }}
app.aip/operation: "Install"
  {{- else if $context.Release.IsUpgrade }}
app.aip/operation: "Upgrade or Rollback"
  {{- end }}
app.aip/revision: {{ $context.Release.Revision | quote }}
  {{- $global := $context.Values.global | default dict -}}
  {{- if $global.annotations }}
{{ printf "%s" (include "aip.renderer" (dict "value" $global.annotations "context" $context)) }}
  {{- end }}
{{- end -}}
