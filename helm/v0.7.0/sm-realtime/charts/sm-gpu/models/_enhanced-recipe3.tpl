{{/*
Manage model costs for enhanced recipe 3
*/}}
capacity: {{ .Values.inferenceSidecar.registerFeatures.capacity }}
{{- with .Values.inferenceSidecar.registerFeatures.modelCosts }}
model_costs:
  "*:diar_enhanced": {{ .diar }}
  "*:body_enhanced": {{ .body }}
  "*:audio_event_detection": {{ .audioEventDetection }}
  de:lm_de_enhanced: {{ .lm_de }}
  ca:am_ca_enhanced: {{ .am }}
  cs:am_cs_enhanced: {{ .am }}
  da:am_da_enhanced: {{ .am }}
  de:am_de_enhanced: {{ .am }}
  el:am_el_enhanced: {{ .am }}
  fi:am_fi_enhanced: {{ .am }}
  he:am_he_enhanced: {{ .am }}
  hi:am_hi_enhanced: {{ .am }}
  hu:am_hu_enhanced: {{ .am }}
  it:am_it_enhanced: {{ .am }}
  ko:am_ko_enhanced: {{ .am }}
  ms:am_ms_enhanced: {{ .am }}
  sv:am_sv_enhanced: {{ .am }}
  sw:am_sw_enhanced: {{ .am }}
  ca:ensemble_ca_enhanced: {{ .ensemble }}
  cs:ensemble_cs_enhanced: {{ .ensemble }}
  da:ensemble_da_enhanced: {{ .ensemble }}
  de:ensemble_de_enhanced: {{ .ensemble_de }}
  el:ensemble_el_enhanced: {{ .ensemble }}
  fi:ensemble_fi_enhanced: {{ .ensemble }}
  he:ensemble_he_enhanced: {{ .ensemble }}
  hi:ensemble_hi_enhanced: {{ .ensemble }}
  hu:ensemble_hu_enhanced: {{ .ensemble }}
  it:ensemble_it_enhanced: {{ .ensemble }}
  ko:ensemble_ko_enhanced: {{ .ensemble }}
  ms:ensemble_ms_enhanced: {{ .ensemble }}
  sv:ensemble_sv_enhanced: {{ .ensemble }}
  sw:ensemble_sw_enhanced: {{ .ensemble }}
{{- end }}
{{- with .Values.inferenceSidecar.registerFeatures.additionalModelCosts }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
