{{/*
Manage model costs for enhanced recipe 1
*/}}
capacity: {{ .Values.inferenceSidecar.registerFeatures.capacity }}
{{- with .Values.inferenceSidecar.registerFeatures.modelCosts }}
model_costs:
  "*:diar_enhanced": {{ .diar }}
  "*:body_enhanced": {{ .body }}
  "*:audio_event_detection": {{ .audioEventDetection }}
  en:lm_en_enhanced: {{ .lm_en }}
  ba:am_ba_enhanced: {{ .am }}
  be:am_be_enhanced: {{ .am }}
  cmn_en:am_cmn_en_enhanced: {{ .am }}
  cy:am_cy_enhanced: {{ .am }}
  en:am_en_enhanced: {{ .am }}
  en_ms:am_en_ms_enhanced: {{ .am }}
  en_ta:am_en_ta_enhanced: {{ .am }}
  eo:am_eo_enhanced: {{ .am }}
  eu:am_eu_enhanced: {{ .am }}
  ga:am_ga_enhanced: {{ .am }}
  mn:am_mn_enhanced: {{ .am }}
  mr:am_mr_enhanced: {{ .am }}
  ta:am_ta_enhanced: {{ .am }}
  tr:am_tr_enhanced: {{ .am }}
  ug:am_ug_enhanced: {{ .am }}
  uk:am_uk_enhanced: {{ .am }}
  ba:ensemble_ba_enhanced: {{ .ensemble }}
  be:ensemble_be_enhanced: {{ .ensemble }}
  cmn_en:ensemble_cmn_en_enhanced: {{ .ensemble }}
  cy:ensemble_cy_enhanced: {{ .ensemble }}
  en:ensemble_en_enhanced: {{ .ensemble_en }}
  en_ms:ensemble_en_ms_enhanced: {{ .ensemble }}
  en_ta:ensemble_en_ta_enhanced: {{ .ensemble }}
  eo:ensemble_eo_enhanced: {{ .ensemble }}
  eu:ensemble_eu_enhanced: {{ .ensemble }}
  ga:ensemble_ga_enhanced: {{ .ensemble }}
  mn:ensemble_mn_enhanced: {{ .ensemble }}
  mr:ensemble_mr_enhanced: {{ .ensemble }}
  ta:ensemble_ta_enhanced: {{ .ensemble }}
  tr:ensemble_tr_enhanced: {{ .ensemble }}
  ug:ensemble_ug_enhanced: {{ .ensemble }}
  uk:ensemble_uk_enhanced: {{ .ensemble }}
{{- end }}
{{- with .Values.inferenceSidecar.registerFeatures.additionalModelCosts }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
