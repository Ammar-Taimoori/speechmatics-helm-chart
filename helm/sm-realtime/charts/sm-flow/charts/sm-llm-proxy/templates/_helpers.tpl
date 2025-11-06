{{- define "sm-llm-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-llm-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-llm-proxy.fullname" -}}
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
{{- define "sm-llm-proxy.labels" -}}
app: {{ .app | default (include "sm-llm-proxy.fullname" .) }}
app.kubernetes.io/version: {{ include "sm-llm-proxy.version" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-llm-proxy.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-llm-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ .app | default (include "sm-llm-proxy.fullname" .) }}
speechmatics.io/component: {{ include "sm-llm-proxy.fullname" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "sm-llm-proxy.annotations" -}}
helm.sh/chart: {{ include "sm-llm-proxy.chart" . }}
speechmatics.io/component: {{ include "sm-llm-proxy.fullname" . }}
{{- end }}

{{/*
Version of LLM proxy service
*/}}
{{- define "sm-llm-proxy.version" -}}
{{- default .Chart.AppVersion .Values.version }}
{{- end }}

{{/*
Create the service name for the llm-proxy
*/}}
{{- define "sm-llm-proxy.llmProxyServiceName" -}}
{{ default (include "sm-llm-proxy.fullname" .) .Values.serviceName }}
{{- end }}

{{/*
Create the name of the llm-proxy configMap consisting of all llm configs
*/}}
{{- define "sm-llm-proxy.llmProxyConfigmapName" -}}
{{- default (printf "%s-config" (include "sm-llm-proxy.fullname" .)) .Values.configMapName }}
{{- end }}

{{/*
Get llm proxy timeout configuration
*/}}
{{- define "sm-llm-proxy.llmProxyTimeout" -}}
{{- printf "%d" (int .Values.backendTimeoutSec) }}
{{- end }}

{{/*
Create the name for llm-proxy ingress host
*/}}
{{- define "sm-llm-proxy.llmProxyIngressHost" -}}
{{- default (printf "llm-proxy.%s" .Values.ingress.zone) .Values.ingress.host }}
{{- end }}

{{/*
Create the name for llm-proxy ingress TLS host
*/}}
{{- define "sm-llm-proxy.llmProxyIngressTlsHost" -}}
{{- default (printf "*.%s" .Values.ingress.zone) .Values.ingress.tlsHost }}
{{- end }}

{{/* Service image name */}}
{{- define "sm-llm-proxy.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}

{{/* Construct model_list config for vllm if enabled from global */}}
{{- define "sm-llm-proxy.vllmModelList" -}}
{{- if .Values.global.flow.vllm.enabled }}
{{- $model := (required "Please set the required model to use from VLLM server" .Values.global.flow.vllm.config.model) }}
{{- $serviceName := .Values.global.flow.vllm.service.serviceName }}
{{- $port := .Values.global.flow.vllm.service.port }}
model_list:
- model_name: vllm
  llm_params:
    url: http://{{ $serviceName }}:{{ $port }}/v1/chat/completions
    model: {{ $model }}
{{- else }}
model_list: []
{{- end }}
{{- end }}
