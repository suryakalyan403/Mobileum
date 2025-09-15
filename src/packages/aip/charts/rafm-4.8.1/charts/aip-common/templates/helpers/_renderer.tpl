
{{/*
Renders a value that contains template.
*/}}
{{- define "aip.renderer" -}}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}

{{/*
Renders environment variables in form of key value to container configurations.
Ex.:
envs:   is parsed to   - name: a
  a: b                   value: b
*/}}
{{- define "aip.env.renderer" -}}
  {{- with .value}}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := $v }}
- name: {{ $k | quote }}
  value: {{ $v | quote }}
    {{- end }}
  {{- end }}
{{- end -}}
