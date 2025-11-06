{{/*
Build the conversational engine, asr, llm and tts congfig
*/}}
{{- define "sm-flow.sysDefault" -}}
services:
  # Conversation Engine (CE) configuration
  ce:
    {{- include "sm-flow.conversationalEngine" . | nindent 4 }}

  {{- if not (default .Values.global.flow.flowUseLocalTranscriber .Values.config.asr.flowUseLocalTranscriber) }}
  # ASR configurations
  asr:
    {{- include "sm-flow.asrConfig" . | nindent 4 }}
  {{- end }}

  {{- if (or .Values.config.llm.azure.enabled .Values.config.llm.chatgpt.enabled .Values.llmProxy.enabled) }}
  # LLM configurations
  llm:
    {{- if .Values.config.llm.azure.enabled }}
    {{- include "sm-flow.azureLlmConfig" . | nindent 4 }}
    {{- end }}
    {{- if .Values.config.llm.chatgpt.enabled }}
    {{- include "sm-flow.chatgptLlmConfig" . | nindent 4 }}
    {{- end }}
    {{- if .Values.llmProxy.enabled }}
    {{- include "sm-flow.proxyLlmConfig" . | nindent 4 }}
    {{- end }}
  {{- end }}

  {{- if (or .Values.config.tts.sm.enabled .Values.config.tts.playht.enabled .Values.config.tts.elevenlabs.enabled) }}
  # TTS configurations
  tts:
    {{- if .Values.config.tts.sm.enabled }}
    {{- include "sm-flow.smTtsConfig" . | nindent 4 }}
    {{- end }}
    {{- if .Values.config.tts.playht.enabled }}
    {{- include "sm-flow.playhtTtsConfig" . | nindent 4 }}
    {{- end }}
    {{- if .Values.config.tts.elevenlabs.enabled }}
    {{- include "sm-flow.elevenlabsTtsConfig" . | nindent 4 }}
    {{- end }}
  {{- end }}

UsageReporting:
  mode: {{ .Values.usageReporting.mode }}
  {{- with .Values.usageReporting.server }}
  server: {{ . }}
  {{- end }}
  {{- with .Values.usageReporting.statusEventInterval }}
  status_event_interval_s: {{ . }}
  {{- end }}

EndOfTurn:
  enabled: {{ .Values.endOfTurn.enabled }}
  {{- if .Values.endOfTurn.enabled }}
  base_url: {{ .Values.endOfTurn.endpoint }}
  model: {{ .Values.endOfTurn.model }}
  probability_threshold: {{ .Values.endOfTurn.probabilityThreshold }}
  max_conversation_history_length: {{ .Values.endOfTurn.maxConversationHistoryLength }}
  max_history_tokens: {{ .Values.endOfTurn.maxHistoryTokens }}
  timeout_ms: {{ .Values.endOfTurn.timeout }}
  supported_languages: [{{ join "\", \"" .Values.endOfTurn.supportedLanguages | printf "\"%s\"" }}]
  {{- end }}

{{- end }}
