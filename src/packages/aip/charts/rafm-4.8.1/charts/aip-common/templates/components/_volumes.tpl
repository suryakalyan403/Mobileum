{{/*
Volume mount that allows custom cacerts to be added to AIP java images
*/}}
{{- define "aip.volumes.mount.javacatrust" -}}
  {{- $tls := .tls | default dict -}}
  {{- if $tls.enabled -}}
- name: javacatrust
  mountPath: /etc/pki/ca-trust/extracted/java/
  readOnly: true
  {{- end -}}
{{- end -}}

{{/*
Volume that will map a config map or a secret with a cacert
*/}}
{{- define "aip.volumes.javacatrust" -}}
  {{- $tls := .tls | default dict -}}
  {{- if $tls.enabled -}}
- name: javacatrust
    {{- if $tls.configmap }}
  configMap:
    name: {{ $tls.configmap.name }}
    {{- else if $tls.secret }}
  secret:
    secretName: {{ $tls.secret.name }}
    items:
      - key: {{ base $tls.secret.path }}
        path: cacerts
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Volumes mounts for each of the volumes dynamically configured by the user
*/}}
{{- define "aip.volumes.mounts" -}}
  {{- $context := .context | default $ -}}
  {{- $persistences := .persistence | default list -}}
  {{- range $idx, $persistence := $persistences }}
    {{- $mounts := $persistence.mounts -}}
    {{- if $mounts }}
      {{- $name := $persistence.name | default (printf "%s-%d" (include "aip.names.fullname" (dict "context" $context)) $idx) }}
      {{- range $_, $mount := $mounts }}
- name: {{ $name }}
        {{- include "aip.renderer" ( dict "value" $mount "context" $context ) | nindent 2 }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}

{{/*
Volumes that can be dynamically configured by the user
*/}}
{{- define "aip.volumes" -}}
  {{- $context := .context | default $ -}}
  {{- $persistences := .persistence | default list -}}
  {{- range $idx, $persistence := $persistences }}
    {{- $volume := $persistence.volume }}
    {{- $claim := $persistence.claim }}
    {{- $existingClaim := $persistence.existingClaim }}
    {{- if not $persistence.enabled }}
- name: {{ $persistence.name | default (printf "%s-%d" (include "aip.names.fullname" (dict "context" $context)) $idx) }}
  emptyDir: {}
    {{-  else if not $persistence.claimTemplate }}
- name: {{ $persistence.name | default (printf "%s-%d" (include "aip.names.fullname" (dict "context" $context)) $idx) }}
      {{- if $volume }}
      {{- include "aip.renderer" ( dict "value" $volume "context" $context ) | nindent 2 }}
      {{- else if $existingClaim }}
  persistentVolumeClaim:
    claimName: {{ $existingClaim }}
      {{- else if $claim }}
  persistentVolumeClaim:
    claimName: {{ if and $claim.accessModes (has "ReadWriteMany" $claim.accessModes) }}{{ $persistence.name }}{{ else }}{{ printf "%s-%s-pvc-%d" (include "aip.names.fullname" (dict "context" $context)) $persistence.name $idx }}{{ end }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}


{{/*
Volumes claim templates that can be dynamically configured by the user
*/}}
{{- define "aip.volumes.templates" -}}
  {{- $context := .context | default $ -}}
  {{- $persistences := .persistence | default list -}}
  {{- range $idx, $persistence := $persistences }}
    {{- $template := $persistence.claimTemplate -}}
    {{- if and $persistence.enabled $template }}
      {{- $name := $persistence.name | default (printf "%s-%d" (include "aip.names.fullname" (dict "context" $context)) $idx) }}
- metadata: {{ include "aip.pvc.metadata" ( dict "name" $name "context" $context "template" $template) | nindent 4 }}
  spec: {{ include "aip.pvc.spec" ( dict "context" $context "template" $template) | nindent 4 }}
    {{- end }}
  {{- end -}}
{{- end -}}


{{/*
Persistent volumes claim that can be dynamically configured by the user
*/}}
{{- define "aip.volumes.claims" -}}
  {{- $context := .context | default $ -}}
  {{- $persistences := .persistence | default list -}}
  {{- range $idx, $persistence := $persistences }}
    {{- if and $persistence.enabled $persistence.claim }}
      {{- $claim := $persistence.claim -}}
      {{- $name := "" -}}
      {{- if and $claim.accessModes (has "ReadWriteMany" $claim.accessModes) }}
        {{- $name = $persistence.name -}}
      {{- else if and $claim.accessModes (has "ReadWriteOnce" $claim.accessModes) }}
        {{- $name = printf "%s-%s-pvc-%d" (include "aip.names.fullname" (dict "context" $context)) $persistence.name $idx }}
      {{- else }}
        {{- $name = printf "%s-%s-pvc-%d" (include "aip.names.fullname" (dict "context" $context)) $persistence.name $idx }}
      {{- end }}
      {{- $_ := set $claim "name" $name -}}
      {{- include "aip.resources.pvc" (dict "name" $name "context" $context "template" $claim) | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end }}




{{/*
Allows the user to change mount permissions for dynamically mounted volumes
*/}}
{{- define "aip.volumes.permissions" -}}
  {{- range $idx, $mount := . }}
{{ printf "chown  \"1001:0\" \"%s\"" $mount }}
  {{- end }}
{{- end -}}


{{/*
Global CA bundle volume mount
*/}}
{{- define "aip.volumes.mount.catrust" -}}
  {{- $caTrust := .caTrust | default dict -}}
  {{- if $caTrust.enabled -}}
- name: catrust
  mountPath: /etc/pki/ca-trust/source/anchors
  readOnly: true
  {{- end -}}
{{- end -}}

{{/*
Global CA bundle volume
*/}}
{{- define "aip.volumes.catrust" -}}
  {{- $caTrust := .caTrust | default dict -}}
  {{- if $caTrust.enabled -}}
- name: catrust
    {{- if $caTrust.configmap }}
  configMap:
    name: {{ $caTrust.configmap }}
    {{- else if $caTrust.secret }}
  secret:
    secretName: {{ $caTrust.secret }}
    {{- end -}}
  {{- end -}}
{{- end -}}

