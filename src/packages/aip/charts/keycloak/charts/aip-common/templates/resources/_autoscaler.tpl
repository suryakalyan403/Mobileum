{{/*
Template to render an horizontal pod autoscaler based on dynamic values
*/}}
{{- define "aip.resources.hpa" -}}
  {{- $context := .context | default $ -}}
  {{- $autoscaling := .autoscaling | default $context.Values.autoscaling | default dict -}}
  {{- if $autoscaling.enabled -}}
    {{- $target := .target | default (include "aip.names.fullname" (dict "context" $context)) }}
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ printf "%s-hpa" $target | trunc 63 | trimSuffix "-" | quote }}
  labels: {{- include "aip.labels.standard" $ | nindent 4 }}
  annotations: {{- include "aip.annotations.standard" (dict "context" $context) | nindent 4 }}
    app.aip/hpa-target: {{ $target }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ $autoscaling.kind | default "Deployment" }}
    name: {{ $target }}
  minReplicas: {{ $autoscaling.minReplicas | default 1 }}
  maxReplicas: {{ $autoscaling.maxReplicas | default 3 }}
  metrics:
    {{- $metrics := $autoscaling.metrics | default dict -}}
    {{- if $metrics.cpuPercent }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ $metrics.cpuPercent }}
    {{- end }}
    {{- if $metrics.memoryPercent }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ $metrics.memoryPercent }}
    {{- end }}
    {{- if and $metrics.customEnabled $metrics.custom }}
      {{- include "aip.renderer" ( dict "value" $metrics.custom "context" .context) | nindent 4 }}
    {{- end }}
    {{- $behaviors := $autoscaling.behaviors | default dict -}}
    {{- if $behaviors.enabled }}
  behavior:
      {{- $scaleDown := $behaviors.scaleDown | default dict -}}
      {{- if $scaleDown.enabled }}
    scaleDown:
      stabilizationWindowSeconds: {{ $scaleDown.stabilizationWindow | default 0 }}
      policies:
        {{- $podsScaleDown := $scaleDown.pods | default dict -}}
        {{- if $podsScaleDown.enabled }}
      - type: Pods
        value: {{ $podsScaleDown.value }}
        periodSeconds: {{ $podsScaleDown.period | default 15 }}
        {{- end }}
        {{- $percentScaleDown := $scaleDown.percent | default dict -}}
        {{- if $percentScaleDown.enabled }}
      - type: Percent
        value: {{ $percentScaleDown.value | default 100 }}
        periodSeconds: {{ $percentScaleDown.period | default 15 }}
        {{- end }}
      selectPolicy: {{ $scaleDown.selectPolicy | default "Max" }}
      {{- end }}
      {{- $scaleUp := $behaviors.scaleUp | default dict -}}
      {{- if $scaleUp.enabled }}
    scaleUp:
      stabilizationWindowSeconds: {{ $scaleUp.stabilizationWindow | default 0 }}
      policies:
        {{- $podsScaleUp := $scaleUp.pods | default dict -}}
        {{- if $podsScaleUp.enabled }}
      - type: Pods
        value: {{ $podsScaleUp.value }}
        periodSeconds: {{ $podsScaleUp.period | default 15 }}
        {{- end }}
        {{- $percentScaleUp := $scaleUp.percent | default dict -}}
        {{- if $percentScaleUp.enabled }}
      - type: Percent
        value: {{ $percentScaleUp.value | default 100 }}
        periodSeconds: {{ $percentScaleUp.period | default 15 }}
        {{- end }}
      selectPolicy: {{ $scaleUp.selectPolicy | default "Max" }}
      {{- end }}
    {{- end }}
  {{- end -}}
{{- end -}}
