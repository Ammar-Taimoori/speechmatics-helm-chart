{{- define "sm-realtime.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-realtime.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-realtime.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Release.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Set name helper for inference controller chart to update pointers to sub-chart
*/}}
{{- define "sm-realtime.resourceManagerName" -}}
{{- if .Values.resourceManager.fullnameOverride }}
{{- .Values.resourceManager.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Release.Name .Values.resourceManager.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Helper to generate pod_selector_list for reconciliation server to monitor
*/}}
{{- define "sm-realtime.podSelectorList" -}}
{{- $names := list }}
{{- $services := list .Values.transcribers .Values.flow .Values.flow.tts .Values.inferenceServerCustom .Values.inferenceServerStandardAll .Values.inferenceServerEnhancedRecipe1 .Values.inferenceServerEnhancedRecipe2 .Values.inferenceServerEnhancedRecipe3 .Values.inferenceServerEnhancedRecipe4 }}
{{- range $services }}
  {{- if .enabled }}
    {{- $name := "" }}
    {{- if .fullnameOverride }}
      {{- $name = .fullnameOverride | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- $name = default $.Release.Name .nameOverride }}
      {{- if contains $name $.Release.Name }}
        {{- $name = $.Release.Name | trunc 63 | trimSuffix "-" }}
      {{- else }}
        {{- $name = printf "%s-%s" $.Release.Name $name | trunc 63 | trimSuffix "-" }}
      {{- end }}
    {{- end }}
    {{- $names = append $names $name }}
  {{- end }}
{{- end }}
{{- join "," $names }}
{{- end }}

{{- define "sm-realtime.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-realtime.selectorLabels" . }}
{{- end }}

{{- define "sm-realtime.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sm-realtime.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
speechmatics.io/component: realtime
{{- end }}

{{- define "sm-realtime.annotations" -}}
helm.sh/chart: {{ include "sm-realtime.chart" . }}
speechmatics.io/component: realtime
{{- end }}
