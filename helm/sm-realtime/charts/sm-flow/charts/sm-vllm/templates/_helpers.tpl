{{- define "sm-vllm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-vllm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-vllm.fullname" -}}
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
{{- define "sm-vllm.labels" -}}
app: {{ .app | default (include "sm-vllm.fullname" .) }}
app.kubernetes.io/version: {{ include "sm-vllm.version" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-vllm.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-vllm.selectorLabels" -}}
app.kubernetes.io/name: {{ .app | default (include "sm-vllm.fullname" .) }}
speechmatics.io/component: {{ include "sm-vllm.fullname" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "sm-vllm.annotations" -}}
helm.sh/chart: {{ include "sm-vllm.chart" . }}
speechmatics.io/component: {{ include "sm-vllm.fullname" . }}
{{- end }}

{{/*
Datadog annotations for VLLM server
*/}}
{{- define "sm-vllm.vllmServerDatadogAnnotations" -}}
ad.datadoghq.com/{{ .containerName }}.check_names: |
  ["vllm"]
ad.datadoghq.com/{{ .containerName }}.init_configs: |
  [{}]
ad.datadoghq.com/{{ .containerName }}.instances: |
  [
    {
      "openmetrics_endpoint": "http://%%host%%:{{ .port }}/metrics"
    }
  ]
ad.datadoghq.com/{{ .containerName }}.logs: |
  [
    {
      "source": "vllm",
      "service": "{{ .name }}"
    }
  ]
{{- end }}

{{/*
Version of VLLM
*/}}
{{- define "sm-vllm.version" -}}
{{- default .Chart.AppVersion .Values.version }}
{{- end }}

{{/*
Create the service name for vllm
*/}}
{{- define "sm-vllm.vllmServiceName" -}}
{{ default (include "sm-vllm.fullname" .) (default .Values.service.serviceName .Values.global.flow.vllm.service.serviceName) }}
{{- end }}

{{/*
Parameters for VLLM server
*/}}
{{- define "sm-vllm.params" -}}
{{- $model := (default .Values.config.model .Values.global.flow.vllm.config.model) -}}
- --model={{ required "Please set the required model to use from VLLM server" $model }}
- --tensor-parallel-size={{ .Values.config.tensorParallelSize | default .Values.config.numGPUs}}
- --port={{ .Values.containerPort }}
- --dtype={{ .Values.config.dtype }}
{{- with .Values.config.maxModelLength }}
- --max-model-len={{ . }}
{{- end }}
{{- if .Values.config.enablePrefixCaching }}
- --enable-prefix-caching
{{- end }}
{{- if .Values.config.disableLogRequests }}
- --disable-log-requests
{{- end }}
{{- range $key, $value := .Values.config.additionalArgs }}
{{- /* Accept keys without values or with false as value */}}
{{- if eq ($value | quote | len) 2 }}
- --{{ $key }}
{{- else }}
- --{{ $key }}={{ $value }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create the name for vllm ingress host
*/}}
{{- define "sm-vllm.vllmIngressHost" -}}
{{- default (printf "vllm.%s" .Values.ingress.zone) .Values.ingress.host }}
{{- end }}
