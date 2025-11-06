{{/*
Manage all SM TTS related config
*/}}
{{- define "sm-flow.smTtsConfig" -}}
SpeechmaticsTTS:
  defaults:
    config:
      endpoint: {{ .Values.config.tts.sm.endpoint | default (printf "http://%s:8000/generate/" (include "sm-tts.ttsServiceName" (dict "Values" .Values.tts))) }}
  {{-  with .Values.config.tts.sm.additionalPresets }}
  presets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
