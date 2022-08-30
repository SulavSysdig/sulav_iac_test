{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "usercount.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "usercount.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "usercount.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "usercount.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "usercount.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Common labels for prometheus
*/}}
{{- define "usercount.prometheus.labels" -}}
helm.sh/chart: {{ include "usercount.chart" . }}
{{ include "usercount.prometheus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels for prometheus
*/}}
{{- define "usercount.prometheus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "usercount.name" . }}-prometheus
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "usercount.prometheus.image" -}}
{{- include "image_for_component" (dict "root" . "component" "prometheus") -}}
{{- end -}}

{{/*
Common labels for usercount
*/}}
{{- define "usercount.usercount.labels" -}}
helm.sh/chart: {{ include "usercount.chart" . }}
{{ include "usercount.usercount.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels for usercount
*/}}
{{- define "usercount.usercount.selectorLabels" -}}
app.kubernetes.io/name: {{ include "usercount.name" . }}-usercount
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "usercount.usercount.image" -}}
{{- include "image_for_component" (dict "root" . "component" "usercount") -}}
{{- end -}}

{{/* 
Use like: {{ include "define_component_image" (dict "root" . "component" "<component_name>" }}
*/}}
{{- define "image_for_component" -}}
{{- $overrideValue := tpl (printf "{{- .Values.%s.image.overrideValue -}}" .component) .root }}
{{- if $overrideValue }}
    {{- $overrideValue -}}
{{- else -}}
    {{- $imageRegistry := tpl (printf "{{- .Values.%s.image.registry -}}" .component) .root -}}
    {{- $imageRepository := tpl (printf "{{- .Values.%s.image.repository -}}" .component) .root -}}
    {{- $imageTag := tpl (printf "{{- .Values.%s.image.tag -}}" .component) .root -}}
    {{- $globalRegistry := (default .root.Values.global dict).imageRegistry -}}
    {{- $globalRegistry | default $imageRegistry | default "docker.io" -}} / {{- $imageRepository -}} : {{- $imageTag -}}
{{- end -}}
{{- end -}}