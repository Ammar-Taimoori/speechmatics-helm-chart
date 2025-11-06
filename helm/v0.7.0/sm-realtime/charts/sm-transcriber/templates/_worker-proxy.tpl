{{/*
Manage container configuration for worker-proxy
Make sure indentation is correct and as expected for spec.containers
*/}}
{{- define "sm-transcriber.workerProxy" -}}
{{- $langsNoDomain := list }}
{{- range $item := .languages }}
  {{- $langsNoDomain = append $langsNoDomain (split "-" $item)._0 }}
{{- end }}
{{- $cleaned_lang := ( .lang | replace "_" "-" ) }}
{{- $prefixed_version := ((eq "batch" .context.Values.transcriber.mode) | ternary (printf "%s%s" .context.Values.readinessTracker.versionPrefix (include "sm-transcriber.appVersion" .context)) (include "sm-transcriber.appVersion" .context)) }}
{{- $kube129 := (semverCompare ">=1.29.0" .context.Capabilities.KubeVersion.GitVersion) }}
      - name: worker-proxy
        env:
          - name: LANGUAGE_FEATURE
            value: {{ (join "," $langsNoDomain) | quote }}
          - name: SM_TOKEN_STORE_URL
          {{- if and (.context.Values.resourceManager.configMap) (.context.Values.resourceManager.configMap.enabled) }}
            valueFrom:
              configMapKeyRef:
                name: {{ default .context.Release.Name .context.Values.resourceManager.configMap.name }}
                key: resource_manager_url
          {{- else }}
            value: {{ default .context.Values.global.resourceManager.url .context.Values.resourceManager.url }}
          {{- end }}
          - name: SM_MODELS_SHARED_BY_LANGUAGES_PREFIXES
            value: "body,diar,audio_event_detection"
          {{- /* Support ability to optionally override the transcriber version used for IC, if not use image tag version */}}
          {{- if (not (has "TRANSCRIBER_VERSION" (include "sm-transcriber.envVarNames" .context.Values.workerProxy.env | list))) }}
          - name: TRANSCRIBER_VERSION
            value: {{ $prefixed_version | quote }}
          {{- end }}
          {{/* Enable check for capacity on Start when prewarm is enabled - only do this when worker-proxy is running as an init container */}}
          {{- if $kube129 }}
          - name: SM_CHECK_FOR_CAPACITY_ON_START
            value: {{ (and (ne .context.Values.readinessTracker.preWarm.enabled .context.Values.transcriber.preWarm.enabled) .context.Values.workerProxy.checkForCapacityOnStart) | quote }}
          {{- $preWarmOp := "enhanced" }}
          {{- /* worker proxy check for capacity is for only one operating point */}}
          {{- if (and .context.Values.transcriber.preWarm.enabled (eq (len (regexSplit "," (.context.Values.transcriber.preWarm.operatingPoint | trimSuffix ",") -1)) 1) (not .context.Values.readinessTracker.preWarm.enabled)) }}
            {{- $preWarmOp = .context.Values.transcriber.preWarm.operatingPoint }}
          {{- else if (and .context.Values.readinessTracker.preWarm.enabled (not .context.Values.transcriber.preWarm.enabled)) }}
            {{- $preWarmOp = .context.Values.readinessTracker.preWarm.operatingPoint }}
          {{- end }}
          - name: SM_CHECK_FOR_CAPACITY_ON_START_OPERATING_POINT
            value: {{ $preWarmOp | quote }}
          {{- end }}
          {{- if eq "batch" .context.Values.transcriber.mode }}
          - name: SM_LEASE_DURATION
            value: {{ .context.Values.transcriber.leaseDuration | quote }}
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
          {{- with .context.Values.workerProxy.env }}
          {{- toYaml . | nindent 10 }}
          {{- end }}
          - name: SM_TOKENS_RESOURCE_PARTITION
            value: {{ .context.Values.workerProxy.tokensResourcePartition | default "default" | quote }}
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
        image: {{ include "sm-transcriber.image" (dict "Chart" .context.Chart "global" .context.Values.global.resourceManager "component" .context.Values.workerProxy) | quote }}
        {{- with .context.Values.workerProxy.imagePullPolicy }}
        imagePullPolicy: {{ . }}
        {{- end }}
        ports:
          - containerPort: 8024
            {{- /* Do not change the port name as it is expected by repopulation service */}}
            name: wp-repop
            protocol: TCP
        {{- if $kube129 }}
        {{- /* Set restartPolicy as Always to run worker-proxy as initContainer sidecar which remain running during the entire life of the pod */}}
        restartPolicy: Always
        {{- end }}
        {{- with .context.Values.workerProxy.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.workerProxy.readinessProbe }}
        readinessProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.workerProxy.startupProbe }}
        startupProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
{{- end }}
