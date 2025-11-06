{{/*
Manage all ChatGPT LLM related config
*/}}
{{- define "sm-flow.chatgptLlmConfig" -}}
ChatGPT:
  {{- with .Values.config.llm.chatgpt.maxTokens }}
  defaults:
    config:
      completion:
        max_tokens: {{ . }}
  {{- end }}
  presets:
    - gpt-4o:
        description: GPT-4o model
        config:
          completion:
            model: gpt-4o-2024-08-06
    - gpt-4o-mini:
        description: GPT-4o mini model
        config:
          completion:
            model: gpt-4o-mini-2024-07-18
  {{-  with .Values.config.llm.chatgpt.additionalPresets }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
