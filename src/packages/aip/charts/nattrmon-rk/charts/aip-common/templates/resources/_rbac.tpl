{{- define "aip.resources.rbac" -}}
 {{- $context := .context | default $ -}}
  {{- $rbac := .rbac | default $context.Values.rbac -}}

  {{- $automountServiceAccountToken := false }}
  {{- if hasKey $context.Values "automountServiceAccountToken" }}
    {{- $automountServiceAccountToken = $context.Values.automountServiceAccountToken }}
  {{- else if and (hasKey $context.Values "global") (hasKey $context.Values.global "automountServiceAccountToken") }}
    {{- $automountServiceAccountToken = $context.Values.global.automountServiceAccountToken }}
  {{- end }}

  {{- if $rbac.enabled -}}


{{/* AIP basic service account*/}}
{{- if eq $rbac.serviceAccountName "aip-basic-sa" }}
{{- if not (lookup "v1" "ServiceAccount" $context.Release.Namespace "aip-basic-sa") -}}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aip-basic-sa
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
automountServiceAccountToken: {{ $automountServiceAccountToken }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-basic-role
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [endpoints]
  verbs: [get,list, watch]
- apiGroups: [""]
  resources: [events]
  verbs: [create]
- apiGroups: [""]
  resources: [pods]
  verbs: [get, list, watch]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-basic-rb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-basic-sa
roleRef:
  kind: Role
  name: aip-basic-role
  apiGroup: rbac.authorization.k8s.io
{{- end -}}
{{/* AIP basic service account ends*/}}



{{/* AIP adv service account*/}}
{{- else if eq $rbac.serviceAccountName "aip-adv-sa" }}
{{- if not (lookup "v1" "ServiceAccount" $context.Release.Namespace "aip-adv-sa") -}}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aip-adv-sa
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
automountServiceAccountToken: {{ $automountServiceAccountToken }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-adv-role
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [endpoints]
  verbs: [get, list, watch]
- apiGroups: [""]
  resources: [events]
  verbs: [create]
- apiGroups: [""]
  resources: [pods]
  verbs: [get,list,watch,create,delete,deletecollection]
- apiGroups: [""]
  resources: [services]
  verbs: [list,create,delete,deletecollection]
- apiGroups: [""]
  resources: [configmaps]
  verbs: [list,create,delete,deletecollection]
- apiGroups: [""]
  resources: [persistentvolumeclaims]
  verbs: [list,deletecollection]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: [list,create,delete,deletecollection]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-adv-rb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-adv-sa
roleRef:
  kind: Role
  name: aip-adv-role
  apiGroup: rbac.authorization.k8s.io
{{- end -}}
{{/* AIP adv service account ends*/}}




{{/* AIP spl-nattr service account*/}}
{{- else if eq $rbac.serviceAccountName "aip-spl-nattr-sa" }}
{{- if not (lookup "v1" "ServiceAccount" $context.Release.Namespace "aip-spl-nattr-sa") -}}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aip-spl-nattr-sa
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
automountServiceAccountToken: {{ $automountServiceAccountToken }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-monitor-role
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [pods]
  verbs: [get, list, watch]
- apiGroups: [""]
  resources: [pods,pods/exec]
  verbs: [get, create]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-nattr-rb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-spl-nattr-sa
roleRef:
  kind: Role
  name: aip-monitor-role
  apiGroup: rbac.authorization.k8s.io
{{- end -}}
{{/* AIP spl-nattr service account ends*/}}



{{/* AIP spl-fltbit service account*/}}
{{- else if eq $rbac.serviceAccountName "aip-spl-fltbit-sa" }}
{{- if not (lookup "v1" "ServiceAccount" $context.Release.Namespace "aip-spl-fltbit-sa") -}}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aip-spl-fltbit-sa
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
automountServiceAccountToken: {{ $automountServiceAccountToken }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-monitor-role
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [pods]
  verbs: [get, list, watch]
- apiGroups: [""]
  resources: [pods,pods/exec]
  verbs: [get, create]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-fltbit-rb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-spl-fltbit-sa
roleRef:
  kind: Role 
  name: aip-monitor-role
  apiGroup: rbac.authorization.k8s.io
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-basic-crole
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [namespaces]
  verbs: [get, list, watch]
- apiGroups: [""]
  resources: [nodes]
  verbs: [get, list, watch]
- apiGroups: [""]
  resources: [pods]
  verbs: [get, list, watch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aip-spl-fltbit-crb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-spl-fltbit-sa
  namespace: {{ $context.Release.Namespace }}
roleRef:
  kind: ClusterRole 
  name: aip-basic-crole
  apiGroup: rbac.authorization.k8s.io
{{- end -}}
{{/* AIP spl-fltbit service account ends*/}}



{{/* AIP spl-gtk service account*/}}
{{- else if eq $rbac.serviceAccountName "aip-spl-gtk-sa" }}
{{- if not (lookup "v1" "ServiceAccount" $context.Release.Namespace "aip-spl-gtk-sa") -}}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aip-spl-gtk-sa
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
automountServiceAccountToken: {{ $automountServiceAccountToken }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-gtk-role
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [events]
  verbs: [create,patch]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: [list,create,delete,get,patch,watch,update]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-gtk-rb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-spl-gtk-sa
roleRef:
  kind: Role 
  name: aip-spl-gtk-role
  apiGroup: rbac.authorization.k8s.io
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-gtk-crole
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [events]
  verbs: [create,patch]
- apiGroups: ["*"]
  resources: ["*"]
  verbs: [get,list,watch]
- apiGroups: [admissionregistration.k8s.io]
  resources: [mutatingwebhookconfigurations]
  verbs: [get,list,patch,update,watch]
- apiGroups: [apiextensions.k8s.io]
  resources: [customresourcedefinitions]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [config.gatekeeper.sh]
  resources: [configs]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [constraints.gatekeeper.sh]
  resources: ["*"]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [expansion.gatekeeper.sh]
  resources: ["*"]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [externaldata.gatekeeper.sh]
  resources: [resources]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [mutations.gatekeeper.sh]
  resources: ["*"]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [status.gatekeeper.sh]
  resources: ["*"]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [templates.gatekeeper.sh]
  resources: [constrainttemplates]
  verbs: [get, list,patch, update,watch, create, delete]
- apiGroups: [admissionregistration.k8s.io]
  resources: [validatingwebhookconfigurations]
  verbs: [get, list,patch, update,watch, create, delete]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-gtk-crb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-spl-gtk-sa
  namespace: {{ $context.Release.Namespace }}
roleRef:
  kind: ClusterRole 
  name: aip-spl-gtk-crole
  apiGroup: rbac.authorization.k8s.io
{{- end -}}
{{/* AIP spl-gtk service account ends*/}}


{{/* AIP spl-rmq service account*/}}
{{- else if eq $rbac.serviceAccountName "aip-spl-rmq-sa" }}
{{- if not (lookup "v1" "ServiceAccount" $context.Release.Namespace "aip-spl-rmq-sa") -}}
---
kind: ServiceAccount
apiVersion: v1
metadata:
  name: aip-spl-rmq-sa
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
automountServiceAccountToken: {{ $automountServiceAccountToken }}
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-rmq-role
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
rules:
- apiGroups: [""]
  resources: [endpoints]
  verbs: [get, list]
- apiGroups: [""]
  resources: [events]
  verbs: [create]
- apiGroups: [""]
  resources: [pods]
  verbs: [get, list, watch]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: aip-spl-rmq-rb
  labels: {{- include "aip.labels.standard" . | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" . | nindent 4 }}
subjects:
- kind: ServiceAccount
  name: aip-spl-rmq-sa
roleRef:
  kind: Role
  name: aip-spl-rmq-role
  apiGroup: rbac.authorization.k8s.io
{{- end -}}
{{/* AIP spl-rmq service account ends*/}}

{{- end -}}


{{- end -}}
{{- end -}}
