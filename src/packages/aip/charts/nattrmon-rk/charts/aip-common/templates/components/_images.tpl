{{/*
Return the proper image name
*/}}
{{- define "aip.images.image" -}}
  {{- $global := .global | default dict -}}
  {{- $default := .default | default dict -}}
  {{- $registry := .image.registry | default $default.registry | default $global.registry -}}
  {{- $repository := .image.repository | default $default.repository | default $global.repository -}}
  {{- $tag := .image.tag | default $default.tag | default $global.tag -}}
  {{- if $registry -}}
    {{- printf "%s/%s:%s" $registry $repository $tag -}}
  {{- else -}}
    {{- printf "%s:%s" $repository $tag -}}
  {{- end -}}
{{- end -}}

{{/*
Using image from a private registry
*/}}
{{- define "aip.images.imagePullSecrets" -}}
  {{- $pullSecrets := .pullSecrets | default (list) -}}
  {{- if $pullSecrets -}}
imagePullSecrets:
  {{- range $pullSecrets }}
  - name: {{ . }}
  {{- end }}
  {{- end }}
{{- end }}
