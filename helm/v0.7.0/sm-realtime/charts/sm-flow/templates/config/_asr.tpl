{{/*
Manage all ASR related config
*/}}
{{- define "sm-flow.asrConfig" -}}
SpeechmaticsASR:
  defaults:
    config:
      server: {{ (required "Please specify ASR endpoint" .Values.config.asr.endpoint) }}
{{- end }}
