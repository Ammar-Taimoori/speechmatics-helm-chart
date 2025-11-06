{{- define "sm-transcriber.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sm-transcriber.fullname" -}}
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

{{- define "sm-transcriber.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "sm-transcriber.appVersion" -}}
{{ default (default .Chart.AppVersion .Values.global.transcriber.image.tag) .Values.transcriber.image.tag }}
{{- end }}

{{- define "sm-transcriber.labels" -}}
helm.sh/chart: {{ include "sm-transcriber.chart" . }}
app.kubernetes.io/version: {{ (include "sm-transcriber.appVersion" $) | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
speechmatics.io/component: transcriber
{{- end }}

{{- define "sm-transcriber.nodeSelector" }}
{{- if (not (has .lang .config.transcriber.languages.cpuLanguages)) }}
{{- toYaml (merge .config.transcriber.processors.gpu.nodeSelector .config.transcriber.nodeSelector) }}
{{- else }}
{{- toYaml (merge .config.transcriber.processors.cpu.nodeSelector .config.transcriber.nodeSelector) }}
{{- end }}
{{- end }}

{{- define "sm-transcriber.tolerations" }}
{{- if (not (has .lang .config.transcriber.languages.cpuLanguages)) }}
{{- toYaml (concat .config.transcriber.processors.gpu.tolerations .config.transcriber.tolerations) }}
{{- else }}
{{- toYaml (concat .config.transcriber.processors.cpu.tolerations .config.transcriber.tolerations) }}
{{- end }}
{{- end }}

{{- define "sm-transcriber.resources" }}
{{- if (get .config.transcriber.languages.overrides.resources .lang) }}
{{- toYaml (get .config.transcriber.languages.overrides.resources .lang) }}
{{- else if (not (has .lang .config.transcriber.languages.cpuLanguages)) }}
{{- toYaml (default .config.transcriber.resources .config.transcriber.processors.gpu.resources) }}
{{- else }}
{{- toYaml (default .config.transcriber.resources .config.transcriber.processors.cpu.resources) }}
{{- end }}
{{- end }}

{{- define "sm-transcriber.enginePreWarm" -}}
{{- $preWarmString := "" }}
{{- $config := .config }}
{{- $processor := "gpu" }}
{{- if (has .lang $config.transcriber.languages.cpuLanguages) }}
  {{- $processor = "cpu" }}
{{- end }}
{{- range $langDomain := .languages }}
{{- $langParts := regexSplit "-" $langDomain 2 }}
{{- $lang := index $langParts 0 | trim }}
{{- $domain := "general" }}
{{- if ge (len $langParts) 2 }}
  {{- $domain = index $langParts 1 | trim }}
{{- end }}
{{- range $operatingPoint := (regexSplit "," ($config.transcriber.preWarm.operatingPoint | trimSuffix ",") -1) }}
  {{- $preWarmString = (printf "%s%s_%s_%s_%s:1;" $preWarmString $lang $domain $processor $operatingPoint) }}
{{- end }}
{{- end }}
{{- $preWarmString | trimSuffix ";" }}
{{- end }}

{{/*
  Extract a particular key in a list of dictionaries. Pipe output to list to get result of $names
*/}}
{{- define "sm-transcriber.envVarNames" }}
{{- $names := list }}
{{- range $index, $envDict := . -}}
{{- $names = append $names (pluck "name" $envDict) -}}
{{- end }}
{{- $names -}}
{{- end }}

{{/*
  Service image name
*/}}
{{- define "sm-transcriber.image" -}}
{{ printf "%s/%s%s:%s" (default .global.image.registry .component.image.registry) .component.image.repository (default "" .language) (default (default .Chart.AppVersion .global.image.tag) .component.image.tag) }}
{{- end }}

{{/*
  Sessiongroups scaling
*/}}
{{- define "sm-transcriber.sessionGroupsScaling" -}}
{{/* we need to copy the maps first to avoid mutating the global variables */}}
{{- $global_scaling := deepCopy .config.global.sessionGroups.scaling }}
{{- $component_scaling := deepCopy .config.sessionGroups.scaling }}
{{- $scaling := mergeOverwrite $global_scaling $component_scaling (get .config.transcriber.languages.overrides.sessionGroupsScaling .lang | default dict) }}
{{- if and (not (hasKey $scaling "scaleOnPodsLeft")) (not (hasKey $scaling "scaleOnCapacityLeft")) }}
  {{- fail "One value from sessionGroups.scaling.scaleOnPodsLeft or sessionGroups.scaling.scaleOnCapacityLeft must be set, or overriden in per-language scaling overrides." }}
{{- end }}
{{- toYaml $scaling | nindent 4 }}
{{- end }}