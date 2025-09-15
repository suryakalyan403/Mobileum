{{/*
Expand the name of the chart that can be overritten by "name" property on values
*/}}
{{- define "aip.names.name" -}}
  {{- $context := .context | default $ -}}
  {{- $global := $context.Values.global | default dict -}}
  {{- default $context.Chart.Name $global.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aip.names.chart" -}}
  {{- $context := .context | default $ -}}
  {{- printf "%s-%s" $context.Chart.Name $context.Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aip.names.fullname" -}}
  {{- $context := .context | default $ -}}
  {{- $global := $context.Values.global | default dict -}}
  {{- if $global.fullname -}}
    {{- $global.fullname | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := include "aip.names.name" . -}}
    {{- if contains $name $context.Release.Name -}}
      {{- $context.Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" $context.Release.Name $name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
