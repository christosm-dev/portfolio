{{/*
Expand the name of the chart.
*/}}
{{- define "flask-tasks.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec). If the release name already contains the chart name,
we use it as-is to avoid duplication (e.g. "flask-tasks-flask-tasks").
*/}}
{{- define "flask-tasks.fullname" -}}
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
Create chart label — used in the helm.sh/chart annotation to record which
chart version deployed a resource.
*/}}
{{- define "flask-tasks.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to every resource.
*/}}
{{- define "flask-tasks.labels" -}}
helm.sh/chart: {{ include "flask-tasks.chart" . }}
{{ include "flask-tasks.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels — used by the Deployment selector and the Service selector.
These must remain stable across upgrades; changing them forces pod recreation.
*/}}
{{- define "flask-tasks.selectorLabels" -}}
app.kubernetes.io/name: {{ include "flask-tasks.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
The fully-qualified image reference, combining repository and tag.
Falls back to .Chart.AppVersion when values.image.tag is empty — this keeps
the chart self-contained while still allowing explicit pinning in production.
*/}}
{{- define "flask-tasks.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s:%s" .Values.image.repository $tag }}
{{- end }}
