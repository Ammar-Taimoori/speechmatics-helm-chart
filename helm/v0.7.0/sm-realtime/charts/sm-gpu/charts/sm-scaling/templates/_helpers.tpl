{{/*
Expand the name of the chart.
*/}}
{{- define "sm-scaling.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-scaling.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sm-scaling.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sm-scaling.labels" -}}
app.kubernetes.io/version: {{ include "sm-scaling.version" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-scaling.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-scaling.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sm-scaling.fullname" . }}
speechmatics.io/component: {{ include "sm-scaling.fullname" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "sm-scaling.annotations" -}}
helm.sh/chart: {{ include "sm-scaling.chart" . }}
speechmatics.io/component: {{ include "sm-scaling.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sm-scaling.serviceAccountName" -}}
{{- default (include "sm-scaling.fullname" .) .Values.serviceAccountName }}
{{- end }}

{{/*
Version of scaler service
*/}}
{{- define "sm-scaling.version" -}}
{{- default .Chart.AppVersion (default .Values.global.scaler.image.tag .Values.image.tag) }}
{{- end }}

{{/*
Service image name
*/}}
{{- define "sm-scaling.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}
