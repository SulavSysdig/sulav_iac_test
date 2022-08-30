{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "custom-metrics.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "custom-metrics.fullname" -}}
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
{{- define "custom-metrics.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels for golang
*/}}
{{- define "custom-metrics.golang.labels" -}}
helm.sh/chart: {{ include "custom-metrics.chart" . }}
{{ include "custom-metrics.golang.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Selector labels for golang
*/}}
{{- define "custom-metrics.golang.selectorLabels" -}}
app.kubernetes.io/name: {{ include "custom-metrics.name" . }}-golang
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Common labels for java
*/}}
{{- define "custom-metrics.java.labels" -}}
helm.sh/chart: {{ include "custom-metrics.chart" . }}
{{ include "custom-metrics.java.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Selector labels for java
*/}}
{{- define "custom-metrics.java.selectorLabels" -}}
app.kubernetes.io/name: {{ include "custom-metrics.name" . }}-java
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Common labels for node
*/}}
{{- define "custom-metrics.node.labels" -}}
helm.sh/chart: {{ include "custom-metrics.chart" . }}
{{ include "custom-metrics.node.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Selector labels for node
*/}}
{{- define "custom-metrics.node.selectorLabels" -}}
app.kubernetes.io/name: {{ include "custom-metrics.name" . }}-node
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
Common labels for python
*/}}
{{- define "custom-metrics.python.labels" -}}
helm.sh/chart: {{ include "custom-metrics.chart" . }}
{{ include "custom-metrics.python.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Selector labels for python
*/}}
{{- define "custom-metrics.python.selectorLabels" -}}
app.kubernetes.io/name: {{ include "custom-metrics.name" . }}-python
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "custom-metrics.golang.image" -}}
{{- include "image_for_component" (dict "root" . "component" "golang") -}}
{{- end -}}


{{- define "custom-metrics.java.image" -}}
{{- include "image_for_component" (dict "root" . "component" "java") -}}
{{- end -}}

{{- define "custom-metrics.node.image" -}}
{{- include "image_for_component" (dict "root" . "component" "node") -}}
{{- end -}}

{{- define "custom-metrics.python.image" -}}
{{- include "image_for_component" (dict "root" . "component" "python") -}}
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