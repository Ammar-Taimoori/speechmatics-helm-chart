{{/*
Manage all Azure LLM related config
*/}}
{{- define "sm-flow.azureLlmConfig" -}}
Azure:
  defaults:
    config:
      {{- with .Values.config.llm.azure.maxTokens }}
      completion:
        max_tokens: {{ . }}
      {{- end }}
      api:
        api_version: {{ .Values.config.llm.azure.apiVersion }}
  {{-  with .Values.config.llm.azure.additionalPresets }}
  presets:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
