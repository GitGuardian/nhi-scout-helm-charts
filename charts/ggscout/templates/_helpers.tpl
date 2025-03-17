{{/*
Expand the name of the chart.
*/}}
{{- define "ggscout.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ggscout.fullname" -}}
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
{{- define "ggscout.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ggscout.labels" -}}
helm.sh/chart: {{ include "ggscout.chart" . }}
{{ include "ggscout.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ggscout.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ggscout.name" . }}
app.kubernetes.io/component: {{ include "ggscout.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ggscout.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ggscout.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Security context
*/}}
{{- define "ggscout.securityContext" }}
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
{{- define "ggscout.containerSecurityContext" }}
{{- if .Values.securityContext.enabled }}
securityContext: {{- toYaml .Values.containerSecurityContext | nindent 2 }}
{{- end }}
{{- end }}

{{/*
Create the image path
{{ include "ggscout.image" }}
Image schema:
  image:
    registry: ""
    name: ""
    tag: ""
By default , concatenate values like this "<registry>/<name>:<tag>", but if global.imageRegistry is defined,
it will take precedence over registry defined in image.
*/}}
{{- define "ggscout.image" -}}
{{- $registry := .Values.image.registry -}}
{{- $name := .Values.image.name -}}
{{- $tag := (default .Chart.AppVersion .Values.image.tag) | toString -}}
{{- with .Values.global -}}
  {{- if .imageRegistry -}}
    {{- $registry = .imageRegistry -}}
  {{- end -}}
{{- end -}}
{{- if $registry -}}
  {{- $name = printf "%s/%s" $registry $name -}}
{{- end -}}
{{- if hasPrefix "sha256:" $tag -}}
  {{- printf "%s@%s" $name $tag -}}
{{- else -}}
  {{- printf "%s:%s" $name $tag -}}
{{- end -}}
{{- end -}}

{{/*
{{ include "ggscout.caBundle.image" }}
Return the proper ggscout caBundle image name.
Image schema:
  image:
    registry: ""
    name: ""
    tag: ""
By default , concatenate values like this "<registry>/<name>:<tag>", but if global.imageRegistry is defined,
it will take precedence over registry defined in image.
*/}}
{{- define "ggscout.caBundle.image" -}}
{{- $registry := .Values.caBundle.image.registry -}}
{{- $name := .Values.caBundle.image.name -}}
{{- $tag := (default .Chart.AppVersion .Values.caBundle.image.tag) | toString -}}
{{- with .Values.global -}}
  {{- if .imageRegistry -}}
    {{- $registry = .imageRegistry -}}
  {{- end -}}
{{- end -}}
{{- if $registry -}}
  {{- $name = printf "%s/%s" $registry $name -}}
{{- end -}}
{{- if hasPrefix "sha256:" $tag -}}
  {{- printf "%s@%s" $name $tag -}}
{{- else -}}
  {{- printf "%s:%s" $name $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names evaluating values as templates, and following these rules:
- Include all existing secret names defined in global.imagePullSecrets:
  global:
    imagePullSecrets:
      - name: pull-secret
      - name: another-pull-secret
- Include all existing secret names defined in each images parameters in .pullSecrets:
  image:
    pullSecrets:
      - name: image-pull-secret
Follow this guide in order to create docker secrets https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
Usage: {{ include "common.imagePullSecrets" ( dict "images" (list .Values.path.to.the.image1 .Values.path.to.the.image2) "context" $) }}
*/}}
{{- define "ggscout.common.imagePullSecrets" -}}
  {{- $pullSecrets := list }}
  {{- $context := .context }}

  {{- if $context.Values.global }}
    {{- range $context.Values.global.imagePullSecrets -}}
      {{- if kindIs "map" . -}}
        {{- $pullSecrets = append $pullSecrets (tpl .name $context) -}}
      {{- else -}}
        {{- $pullSecrets = append $pullSecrets (tpl . $context) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- if kindIs "map" . -}}
        {{- $pullSecrets = append $pullSecrets (tpl .name $context) -}}
      {{- else -}}
        {{- $pullSecrets = append $pullSecrets (tpl . $context) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets | uniq }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
imagePullSecrets
*/}}
{{- define "ggscout.imagePullSecrets" -}}
    {{ include "ggscout.common.imagePullSecrets" ( dict "images" (list $.Values.image) "context" $) }}
{{- end -}}
