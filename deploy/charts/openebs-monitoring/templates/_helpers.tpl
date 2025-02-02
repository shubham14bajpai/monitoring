{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "openebs-monitoring.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "openebs-monitoring.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 26 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "openebs-monitoring.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "openebs-monitoring.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "openebs-monitoring.labels" -}}
helm.sh/chart: {{ include "openebs-monitoring.chart" . }}
{{ include "openebs-monitoring.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "openebs-monitoring.selectorLabels" -}}
app.kubernetes.io/name: {{ include "openebs-monitoring.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
release: {{ $.Release.Name | quote }}
{{- end }}

{{/*
Template to support multiple levels of sub-charts

Call a template from the context of a subchart.

Usage:
  {{ include "call-nested" (list . "<subchart_name>" "<subchart_template_name>") }}
*/}}
{{- define "call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 | splitList "." }}
{{- $template := index . 2 }}
{{- $values := $dot.Values }}
{{- range $subchart }}
{{- $values = index $values . }}
{{- end }}
{{- include $template (dict "Chart" (dict "Name" (last $subchart)) "Values" $values "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}


{{/* 
grafana sidecar dashboards label
*/}}
{{- define "grafana-sidecar-dashboards.label" }}
{{- if and (index .Values "kube-prometheus-stack" "install") (index .Values "kube-prometheus-stack" "grafana" "sidecar" "dashboards" "enabled") }}
{{- $grafanaSidecarDashboardsLabel:= index .Values "kube-prometheus-stack" "grafana" "sidecar" "dashboards" "label" }}
{{- printf $grafanaSidecarDashboardsLabel }}
{{- else if and (.Values.openebsMonitoringAddon.enabled) (.Values.openebsMonitoringAddon.grafana.sidecar.dashboards.enabled )}}
{{- $grafanaSidecarDashboardsLabel:= .Values.openebsMonitoringAddon.grafana.sidecar.dashboards.label }}
{{- printf $grafanaSidecarDashboardsLabel }}
{{- end }}
{{- end }}