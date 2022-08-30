{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sock-shop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sock-shop.fullname" -}}
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
{{- define "sock-shop.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sock-shop.serviceAccountName" -}}
    {{ include "sock-shop.fullname" . }}
{{- end -}}




{{/*
Common labels for services and deployments
*/}}
{{- define "sock-shop.common.labels" -}}
helm.sh/chart: {{ include "sock-shop.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/*
Selector labels for carts-db
*/}}
{{- define "sock-shop.carts-db.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-carts-db
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.carts-db.image" -}}
{{- include "image_for_component" (dict "root" . "component" "cartsdb") -}}
{{- end -}}


{{/*
Selector labels for carts
*/}}
{{- define "sock-shop.carts.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-carts
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for carts
*/}}
{{- define "sock-shop.carts.annotations" -}}
{{- if .Values.carts.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.carts.prometheus.port | quote }}
{{- if .Values.carts.prometheus.path }}
prometheus.io/path: {{ .Values.carts.prometheus.path | quote }}
{{- end -}}{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.carts.image" -}}
{{- include "image_for_component" (dict "root" . "component" "carts") -}}
{{- end -}}

{{/*
Selector labels for catalogue-db
*/}}
{{- define "sock-shop.catalogue-db.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-catalogue-db
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.catalogue-db.image" -}}
{{- include "image_for_component" (dict "root" . "component" "cataloguedb") -}}
{{- end -}}

{{/*
Selector labels for catalogue
*/}}
{{- define "sock-shop.catalogue.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-catalogue
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for catalogue
*/}}
{{- define "sock-shop.catalogue.annotations" -}}
{{- if .Values.catalogue.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.catalogue.prometheus.port | quote }}
{{- if .Values.catalogue.prometheus.path }}
prometheus.io/path: {{ .Values.catalogue.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.catalogue.image" -}}
{{- include "image_for_component" (dict "root" . "component" "catalogue") -}}
{{- end -}}

{{/*
Selector labels for front-end
*/}}
{{- define "sock-shop.front-end.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-front-end
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for front-end
*/}}
{{- define "sock-shop.front-end.annotations" -}}
{{- if .Values.frontend.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.frontend.prometheus.port | quote }}
{{- if .Values.frontend.prometheus.path }}
prometheus.io/path: {{ .Values.frontend.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.front-end.image" -}}
{{- include "image_for_component" (dict "root" . "component" "frontend") -}}
{{- end -}}


{{/*
Selector labels for front-end-external
*/}}
{{- define "sock-shop.front-end-external.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-front-end-external
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels for orders-db
*/}}
{{- define "sock-shop.orders-db.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-orders-db
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.orders-db.image" -}}
{{- include "image_for_component" (dict "root" . "component" "ordersdb") -}}
{{- end -}}

{{/*
Selector labels for orders
*/}}
{{- define "sock-shop.orders.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-orders
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for orders
*/}}
{{- define "sock-shop.orders.annotations" -}}
{{- if .Values.orders.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.orders.prometheus.port | quote }}
{{- if .Values.orders.prometheus.path }}
prometheus.io/path: {{ .Values.orders.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.orders.image" -}}
{{- include "image_for_component" (dict "root" . "component" "orders") -}}
{{- end -}}

{{/*
Selector labels for payment
*/}}
{{- define "sock-shop.payment.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-payment
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for payment
*/}}
{{- define "sock-shop.payment.annotations" -}}
{{- if .Values.payment.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.payment.prometheus.port | quote }}
{{- if .Values.payment.prometheus.path }}
prometheus.io/path: {{ .Values.payment.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.payment.image" -}}
{{- include "image_for_component" (dict "root" . "component" "payment") -}}
{{- end -}}

{{/*
Selector labels for queue-master
*/}}
{{- define "sock-shop.queue-master.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-queue-master
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for queuemaster
*/}}
{{- define "sock-shop.queue-master.annotations" -}}
{{- if .Values.queuemaster.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.queuemaster.prometheus.port | quote }}
{{- if .Values.queuemaster.prometheus.path }}
prometheus.io/path: {{ .Values.queuemaster.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.queue-master.image" -}}
{{- include "image_for_component" (dict "root" . "component" "queuemaster") -}}
{{- end -}}

{{/*
Selector labels for rabbitmq
*/}}
{{- define "sock-shop.rabbitmq.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-rabbitmq
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.rabbitmq.image" -}}
{{- include "image_for_component" (dict "root" . "component" "rabbitmq") -}}
{{- end -}}

{{/*
Selector labels for shipping
*/}}
{{- define "sock-shop.shipping.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-shipping
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for shipping
*/}}
{{- define "sock-shop.shipping.annotations" -}}
{{- if .Values.shipping.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.shipping.prometheus.port | quote }}
{{- if .Values.shipping.prometheus.path }}
prometheus.io/path: {{ .Values.shipping.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.shipping.image" -}}
{{- include "image_for_component" (dict "root" . "component" "shipping") -}}
{{- end -}}

{{/*
Selector labels for user-db
*/}}
{{- define "sock-shop.user-db.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-user-db
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.user-db.image" -}}
{{- include "image_for_component" (dict "root" . "component" "userdb") -}}
{{- end -}}

{{/*
Selector labels for user
*/}}
{{- define "sock-shop.user.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-user
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
{{/*
Annotations for user
*/}}
{{- define "sock-shop.user.annotations" -}}
{{- if .Values.user.prometheus.active }}
prometheus.io/scrape: 'true'
prometheus.io/port: {{ .Values.user.prometheus.port | quote }}
{{- if .Values.user.prometheus.path }}
prometheus.io/path: {{ .Values.user.prometheus.path | quote }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.user.image" -}}
{{- include "image_for_component" (dict "root" . "component" "user") -}}
{{- end -}}


{{/*
Selector labels for loadgenerator
*/}}
{{- define "sock-shop.loadgenerator.labels" -}}
app.kubernetes.io/name: {{ include "sock-shop.name" . }}-loadgenerator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Allow overriding registry and repository for air-gapped environments
*/}}
{{- define "sock-shop.loadgenerator.image" -}}
{{- include "image_for_component" (dict "root" . "component" "loadgenerator") -}}
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