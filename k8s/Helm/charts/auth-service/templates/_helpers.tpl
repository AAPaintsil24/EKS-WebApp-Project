{{- define "auth-service.name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "auth-service.image" -}}
{{- .Values.image -}}
{{- end -}}