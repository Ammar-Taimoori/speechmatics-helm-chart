{{/*
Manage model costs for enhanced recipe 4
*/}}
capacity: {{ .Values.inferenceSidecar.registerFeatures.capacity }}
{{- with .Values.inferenceSidecar.registerFeatures.modelCosts }}
model_costs:
  "*:diar_enhanced": {{ .diar }}
  "*:body_enhanced": {{ .body }}
  "*:audio_event_detection": {{ .audioEventDetection }}
  fr:lm_fr_enhanced: {{ .lm_fr }}
  ar:am_ar_enhanced: {{ .am }}
  bn:am_bn_enhanced: {{ .am }}
  cmn:am_cmn_enhanced: {{ .am }}
  fr:am_fr_enhanced: {{ .am }}
  ja:am_ja_enhanced: {{ .am }}
  mt:am_mt_enhanced: {{ .am }}
  no:am_no_enhanced: {{ .am }}
  nl:am_nl_enhanced: {{ .am }}
  pl:am_pl_enhanced: {{ .am }}
  pt:am_pt_enhanced: {{ .am }}
  ru:am_ru_enhanced: {{ .am }}
  th:am_th_enhanced: {{ .am }}
  vi:am_vi_enhanced: {{ .am }}
  yue:am_yue_enhanced: {{ .am }}
  ar:ensemble_ar_enhanced: {{ .ensemble }}
  bn:ensemble_bn_enhanced: {{ .ensemble }}
  cmn:ensemble_cmn_enhanced: {{ .ensemble }}
  fr:ensemble_fr_enhanced: {{ .ensemble_fr }}
  ja:ensemble_ja_enhanced: {{ .ensemble }}
  mt:ensemble_mt_enhanced: {{ .ensemble }}
  no:ensemble_no_enhanced: {{ .ensemble }}
  nl:ensemble_nl_enhanced: {{ .ensemble }}
  pl:ensemble_pl_enhanced: {{ .ensemble }}
  pt:ensemble_pt_enhanced: {{ .ensemble }}
  ru:ensemble_ru_enhanced: {{ .ensemble }}
  th:ensemble_th_enhanced: {{ .ensemble }}
  vi:ensemble_vi_enhanced: {{ .ensemble }}
  yue:ensemble_yue_enhanced: {{ .ensemble }}
{{- end }}
{{- with .Values.inferenceSidecar.registerFeatures.additionalModelCosts }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
