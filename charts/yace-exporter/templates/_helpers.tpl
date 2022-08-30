{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "yace-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "yace-exporter.fullname" -}}
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
{{- define "yace-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels for all the entities
*/}}
{{- define "yace-exporter.common.labels" -}}
helm.sh/chart: {{ include "yace-exporter.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
labels matching
*/}}
{{- define "yace-exporter.labels" -}}
app.kubernetes.io/name: {{ include "yace-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "yace-exporter.image" -}}
{{- .Values.image.registry -}} / {{- .Values.image.repository -}} : {{- .Values.image.tag -}}
{{- end -}}

{{/*
Annotations for prometheus service discovery
*/}}
{{- define "yace-exporter.annotations" -}}
{{- if .Values.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.prometheus.port | quote }}
{{- if .Values.prometheus.path }}
prometheus.io/path: {{ .Values.prometheus.path | quote }}
{{- end -}}{{- end -}}
{{- end -}}
