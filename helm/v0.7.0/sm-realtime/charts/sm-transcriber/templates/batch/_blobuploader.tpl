{{/*
Manage container configuration for blobuploader
Make sure indentation is correct and as expected for spec.containers
*/}}
{{- define "sm-transcriber.blobUploader" -}}
{{- $cleaned_lang := ( .lang | replace "_" "-" ) }}
      - name: blobuploader
        env:
          - name: SM_API_URL
            value: {{ default .context.Values.global.batch.internalApi.url .context.Values.batch.internalApi.url }}
          - name: SM_BLOB_PROVIDER
            value: {{ .context.Values.blobuploader.provider }}
          {{- if (eq "azure" .context.Values.blobuploader.provider) }}
          - name: AZ_STORAGE_ACCOUNT
            valueFrom:
              secretKeyRef:
                key: account
                name: blob-storage
          - name: AZ_STORAGE_KEY
            valueFrom:
              secretKeyRef:
                key: key
                name: blob-storage
          {{- end }}
          - name: SM_PERSISTENT_BATCH_MODE
            value: "true"
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
        image: {{ include "sm-transcriber.image" (dict "Chart" .context.Chart "global" .context.Values.global.batch "component" .context.Values.blobuploader) | quote }}
        {{- with .context.Values.blobuploader.imagePullPolicy }}
        imagePullPolicy: {{ . }}
        {{- end }}
        volumeMounts:
          - name: sharedvoluplo
            mountPath: /output
          - name: internal-api-secret
            mountPath: /var/secrets/internal
            readOnly: true
        {{- with .context.Values.blobuploader.resources }}
        resources:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.blobuploader.readinessProbe }}
        readinessProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
        {{- with .context.Values.blobuploader.startupProbe }}
        startupProbe:
          {{- toYaml . | nindent 10 }}
        {{- end }}
{{- end }}
