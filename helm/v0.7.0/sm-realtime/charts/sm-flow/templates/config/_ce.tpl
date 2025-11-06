{{/*
# Conversation Engine (CE) configuration file
*/}}
{{- define "sm-flow.conversationalEngine" -}}
LLaVA:
  defaults:
    config:
      {{- if .Values.config.ce.conversationLimit.enabled }}
      conversation_config:
        # sets the maximum session duration time (in seconds)
        conversation_duration_limit_s: {{ .Values.config.ce.conversationLimit.duration }}
        # sets how long before the termination (in seconds), client receives a warning message
        conversation_termination_warning_s: {{ .Values.config.ce.conversationLimit.terminationWarningInterval }}
      {{- end }}
      services:
        llm: {{ .Values.config.ce.llm.default }}
{{- end }}
