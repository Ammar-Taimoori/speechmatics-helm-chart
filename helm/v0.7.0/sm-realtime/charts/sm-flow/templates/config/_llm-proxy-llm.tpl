{{/*
Manage all ProxyLLM related config
*/}}
{{- define "sm-flow.proxyLlmConfig" -}}
ProxyLLM:
  defaults:
    config:
      llm_timeout: {{ add (include "sm-llm-proxy.llmProxyTimeout" (dict "Values" .Values.llmProxy)) 2 }}
      {{- with .Values.config.llm.llmProxy.maxTokens }}
      completion:
        max_tokens: {{ . }}
      {{- end }}
      api:
        base_url: {{ printf "http://%s:8080" (include "sm-llm-proxy.llmProxyServiceName" (dict "Values" .Values.llmProxy)) }}
  presets:
    - base:
        config:
          completion:
            model: {{ .Values.config.llm.llmProxy.modelGroup }}
  {{- with .Values.config.llm.llmProxy.additionalPresets }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
