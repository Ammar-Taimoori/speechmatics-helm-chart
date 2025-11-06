{{/*
Manage all ElevenLabs TTS related config
*/}}
{{- define "sm-flow.elevenlabsTtsConfig" -}}
ElevenLabs:
  defaults:
    config:
      endpoint: {{ .Values.config.tts.elevenlabs.endpoint | default "https://api.elevenlabs.io/v1/text-to-speech/{voice}/stream" }}
  {{-  with .Values.config.tts.elevenlabs.additionalPresets }}
  presets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
