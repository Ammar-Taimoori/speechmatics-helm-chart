{{- define "sm-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-proxy.fullname" -}}
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

{{- define "sm-proxy.appVersion" -}}
{{ default (default .Values.global.proxy.image.tag .Chart.AppVersion) .Values.proxy.image.tag | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* 
Service image name 
*/}}
{{- define "sm-proxy.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}

{{/*
Run multiple proxy service deployments
*/}}
{{- define "sm-proxy.deploymentName" -}}
{{- printf "%s-%s" (include "sm-proxy.fullname" .) .deployment | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sm-proxy.labels" -}}
app: {{ .app | default (include "sm-proxy.fullname" .) }}
{{- if .deployVersion }}
app.kubernetes.io/version: {{ .deployVersion | trunc 63 | trimSuffix "-" | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-proxy.selectorLabels" . }}
speechmatics.io/component: {{ include "sm-proxy.fullname" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ .app | default (include "sm-proxy.fullname" .) }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .deploy }}
speechmatics.io/deployment: {{ .deploy | quote }}
{{- end }}
{{- end }}

{{- define "sm-proxy.annotations" -}}
helm.sh/chart: {{ include "sm-proxy.chart" . }}
speechmatics.io/component: {{ include "sm-proxy.fullname" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sm-proxy.serviceAccountName" -}}
{{- default (include "sm-proxy.fullname" .) .Values.serviceAccountName }}
{{- end }}

{{- define "sm-proxy.activeDeployment" -}}
{{- $active := "invalid" }}
{{- range $key, $value := .Values.proxy.deployments }}
{{- if $value.active }}
{{- $active = $key }}
{{- break }}
{{- end }}
{{- end }}
{{- if (eq "invalid" $active) }}
{{- fail "Please provide more than one deployment" }}
{{- end }}
{{- print $active }}
{{- end }}

{{- define "sm-proxy.config" -}}
{{- printf "%s-config" (include "sm-proxy.fullname" .) }}
{{- end }}

{{- define "sm-proxy.agentConfig" -}}
{{- printf "%s-agent-config" (include "sm-proxy.fullname" .) }}
{{- end }}

{{- define "sm-proxy.customDictConfig" -}}
{{- printf "%s-custom-dict" (include "sm-proxy.fullname" .) }}
{{- end }}

{{- define "sm-proxy.dns" -}}
{{- printf "%s-dns" (include "sm-proxy.fullname" .) }}
{{- end }}

{{- define "sm-proxy.events" -}}
{{- default (printf "%s-events" (include "sm-proxy.fullname" $)) .Values.events.secretName }}
{{- end }}

{{- define "sm-proxy.storage" -}}
{{- default (printf "%s-storage" (include "sm-proxy.fullname" $)) .Values.storage.secretName }}
{{- end }}

{{- define "sm-proxy.database" -}}
{{ default (printf "%s-database" (include "sm-proxy.fullname" $)) .Values.database.secretName }}
{{- end }}

{{- define "sm-proxy.cacheServiceName" -}}
{{ default (printf "%s-cache" (include "sm-proxy.fullname" $)) }}
{{- end }}
