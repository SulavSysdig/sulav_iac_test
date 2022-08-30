{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "grafana-sysdig.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana-sysdig.fullname" -}}
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
{{- define "grafana-sysdig.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "grafana-sysdig.labels" -}}
helm.sh/chart: {{ include "grafana-sysdig.chart" . }}
{{ include "grafana-sysdig.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "grafana-sysdig.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grafana-sysdig.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "grafana-sysdig.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "grafana-sysdig.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "grafana-sysdig.image" -}}
{{- if .Values.image.overrideValue -}}
    {{- .Values.image.overrideValue -}}
{{- else -}}
    {{- $imageRegistry := .Values.image.registry -}}
    {{- $imageRepository := .Values.image.repository -}}
    {{- $imageTag := .Values.image.tag -}}
    {{- $globalRegistry := (default .Values.global dict).imageRegistry -}}
    {{- $globalRegistry | default $imageRegistry | default "docker.io" -}} / {{- $imageRepository -}} : {{- $imageTag -}}
{{- end -}}
{{- end -}}

{{- define "grafana-sysdig.busybox" -}}
{{- if .Values.busybox.image.overrideValue -}}
    {{- .Values.busybox.image.overrideValue -}}
{{- else -}}
    {{- $imageRegistry := .Values.busybox.image.registry -}}
    {{- $imageRepository := .Values.busybox.image.repository -}}
    {{- $imageTag := .Values.busybox.image.tag -}}
    {{- $globalRegistry := (default .Values.global dict).imageRegistry -}}
    {{- $globalRegistry | default $imageRegistry | default "docker.io" -}} / {{- $imageRepository | default "busybox" -}} : {{- $imageTag | default "1.31.1" -}}
{{- end -}}
{{- end -}}