{{/*
Manage model costs for enhanced recipe 2
*/}}
capacity: {{ .Values.inferenceSidecar.registerFeatures.capacity }}
{{- with .Values.inferenceSidecar.registerFeatures.modelCosts }}
model_costs:
  "*:diar_enhanced": {{ .diar }}
  "*:body_enhanced": {{ .body }}
  "*:audio_event_detection": {{ .audioEventDetection }}
  es:lm_es_enhanced: {{ .lm_es }}
  bg:am_bg_enhanced: {{ .am }}
  es:am_es_enhanced: {{ .am }}
  et:am_et_enhanced: {{ .am }}
  fa:am_fa_enhanced: {{ .am }}
  gl:am_gl_enhanced: {{ .am }}
  hr:am_hr_enhanced: {{ .am }}
  ia:am_ia_enhanced: {{ .am }}
  id:am_id_enhanced: {{ .am }}
  lt:am_lt_enhanced: {{ .am }}
  lv:am_lv_enhanced: {{ .am }}
  ro:am_ro_enhanced: {{ .am }}
  sk:am_sk_enhanced: {{ .am }}
  sl:am_sl_enhanced: {{ .am }}
  tl:am_tl_enhanced: {{ .am }}
  ur:am_ur_enhanced: {{ .am }}
  bg:ensemble_bg_enhanced: {{ .ensemble }}
  es:ensemble_es_enhanced: {{ .ensemble_es }}
  et:ensemble_et_enhanced: {{ .ensemble }}
  fa:ensemble_fa_enhanced: {{ .ensemble }}
  gl:ensemble_gl_enhanced: {{ .ensemble }}
  hr:ensemble_hr_enhanced: {{ .ensemble }}
  ia:ensemble_ia_enhanced: {{ .ensemble }}
  id:ensemble_id_enhanced: {{ .ensemble }}
  lt:ensemble_lt_enhanced: {{ .ensemble }}
  lv:ensemble_lv_enhanced: {{ .ensemble }}
  ro:ensemble_ro_enhanced: {{ .ensemble }}
  sk:ensemble_sk_enhanced: {{ .ensemble }}
  sl:ensemble_sl_enhanced: {{ .ensemble }}
  tl:ensemble_tl_enhanced: {{ .ensemble }}
  ur:ensemble_ur_enhanced: {{ .ensemble }}
{{- end }}
{{- with .Values.inferenceSidecar.registerFeatures.additionalModelCosts }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
