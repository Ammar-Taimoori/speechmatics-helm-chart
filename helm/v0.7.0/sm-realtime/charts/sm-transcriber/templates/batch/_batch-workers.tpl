{{/*
Manage container configuration for Batch transcriber/worker
Make sure indentation is correct and as expected for spec.containers
*/}}
{{- define "sm-transcriber.batchWorker" -}}
{{- $cleaned_lang := ( .lang | replace "_" "-" ) }}
{{- $imageIdentifier := (dict "language" (printf "-%s" .lang)) }}
{{- if .context.Values.transcriber.mountModels.enabled }}
{{- $_ := set $imageIdentifier "language" "-nolang" }}
{{- end }}
{{- $version := (include "sm-transcriber.appVersion" .context) }}
{{- $kube129 := (semverCompare ">=1.29.0" .context.Capabilities.KubeVersion.GitVersion) }}
      - name: transcriber
        args:
          - --json
          - --run-mode
          - http
          - --parallel
          - {{ .context.Values.batch.parallel | quote }}
          - --all-formats
          - /output
          - --transcript-done-file
          - /output/DONE
          - --no-notify
          - --save-wav
          - --stderr
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
          - name: SM_BATCH_WORKER_LISTEN_PORT
            value: {{ .context.Values.transcriber.ports.containerPort | quote }}
          - name: SM_SPLIT_SIZE
            value: {{ .context.Values.batch.splitSize | quote }}
          - name: SM_API_URL
            value: {{ default .context.Values.global.batch.internalApi.url .context.Values.batch.internalApi.url }}
          - name: SM_ENABLE_AUTO_CHAPTERS
            value: "true"
          - name: ACS_CONFIG_PATH
            value: /var/secrets/openai/acs-config.yaml
          - name: ANTHROPIC_CONFIG_PATH
            value: /var/secrets/auto-chapters/auto-chapters-config.yaml
          - name: SM_ALLOW_FAIL_SPEECH_UNDERSTANDING
            value: "true"
          {{- if (and .context.Values.transcriber.preWarm.enabled (not .context.Values.readinessTracker.preWarm.enabled) $kube129) }}
          - name: SM_PREWARM_ENGINE_MODES
            value: {{ (include "sm-transcriber.enginePreWarm" (dict "languages" .preWarmLanguages "config" .context.Values)) | quote }}
          - name: SM_CHECK_INFERENCE_SERVER_CONN
            value: "true"
          {{- end }}
          - name: SM_TRANSCRIBER_POD_NODE_NAME
            valueFrom:
              fieldRef:
                apiVersion: v1
                fieldPath: spec.nodeName
          {{- if .context.Values.translation.enabled }}
          - name: SM_TRANSLATION_ENDPOINT
            value: {{ .context.Values.translation.url }}
          {{- end }}
          {{- if (not (has .lang .context.Values.transcriber.languages.cpuLanguages)) }}
          - name: SM_ENHANCED_INFERENCE_ENDPOINT
            value: 0.0.0.0:8008
          - name: SM_INFERENCE_ENDPOINT
            value: 0.0.0.0:8008
          - name: SM_INFERENCE_ENDPOINT_RETRY_TIMEOUT
            value: "300"
          - name: SM_INFERENCE_RESPONSE_TIMEOUT_MS
            value: "300000"
          - name: SM_INFERENCE_REQUEST_TIMEOUT_MS
            value: "2000"
          - name: SM_INFERENCE_ENDPOINT_CONNECTION_TIMEOUT
            value: "3"
          - name: SM_GPU_INFERENCE_MAX_ATTEMPTS
            value: "1"
          - name: SM_AUTO_CHAPTERS_TIMEOUT
            value: "1000"
          - name: ACS_RETRY_INTERVALS
            value: 5,5,480
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
            name: http
            protocol: TCP
        {{- with (include "sm-transcriber.resources" (dict "lang" .lang "config" .context.Values)) }}
        resources:
          {{- . | nindent 10 }}
        {{- end }}
        volumeMounts:
          - name: sharedvoluplo
            mountPath: /output
          - mountPath: /license.json
            name: license
            readOnly: true
            subPath: license.json
          - name: acsconfigvol
            mountPath: /var/secrets/openai
            readOnly: true
          - name: autochaptersconfigvol
            mountPath: /var/secrets/auto-chapters
            readOnly: true
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
{{- end }}
