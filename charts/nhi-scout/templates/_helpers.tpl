{{/*
Expand the name of the chart.
*/}}
{{- define "nhi-scout.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nhi-scout.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nhi-scout.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nhi-scout.labels" -}}
helm.sh/chart: {{ include "nhi-scout.chart" . }}
{{ include "nhi-scout.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nhi-scout.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nhi-scout.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nhi-scout.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nhi-scout.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Security context
*/}}
{{- define "nhi-scout.securityContext" }}
{{- if .Values.securityContext.enabled }}
{{/* uid for chainguard images */}}{{- $uid := 65532 }}
securityContext:
  fsGroup: {{ .Values.securityContext.fsGroup | default $uid }}
  runAsUser: {{ .Values.securityContext.runAsUser | default $uid }}
  runAsGroup: {{  .Values.securityContext.runAsGroup | default $uid }}
  runAsNonRoot: {{ .Values.securityContext.runAsNonRoot }}
{{- end }}
{{- end }}

{{/*
Container security context for backend deployments
*/}}
{{- define "nhi-scout.containerSecurityContext" }}
{{- if .Values.securityContext.enabled }}
securityContext: {{- toYaml .Values.containerSecurityContext | nindent 2 }}
{{- end }}
{{- end }}