{{/*
Renders a hard/required node affinity
*/}}
{{- define "aip.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    {{- range .terms }}
    - matchExpressions: {{ include "aip.affinities.matchExpressions" . | indent 8 }}
    {{- end }}
{{- end -}}

{{/*
Renders a soft/preferred node affinity
*/}}
{{- define "aip.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  {{- range .rules }}
  - weight:  {{ .weight | default 1}}
    preference:
      matchExpressions: {{ include "aip.affinities.matchExpressions" . | indent 8 }}
  {{- end }}
{{- end -}}

{{/*
Renders a node affinity definition based a configured type (soft or hard)
*/}}
{{- define "aip.affinities.nodes" -}}
  {{- $type := .type | default "" -}}
  {{- if eq $type "hard" -}}
    {{- include "aip.affinities.nodes.hard" . -}}
  {{- else if eq $type "soft" }}
    {{- include "aip.affinities.nodes.soft" . -}}
  {{- end -}}
{{- end -}}

{{/*
Renders a hard/required pod affinity
*/}}
{{- define "aip.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  {{- range .selectors }}
  - labelSelector: {{- include "aip.affinities.labelSelector" . | nindent 6 }}
  {{- end }}
{{- end -}}

{{/*
Renders a soft/preferred pod affinity
*/}}
{{- define "aip.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  {{- range .rules }}
  - weight: {{ .weight | default 1}}
    podAffinityTerm:
      labelSelector: {{- (include "aip.affinities.labelSelector" .) | nindent 8 }}
  {{- end }}
{{- end -}}

{{/*
Renders a pod affinity definition based a configured type (soft or hard)
*/}}
{{- define "aip.affinities.pods" -}}
  {{- $type := .type | default "" -}}
  {{- if eq $type "hard" -}}
    {{- include "aip.affinities.pods.hard" . -}}
  {{- else if eq $type "soft" }}
    {{- include "aip.affinities.pods.soft" . -}}
  {{- end -}}
{{- end -}}

{{/*
Renders label selectors for pod affinity
*/}}
{{- define "aip.affinities.labelSelector" -}}
matchLabels:
  {{- range $key, $value := .labels }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
matchExpressions: {{ include "aip.affinities.matchExpressions" . | indent 2 }}
{{- end -}}

{{/*
Renders affinity match expressions
*/}}
{{- define "aip.affinities.matchExpressions" -}}
{{- range .expressions }}
- key: {{ .key | quote }}
  operator: {{ .operator | default "In" | quote }}
  values:
    {{- range .values }}
    - {{ . | quote }}
    {{- end }}
{{- end }}
{{- end -}}
