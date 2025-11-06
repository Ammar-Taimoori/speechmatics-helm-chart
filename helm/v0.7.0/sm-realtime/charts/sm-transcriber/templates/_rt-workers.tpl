{{/*
Manage container configuration for RT transcriber/worker
Make sure indentation is correct and as expected for spec.containers
*/}}
{{- define "sm-transcriber.rtWorker" -}}
{{- $cleaned_lang := ( .lang | replace "_" "-" ) }}
{{- $maxConcurrentConnections := (get .context.Values.transcriber.languages.overrides.maxConcurrentConnections .lang | default .context.Values.transcriber.maxConcurrentConnections.value) }}
{{- $maxRecognizers := (get .context.Values.transcriber.languages.overrides.maxRecognizers .lang | default (.context.Values.transcriber.maxRecognizers | default $maxConcurrentConnections)) }}
{{- $imageIdentifier := (dict "language" (printf "-%s" .lang)) }}
{{- if .context.Values.transcriber.mountModels.enabled }}
{{- $_ := set $imageIdentifier "language" "-nolang" }}
{{- end }}
{{- $version := (include "sm-transcriber.appVersion" .context) }}
{{- $kube129 := (semverCompare ">=1.29.0" .context.Capabilities.KubeVersion.GitVersion) }}
      - name: {{ .mode }}-asr-transcriber
        args:
          - --json
        env:
          {{- if .context.Values.eats.enabled }}
          {{- if .context.Values.eats.configMap.enabled }}
          - name: SM_EATS_URL
            valueFrom:
              configMapKeyRef:
                name: {{ .context.Values.eats.configMap.name }}
                key: sm_eats_url
          - name: SM_ENABLE_USAGE_REPORTING
            valueFrom:
              configMapKeyRef:
                name: {{ .context.Values.eats.configMap.name }}
                key: sm_enable_usage_reporting
          {{- else }}
          {{- with .context.Values.eats.url }}
          - name: SM_EATS_URL
            value: {{ . }}
          {{- end }}
          - name: SM_ENABLE_USAGE_REPORTING
            value: {{ .context.Values.eats.enableUsageReporting | quote }}
          {{- end }}
          - name: SM_EATS_SECURE
            value: {{ .context.Values.eats.secure | quote }}
          {{- else}}
          - name: SM_ENABLE_USAGE_REPORTING
            value: "false"
          {{- end }}
          {{- if .context.Values.transcriber.cdCache.enabled }}
          {{- if eq .context.Values.transcriber.cdCache.type "http"}}
          - name: SM_CUSTOM_DICTIONARY_CACHE_TYPE
            value: http
          - name: SM_CUSTOM_DICTIONARY_CACHE_HTTP_ENDPOINT
            value: "{{ .context.Values.resourceManager.url }}/v1/cd-cache"
          - name: SM_CUSTOM_DICTIONARY_CACHE_FALLBACK_ON_CACHE_FAILURE
            value: "true"
          - name: SM_CUSTOM_DICTIONARY_CACHE_HTTP_ASYNC
            value: "true"
          {{- else }}
          - name: SM_CUSTOM_DICTIONARY_CACHE_TYPE
            value: {{ .context.Values.transcriber.cdCache.type }}
          - name: SM_CUSTOM_DICTIONARY_CACHE_DIR_MAX_SIZE
            value: {{ default "-1" .context.Values.transcriber.cdCache.maxDirSize | quote }}
          - name: SM_CUSTOM_DICTIONARY_CACHE_DIR_MAX_ENTRIES
            value: {{ default "-1" .context.Values.transcriber.cdCache.maxDirEntries | quote }}
          - name: SM_CUSTOM_DICTIONARY_CACHE_ENTRY_MAX_SIZE
            value: {{ default "-1" .context.Values.transcriber.cdCache.maxEntrySize | quote }}
          {{- end }}
          {{- end }}
          {{- if .context.Values.translation.enabled }}
          - name: SM_TRANSLATION_ENDPOINT
            value: {{ .context.Values.translation.url }}
          {{- end }}
          {{- if .context.Values.sessionTransfer.enabled }}
          - name: SM_DO_SESSION_TRANSFER
            value: {{ .context.Values.sessionTransfer.enabled | quote }}
          {{- end }}
          {{- if .context.Values.transcriber.maxConcurrentConnections.configMap.enabled }}
          - name: SM_MAX_CONCURRENT_CONNECTIONS
            valueFrom:
              configMapKeyRef:
                name: {{ .context.Values.transcriber.maxConcurrentConnections.configMap.name }}
                key: sm_max_concurrent_connections
          {{- else }}
          - name: SM_MAX_CONCURRENT_CONNECTIONS
            value: {{ $maxRecognizers | quote }}
          {{- end }}
          {{- if .context.Values.transcriber.otel.enabled }}
          - name: HOST_IP
            valueFrom:
              fieldRef:
                fieldPath: status.hostIP
          - name: OTEL_EXPORTER_ENDPOINT
            value: "http://$(HOST_IP):4317"
          {{- end }}
          {{- if .context.Values.transcriber.speakerId.enabled }}
          - name: SM_SPEAKER_ID_SECRETS_DIR
            value: /speaker-id
          {{- end }}
          {{- if (and .context.Values.transcriber.preWarm.enabled (not .context.Values.readinessTracker.preWarm.enabled) $kube129) }}
          - name: SM_PREWARM_ENGINE_MODES
            value: {{ (include "sm-transcriber.enginePreWarm" (dict "languages" .preWarmLanguages "config" .context.Values)) | quote }}
          - name: SM_CHECK_INFERENCE_SERVER_CONN
            value: "true"
          {{- end }}
          {{- if .context.Values.global.flow.flowUseLocalTranscriber }}
          - name: SM_DISABLE_API_VALIDATION
            value: "true"
          {{- end }}
          {{- if (not (has .lang .context.Values.transcriber.languages.cpuLanguages)) }}
          - name: SM_ENHANCED_INFERENCE_ENDPOINT
            value: 0.0.0.0:8008
          - name: SM_INFERENCE_ENDPOINT
            value: 0.0.0.0:8008
          - name: SM_INFERENCE_ENDPOINT_RETRY_TIMEOUT
            value: "20"
          - name: SM_INFERENCE_REQUEST_TIMEOUT_MS
            value: "2000"
          {{- with .context.Values.transcriber.processors.gpu.env }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
          {{- else }}
          {{- with .context.Values.transcriber.processors.cpu.env }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
          {{- end }}
          {{- with .context.Values.transcriber.env }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
          {{/* Add any new env variables above this; SG injects SM_DEPLOYMENT_NAME, SM_NODE_NAME and SM_SPEC_VERSION at the bottom of the env variables list */}}
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
        image: {{ include "sm-transcriber.image" (merge $imageIdentifier (dict "Chart" .context.Chart "global" .context.Values.global.transcriber "component" .context.Values.transcriber)) | quote }}
        {{- with .context.Values.transcriber.imagePullPolicy }}
        imagePullPolicy: {{ . }}
        {{- end }}
        {{- with .context.Values.transcriber.livenessProbe }}
        livenessProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.transcriber.readinessProbe }}
        readinessProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.transcriber.startupProbe }}
        startupProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        ports:
          - containerPort: {{ .context.Values.transcriber.ports.containerPort }}
            name: ws
            protocol: TCP
          - containerPort: {{ .context.Values.transcriber.ports.healthPort }}
            name: health-port
            protocol: TCP
        {{- with (include "sm-transcriber.resources" (dict "lang" .lang "config" .context.Values)) }}
        resources:
          {{- . | nindent 10 }}
        {{- end }}
        volumeMounts:
          - mountPath: /license.json
            name: license
            readOnly: true
            subPath: license.json
          {{- if .context.Values.transcriber.cdCache.enabled }}
          {{- with .context.Values.transcriber.cdCache.volume }}
          - mountPath: /cache
            name: cache
            readOnly: false
          {{- end }}
          {{- end }}
          {{- if .context.Values.transcriber.speakerId.enabled }}
          - mountPath: /speaker-id
            name: speaker-id
            readOnly: true
          {{- end }}
          {{- if .context.Values.transcriber.mountModels.enabled }}
          - name: modeldata
            mountPath: /data
            readOnly: true
            subPath: model_langpacks/data
          - name: modeldata
            mountPath: /manifest
            readOnly: true
            subPath: manifests/{{ .context.Values.transcriber.mountModels.langpackVersion | default $version }}/{{ .lang }}
          {{- end }}
          {{- with .context.Values.transcriber.volumeMounts }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
{{- end }}
