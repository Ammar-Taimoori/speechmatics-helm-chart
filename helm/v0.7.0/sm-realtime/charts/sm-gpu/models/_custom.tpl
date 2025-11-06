{{/*
Manage model costs for custom recipe
*/}}
capacity: {{ .Values.inferenceSidecar.registerFeatures.capacity }}
{{- with (required "Please specify model cost details in customModelCosts when using custom recipe" .Values.inferenceSidecar.registerFeatures.customModelCosts) }}
model_costs:
  {{- . | toYaml | nindent 2 }}
{{- end }}
