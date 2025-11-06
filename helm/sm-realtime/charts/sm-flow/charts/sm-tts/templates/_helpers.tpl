{{- define "sm-tts.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-tts.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-tts.fullname" -}}
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
{{- define "sm-tts.labels" -}}
app: {{ .app | default (include "sm-tts.fullname" .) }}
app.kubernetes.io/version: {{ include "sm-tts.appVersion" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-tts.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-tts.selectorLabels" -}}
app.kubernetes.io/name: {{ .app | default (include "sm-tts.fullname" .) }}
speechmatics.io/component: {{ include "sm-tts.fullname" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "sm-tts.annotations" -}}
helm.sh/chart: {{ include "sm-tts.chart" . }}
speechmatics.io/component: {{ include "sm-tts.fullname" . }}
{{- end }}

{{/*
Datadog annotations for TTS server
*/}}
{{- define "sm-tts.ttsServerDatadogAnnotations" -}}
ad.datadoghq.com/{{ .containerName }}.logs: |
  [
    {
      "source": "{{ .name }}",
      "service": "{{ .name }}"
    }
  ]
{{- end }}

{{/*
Datadog annotations for inference sidecar
*/}}
{{- define "sm-tts.inferenceSidecarDatadogAnnotations" -}}
ad.datadoghq.com/inference-sidecar.check_names: |
  ["openmetrics"]
ad.datadoghq.com/inference-sidecar.init_configs: |
  [{}]
ad.datadoghq.com/inference-sidecar.instances: |
  [
    {
      "prometheus_url": "http://%%host%%:{{ .port }}/metrics",
      "namespace": "inference-sidecar",
      "service": "inference-sidecar",
      "metrics": {{ default (list (dict "*" "*")) .metrics | toPrettyJson | nindent 8 }}
    }
  ]
{{- end }}

{{/*
Version of TTS
*/}}
{{- define "sm-tts.appVersion" -}}
{{- default (default .Chart.AppVersion .Values.global.tts.image.tag) .Values.image.tag }}
{{- end }}

{{/* Service image name */}}
{{- define "sm-tts.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}

{{/*
Create the service name for TTS
*/}}
{{- define "sm-tts.ttsServiceName" -}}
{{ default (include "sm-tts.fullname" .) .Values.serviceName }}
{{- end }}

{{/*
Create the name for TTS ingress host
*/}}
{{- define "sm-tts.ttsIngressHost" -}}
{{- default (printf "tts.%s" .Values.ingress.zone) .Values.ingress.host }}
{{- end }}

{{/*
Get model costs for TTS
*/}}
{{- define "sm-tts.models" -}}
{{ tpl (.Files.Get "models/_default.tpl") . }}
{{- end }}
