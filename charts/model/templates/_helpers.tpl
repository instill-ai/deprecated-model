{{/*
Expand the name of the chart.
*/}}
{{- define "model.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "model.fullname" -}}
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
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "model.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "model.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "model.labels" -}}
app.kubernetes.io/name: {{ include "model.name" . }}
helm.sh/chart: {{ include "model.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | replace "+" "_" }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{/*
MatchLabels
*/}}
{{- define "model.matchLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/name: {{ include "model.name" . }}
{{- end -}}

{{- define "model.autoGenCert" -}}
  {{- if and .Values.expose.tls.enabled (eq .Values.expose.tls.certSource "auto") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "model.autoGenCertForIngress" -}}
  {{- if and (eq (include "model.autoGenCert" .) "true") (eq .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "core.database.host" -}}
    {{- template "core.database" . -}}
{{- end -}}

{{- define "core.database.port" -}}
    {{- print "5432" -}}
{{- end -}}

{{- define "core.database.username" -}}
    {{- print "postgres" -}}
{{- end -}}

{{- define "core.database.rawPassword" -}}
    {{- print "password" -}}
{{- end -}}

/*host:port*/
{{- define "core.redis.addr" -}}
  {{- with .Values.redis -}}
    {{- default (printf "%s:6379" (include "core.redis" $ )) .addr -}}
  {{- end -}}
{{- end -}}

{{- define "core.mgmtBackend" -}}
  {{- print "core-mgmt-backend" -}}
{{- end -}}

{{- define "model.modelBackend" -}}
  {{- printf "%s-model-backend" (include "model.fullname" .) -}}
{{- end -}}

{{- define "model.controllerModel" -}}
  {{- printf "%s-controller-model" (include "model.fullname" .) -}}
{{- end -}}

{{- define "model.triton" -}}
  {{- printf "%s-triton-inference-server" (include "model.fullname" .) -}}
{{- end -}}

{{- define "model.kuberay-operator" -}}
  {{- printf "%s-kuberay-operator" (include "model.fullname" .) -}}
{{- end -}}

{{- define "model.ray-service" -}}
  {{- printf "%s-ray" (include "model.fullname" .) -}}
{{- end -}}

{{- define "model.ray" -}}
  {{- printf "%s-ray-head-svc" (include "model.fullname" .) -}}
{{- end -}}

{{- define "core.database" -}}
  {{- print "core-database" -}}
{{- end -}}

{{- define "core.redis" -}}
  {{- print "core-redis" -}}
{{- end -}}

{{- define "core.temporal" -}}
  {{- printf "core-temporal" -}}
{{- end -}}

{{- define "core.etcd" -}}
  {{- printf "core-etcd" -}}
{{- end -}}

{{/* model-backend service and container public port */}}
{{- define "model.modelBackend.publicPort" -}}
  {{- printf "8083" -}}
{{- end -}}

{{/* model-backend service and container private port */}}
{{- define "model.modelBackend.privatePort" -}}
  {{- printf "3083" -}}
{{- end -}}

{{/* controller-model service and container private port */}}
{{- define "model.controllerModel.privatePort" -}}
  {{- printf "3086" -}}
{{- end -}}

{{/* mgmt-backend service and container public port */}}
{{- define "core.mgmtBackend.publicPort" -}}
  {{- printf "8084" -}}
{{- end -}}

{{/* mgmt-backend service and container private port */}}
{{- define "core.mgmtBackend.privatePort" -}}
  {{- printf "3084" -}}
{{- end -}}

{{- define "model.triton.httpPort" -}}
  {{- printf "8000" -}}
{{- end -}}

{{- define "model.triton.grpcPort" -}}
  {{- printf "8001" -}}
{{- end -}}

{{- define "model.triton.metricsPort" -}}
  {{- printf "8002" -}}
{{- end -}}

{{- define "model.ray.clientPort" -}}
  {{- printf "10001" -}}
{{- end -}}

{{- define "model.ray.dashboardPort" -}}
  {{- printf "8265" -}}
{{- end -}}

{{- define "model.ray.gcsPort" -}}
  {{- printf "6379" -}}
{{- end -}}

{{- define "model.ray.servePort" -}}
  {{- printf "8000" -}}
{{- end -}}

{{- define "model.ray.serveGrpcPort" -}}
  {{- printf "9000" -}}
{{- end -}}

{{- define "model.ray.prometheusPort" -}}
  {{- printf "8079" -}}
{{- end -}}

{{/* temporal container frontend gRPC port */}}
{{- define "core.temporal.frontend.grpcPort" -}}
  {{- printf "7233" -}}
{{- end -}}

{{/* etcd port */}}
{{- define "core.etcd.clientPort" -}}
  {{- printf "2379" -}}
{{- end -}}

{{- define "core.influxdb" -}}
  {{- printf "core-influxdb2" -}}
{{- end -}}

{{- define "core.influxdb.port" -}}
  {{- printf "8086" -}}
{{- end -}}

{{- define "core.jaeger" -}}
  {{- printf "core-jaeger-collector" -}}
{{- end -}}

{{- define "core.jaeger.port" -}}
  {{- printf "14268" -}}
{{- end -}}

{{- define "core.otel" -}}
  {{- printf "core-opentelemetry-collector" -}}
{{- end -}}

{{- define "core.otel.port" -}}
  {{- printf "8095" -}}
{{- end -}}

{{- define "model.internalTLS.modelBackend.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.modelBackend.secretName -}}
  {{- else -}}
    {{- printf "%s-model-backend-internal-tls" (include "model.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{- define "model.internalTLS.controllerModel.secretName" -}}
  {{- if eq .Values.internalTLS.certSource "secret" -}}
    {{- .Values.internalTLS.controllerModel.secretName -}}
  {{- else -}}
    {{- printf "%s-controller-model-internal-tls" (include "model.fullname" .) -}}
  {{- end -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "model.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.expose.ingress.kubeVersionOverride -}}
{{- end -}}
