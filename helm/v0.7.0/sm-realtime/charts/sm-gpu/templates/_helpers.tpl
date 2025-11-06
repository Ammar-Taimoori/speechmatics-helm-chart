{{/*
Expand the name of the chart.
*/}}
{{- define "sm-gpu.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-gpu.fullname" -}}
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
{{- define "sm-gpu.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Version of inference server
*/}}
{{- define "sm-gpu.appVersion" -}}
{{- default (default .Chart.AppVersion .Values.global.transcriber.image.tag) .Values.tritonServer.image.tag }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sm-gpu.labels" -}}
app.kubernetes.io/version: {{ (include "sm-gpu.appVersion" .) | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "sm-gpu.selectorLabels" . }}
speechmatics.io/component: {{ include "sm-gpu.fullname" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sm-gpu.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sm-gpu.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "sm-gpu.annotations" -}}
helm.sh/chart: {{ include "sm-gpu.chart" . }}
speechmatics.io/component: {{ include "sm-gpu.fullname" . }}
{{- end }}

{{/*
Datadog annotations for triton server
https://github.com/DataDog/integrations-core/blob/master/nvidia_triton/datadog_checks/nvidia_triton/data/conf.yaml.example
*/}}
{{- define "sm-gpu.tritonServerDatadogAnnotations" -}}
ad.datadoghq.com/{{ .containerName }}.check_names: |
  ["nvidia_triton"]
ad.datadoghq.com/{{ .containerName }}.init_configs: |
  [
    {
      "service": "{{ .name }}"
    }
  ]
{{- if .metrics }}
ad.datadoghq.com/{{ .containerName }}.instances: |
  [
    {
      "openmetrics_endpoint": "http://%%host%%:8002/metrics",
      "extra_metrics": {{ .metrics | toPrettyJson | nindent 8 }}
    }
  ]
{{- else }}
ad.datadoghq.com/{{ .containerName }}.instances: |
  [
    {
      "openmetrics_endpoint": "http://%%host%%:8002/metrics"
    }
  ]
{{- end }}
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
{{- define "sm-gpu.inferenceSidecarDatadogAnnotations" -}}
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
Create the name of the service account to use
*/}}
{{- define "sm-gpu.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sm-gpu.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the container to use
*/}}
{{- define "sm-gpu.containerName" -}}
{{- if ne .mode "translation" }}
{{- printf "triton-server" }}
{{- else }}
{{- printf "triton-server-translation" }}
{{- end }}
{{- end }}

{{/*
Create a string of registered features version
*/}}
{{- define "sm-gpu.registered_features_version" -}}
{{- $version := default (include "sm-gpu.appVersion" .) (get ((hasKey .Values.inferenceSidecar.env "REGISTER_FEATURES") | ternary ((get .Values.inferenceSidecar.env "REGISTER_FEATURES") | fromJson) .Values.inferenceSidecar.registerFeatures) "version") }}
{{- printf "%s%s" (default "" .Values.inferenceSidecar.versionPrefix) $version }}
{{- end }}

{{/*
Get model costs based on recipe of gpu server
*/}}
{{- define "sm-gpu.models_for_recipe" -}}
{{- if has .Values.tritonServer.recipe (list "enhanced-recipe1" "enhanced-recipe2" "enhanced-recipe3" "enhanced-recipe4" "standard-all" "custom") }}
{{ tpl (.Files.Get (printf "models/_%s.tpl" .Values.tritonServer.recipe)) . }}
{{- else }}
{{- fail "Please specify recipe as one of standard-all, enhanced-recipe1, enhanced-recipe2, enhanced-recipe3, enhanced-recipe4 or custom" }}
{{- end }}
{{- end }}

{{/*
Create a list of languages registered as feature list
*/}}
{{- define "sm-gpu.registered_languages" -}}
{{- $features := get ((hasKey .Values.inferenceSidecar.env "REGISTER_FEATURES") | ternary ((get .Values.inferenceSidecar.env "REGISTER_FEATURES") | fromJson) (include "sm-gpu.models_for_recipe" . | fromYaml)) "model_costs" }}
{{- $languages := dict }}
{{- range $key, $value := $features }}
{{- $parts := split ":" $key}}
{{- if and (eq (len $parts) 2) (ne $parts._0 "*") }}
{{- $_ := set $languages $parts._0 true }}
{{- end }}
{{- end }}
{{- printf "%s" (join "_" (keys $languages | uniq | sortAlpha)) }}
{{- end }}


{{/* Service image name */}}
{{- define "sm-gpu.image" -}}
{{ printf "%s/%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}

{{/*
Create a string of registered features
*/}}
{{- define "sm-gpu.registered_features" -}}
{{- $lang := (include "sm-gpu.registered_languages" .) }}
{{- if .Values.tritonServer.operatingPoint }}
{{- printf "%s_%s" .Values.tritonServer.operatingPoint $lang }}
{{- else }}
{{- printf "enhanced_%s:standard_%[1]s" $lang }}
{{- end }}
{{- end }}

{{- /*
Get registered features capacity
*/}}
{{- define "sm-gpu.registered_features_capacity" -}}
{{- get ((hasKey .Values.inferenceSidecar.env "REGISTER_FEATURES") | ternary ((get .Values.inferenceSidecar.env "REGISTER_FEATURES") | fromJson) .Values.inferenceSidecar.registerFeatures) "capacity" }}
{{- end }}


{{/* Process scaling config and replace model_utilization query */}}
{{- define "sm-gpu.processScalingConfig" -}}
{{- $config := deepCopy .Values.tritonServer.autoscaling.scalingConfig }}
{{- range $i, $metric := $config.metrics -}}
  {{- if (hasKey $metric.backend_properties "metric") }}
    {{- if (eq $metric.backend_properties.metric "model_set_usage") }}
      {{- $name := (include "sm-gpu.fullname" $) -}}
      {{- $model_set := (include "sm-gpu.registered_features" $) -}}
      {{- $version := (include "sm-gpu.registered_features_version" $) -}}
      {{- $capacity := (include "sm-gpu.registered_features_capacity" $) -}}
      {{- $_ := set $metric.backend_properties "labels" (dict "model_set" $model_set "model_version" $version "resource_type" $name) -}}
      {{- $capacity_percentage := (default 80 $metric.capacity_percentage) -}}
      {{/* set the factor to 0.8 * the capacity */}}
      {{- $_ = set $metric "strategy_properties" (dict "factor" (round (mulf (float64 $capacity) (divf $capacity_percentage 100.0)) 0)) -}}
      {{- $_ = unset $metric "capacity_percentage" -}}
    {{- end }}
  {{- else if (hasKey $metric.backend_properties "query") }}
    {{- if (eq $metric.backend_properties.query "open_connections" ) }}
      {{- $service := (include "sm-gpu.fullname" $ ) }}
      {{- $newQuery := printf "sum(open_connections{service=\"%s\"})" $service }}
      {{- $_ := set $metric.backend_properties "query" $newQuery -}}
    {{- end }}
    {{- if (eq $metric.backend_properties.query "queue_duration" ) }}
      {{- $service := (include "sm-gpu.fullname" $) }}
      {{- $newQuery := printf "max((sum by (node) (delta(nv_inference_queue_duration_us{service=\"%s\"}[2m]))/ sum by (node) (delta(nv_inference_count{service=\"%[1]s\"}[2m]))/1000) or vector(0))" $service }}
      {{- $_ := set $metric.backend_properties "query" $newQuery -}}
    {{- end }}
  {{- end }}
{{- end }}
{{- $config | toPrettyJson }}
{{- end }}
