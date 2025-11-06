{{/*
Manage container configuration for readiness-tracker
Make sure indentation is correct and as expected for spec.containers
*/}}
{{- define "sm-transcriber.readinessTracker" -}}
{{- $mode := .context.Values.transcriber.mode }}
{{- $featurePrefix := .context.Values.readinessTracker.featurePrefix }}
{{- $model_costs := dict }}
{{- $langsNoDomain := list }}
{{- range $item := .languages }}
  {{- $prefixed_lang := ((eq "batch" $mode) | ternary (printf "%s%s" $featurePrefix $item) $item) }}
  {{- $model_costs = set $model_costs $prefixed_lang 1 }}
  {{- $langsNoDomain = append $langsNoDomain (split "-" $item)._0 }}
{{- end }}
{{- $cleaned_lang := ( .lang | replace "_" "-" ) }}
{{- $prefixed_version := ((eq "batch" .context.Values.transcriber.mode) | ternary (printf "%s%s" .context.Values.readinessTracker.versionPrefix (include "sm-transcriber.appVersion" .context)) (include "sm-transcriber.appVersion" .context)) }}
{{- $maxConcurrentConnections := (get .context.Values.transcriber.languages.overrides.maxConcurrentConnections .lang | default .context.Values.transcriber.maxConcurrentConnections.value) }}
{{- $restartAfterNSessions := (get .context.Values.transcriber.languages.overrides.restartAfterNSessions .lang | default .context.Values.readinessTracker.restartAfterNSessions) }}
{{- $kube129 := (semverCompare ">=1.29.0" .context.Capabilities.KubeVersion.GitVersion) }}
      - name: readiness-tracker
        env:
          - name: SM_TOKEN_STORE_URL
            {{- if and (.context.Values.resourceManager.configMap) (.context.Values.resourceManager.configMap.enabled) }}
            valueFrom:
              configMapKeyRef:
                name: {{ default .context.Release.Name .context.Values.resourceManager.configMap.name }}
                key: resource_manager_url
            {{- else }}
            value: {{ default .context.Values.global.resourceManager.url .context.Values.resourceManager.url }}
            {{- end }}
          - name: POD_NAME
            valueFrom:
              fieldRef:
                apiVersion: v1
                fieldPath: metadata.name
          - name: POD_IP
            valueFrom:
              fieldRef:
                apiVersion: v1
                fieldPath: status.podIP
          {{- if (eq "batch" .context.Values.transcriber.mode) }}
          - name: SM_RUNTIME_MODE
            value: batch
          - name: SM_WORKER_HEALTH_PORT
            value: {{ .context.Values.transcriber.ports.healthPort | quote }}
          - name: SM_RESOURCE_PORT_TO_REGISTER
            value: {{ .context.Values.transcriber.ports.containerPort | quote }}
          - name: SM_LEASE_DURATION
            value: {{ .context.Values.transcriber.leaseDuration | quote }}
          {{- end }}
          {{- if .sgEnabled }}
          - name: REGISTER_CONDITIONS
            value: {{ .context.Values.readinessTracker.registerConditions | quote }}
          - name: REGISTER_FEATURES
            value: '{"capacity": {{ $maxConcurrentConnections }}, "version": {{ $prefixed_version | quote }}, "model_costs": {{ $model_costs | toJson }}, "partition": {{ ((default "default" .context.Values.readinessTracker.registerFeaturesPartition) | quote )}}}'
          {{- end }}
          - name: READINESS_TRACKER_HEALTH_CHECK_PORT
            value: "8002"
          {{- if .context.Values.readinessTracker.languageOverride }}
          - name: LANGUAGE_FEATURE
            value: {{ .context.Values.readinessTracker.languageOverride | quote }}
          {{- else }}
          - name: LANGUAGE_FEATURE
            value: {{ (join "," $langsNoDomain) | quote }}
          {{- end }}
          - name: SM_RESTART_TRANSCRIBER_AFTER_N_SESSIONS
            value: {{ $restartAfterNSessions | quote }}
          {{- if (and .context.Values.readinessTracker.preWarm.enabled .context.Values.transcriber.preWarm.enabled) }}
            {{- fail "Cannot have both readiness tracker and transcriber pre-warming enabled" }}
          {{- end }}
          - name: PRE_WARM_ENABLED
            value: {{ (and .context.Values.readinessTracker.preWarm.enabled (not .context.Values.transcriber.preWarm.enabled) $kube129) | quote }}
          - name: PRE_WARM_EVERY_SESSION
            value: {{ .context.Values.readinessTracker.preWarm.everySession | quote }}
          - name: PRE_WARM_OPERATING_POINT
            value: {{ default "enhanced" .context.Values.readinessTracker.preWarm.operatingPoint }}
          - name: PRE_WARM_CONTRACT_ID
            value: {{ .context.Values.readinessTracker.preWarm.contractId | quote }}
          - name: PRE_WARM_ONLY
            value: {{ .context.Values.readinessTracker.preWarm.preWarmOnly | quote }}
          {{- with .context.Values.readinessTracker.env }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
          {{- /* Needed for transcribers to report/decrement usage when running outside of default namespace */}}
          - name: SM_K8S_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          {{- /* Add any new env variables above this; SG injects SM_DEPLOYMENT_NAME, SM_NODE_NAME and SM_SPEC_VERSION at the bottom of the env variables list */}}
          - name: SM_DEPLOYMENT_NAME
            value: {{ .context.Values.transcriber.nameOverride | default (printf "%s-%s" .name $cleaned_lang) }}
          - name: SM_NODE_NAME
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: SM_SPEC_VERSION
            {{- if .sgEnabled }}
            valueFrom:
              fieldRef:
                fieldPath: 'metadata.labels[''speechmatics.com/spec-version'']'
            {{- else }}
            value: "1"
            {{- end }}
        image: {{ include "sm-transcriber.image" (dict "Chart" .context.Chart "global" .context.Values.global.resourceManager "component" .context.Values.readinessTracker) | quote }}
        {{- with .context.Values.readinessTracker.imagePullPolicy }}
        imagePullPolicy: {{ . }}
        {{- end }}
        {{- with .context.Values.readinessTracker.readinessProbe }}
        readinessProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.readinessTracker.startupProbe }}
        startupProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        ports:
          - containerPort: 8002
            name: check-port
            protocol: TCP
          - containerPort: 8022
            {{- /* Do not change the port name as it is expected by repopulation service */}}
            name: register-repop
            protocol: TCP
          - containerPort: 8023
            {{- /* Do not change the port name as it is expected by repopulation service */}}
            name: rt-repop
            protocol: TCP
        {{- with .context.Values.readinessTracker.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
{{- end }}
