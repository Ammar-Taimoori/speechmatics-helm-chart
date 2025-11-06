{{- define "sm-flow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-flow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-flow.fullname" -}}
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
Common labels
*/}}
{{- define "sm-flow.labels" -}}
app: {{ .app | default (include "sm-flow.fullname" .) }}
app.kubernetes.io/version: {{ include "sm-flow.version" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-flow.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-flow.selectorLabels" -}}
app.kubernetes.io/name: {{ .app | default (include "sm-flow.fullname" .) }}
speechmatics.io/component: {{ include "sm-flow.fullname" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "sm-flow.annotations" -}}
helm.sh/chart: {{ include "sm-flow.chart" . }}
speechmatics.io/component: {{ include "sm-flow.fullname" . }}
{{- end }}

{{/*
Version of flow service
*/}}
{{- define "sm-flow.version" -}}
{{- default .Chart.AppVersion .Values.global.flow.image.tag .Values.image.tag }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sm-flow.serviceAccountName" -}}
{{- default (include "sm-flow.fullname" .) .Values.serviceAccountName }}
{{- end }}

{{/*
Create the name of the configMap consisting of all config files
*/}}
{{- define "sm-flow.configMapName" -}}
{{- default (printf "%s-config" (include "sm-flow.fullname" .)) .Values.configMapName }}
{{- end }}

{{/*
Create the name of the configMap consisting of agent/template files
*/}}
{{- define "sm-flow.agentConfigMapName" -}}
{{- default (printf "%s-agent-config" (include "sm-flow.fullname" .)) .Values.agentConfigMapName }}
{{- end }}

{{/* 
Component image structure
*/}}
{{- define "sm-flow.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}
