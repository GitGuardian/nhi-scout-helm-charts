{{- define "nhi-scout.cronjob" -}}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "nhi-scout.fullname" . }}-{{ .cronjob_name }}
  labels:
    {{- include "nhi-scout.labels" . | nindent 4 }}
spec:
  schedule: {{ toJson .schedule  }}
  jobTemplate:
    spec:
      template:
        metadata:
          {{- with .Values.podAnnotations }}
          annotations: {{- toJson . }}
          {{- end }}
          labels:
            {{- include "nhi-scout.labels" . | nindent 12 }}
            {{- with .Values.podLabels }}
            {{ toYaml . | nindent 12 }}
            {{- end }}
        spec:
          {{- include "nhi-scout.securityContext" $ | indent 10 }}
          containers:
            - name: {{ .Chart.Name }}
              image: "{{ .Values.image.repository }}:{{ .Values.inventory.version }}"
              imagePullPolicy: {{ .Values.image.pullPolicy }}
              {{- include "nhi-scout.containerSecurityContext" $ | indent 14 }}
              args:
                - {{ .command }}
                {{- if .Values.inventory.log_level }}
                - --verbose={{ .Values.inventory.log_level }}
                {{- end}}
              resources: {{ toJson .Values.resources }}
              envFrom: {{ toJson .Values.envFrom }}
              env:
                - name: INVENTORY_CONFIG_PATH
                  value: /etc/inventory/config.yml
              {{- range .Values.env }}
                - {{ toJson . }}
              {{- end }}
              volumeMounts:
                - name: config
                  mountPath: /etc/inventory
                {{- range .Values.volumeMounts }}
                - {{ toJson . }}
                {{- end }}
          {{- with .Values.imagePullSecrets }}
          imagePullSecrets: {{ toJson . }}
          {{- end }}
          serviceAccountName: {{ include "nhi-scout.serviceAccountName" . }}
          {{- with .Values.nodeSelector }}
          nodeSelector: {{ toJson . }}
          {{- end }}
          {{- with .Values.affinity }}
          affinity: {{ toJson . }}
          {{- end }}
          {{- with .Values.tolerations }}
          tolerations: {{ toJson . }}
          {{- end }}
          restartPolicy: {{ .Values.restartPolicy }}

          volumes:
            - name: config
              configMap:
                name: {{ include "nhi-scout.fullname" . }}
            {{- range .Values.volumes }}
            - {{ toJson . }}
            {{- end }}
{{- end -}}
