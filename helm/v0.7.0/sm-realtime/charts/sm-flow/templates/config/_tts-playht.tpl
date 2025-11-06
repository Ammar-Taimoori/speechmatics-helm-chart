{{/*
Manage all PlayHT TTS related config
*/}}
{{- define "sm-flow.playhtTtsConfig" -}}
PlayHT:
  defaults:
    config:
      AdvancedOptions:
        grpc_addr: {{ (required "Please specify PlayHT endpoint" .Values.config.tts.playht.endpoint) }}
  {{-  with .Values.config.tts.playht.additionalPresets }}
  presets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
