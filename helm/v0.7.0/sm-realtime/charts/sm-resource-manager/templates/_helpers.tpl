{{- define "sm-resource-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-resource-manager.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-resource-manager.fullname" -}}
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
{{- define "sm-resource-manager.labels" -}}
app.kubernetes.io/version: {{ default (default .Chart.AppVersion .Values.global.resourceManager.image.tag) .Values.image.tag | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-resource-manager.selectorLabels" . }}
speechmatics.io/component: {{ include "sm-resource-manager.fullname" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-resource-manager.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sm-resource-manager.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .app }}
app: {{ .app }}
{{- end }}
{{- end }}

{{- define "sm-resource-manager.annotations" -}}
helm.sh/chart: {{ include "sm-resource-manager.chart" . }}
speechmatics.io/component: {{ include "sm-resource-manager.fullname" . }}
{{- end }}

{{- define "sm-resource-manager.databaseSecretName" -}}
{{ default (printf "%s-database" (include "sm-resource-manager.fullname" .)) .Values.secrets.database.name }}
{{- end }}

{{- define "sm-resource-manager.redisSecretName" -}}
{{ default (printf "%s-redis" (include "sm-resource-manager.fullname" .)) (default .Values.secrets.redis.name .Values.secrets.cdCache.name) }}
{{- end }}

{{- define "sm-resource-manager.sessiongroups-controller.fullname" -}}
{{ default .Values.sessionGroups.nameOverride "sessiongroups-controller" }}
{{- end }}

{{/* 
  Service image name 
*/}}
{{- define "sm-resource-manager.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}

{{/*
Node monitor conditions
*/}}
{{- define "sm-resource-manager.nodeMonitorConditions" -}}
{{- $conditionString := "" }}
{{- range $condition, $threshold := .Values.reconciliation.nodeMonitor.conditions }}
{{- $conditionString = (printf "%s%s:%0.f;" $conditionString $condition $threshold) }}
{{- end }}
{{- $conditionString | trimSuffix ";" | quote }}
{{- end }}
