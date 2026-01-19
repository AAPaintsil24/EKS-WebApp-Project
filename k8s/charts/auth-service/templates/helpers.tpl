{{- define "name" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}


{{- define "image"-}}
{{- printf "%s" .Values.image -}}
{{- end -}}