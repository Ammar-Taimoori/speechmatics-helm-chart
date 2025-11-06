{{/*
Manage model costs for presets defined in flow service
*/}}
capacity: {{ .Values.inferenceSidecar.registerFeatures.capacity }}
{{- with .Values.inferenceSidecar.registerFeatures.modelCosts }}
model_costs:
  american-female: {{ .americanFemale }}
  american-male: {{ .americanMale }}
  french-female: {{ .frenchFemale }}
  spanish-female: {{ .spanishFemale }}
{{- end }}
{{- with .Values.inferenceSidecar.registerFeatures.additionalModelCosts }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
