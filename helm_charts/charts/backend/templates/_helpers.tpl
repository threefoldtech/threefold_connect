{{- define "backend.FULL_NAME" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "backend.IMAGE" -}}
{{- .Values.global.BACKEND_IMAGE -}}
{{- end -}}

{{- define "backend.FLAGSMITH_API_KEY" -}}
{{- .Values.global.FLAGSMITH_API_KEY -}}
{{- end -}}


{{- define "backend.DATABASE_URL" -}}
{{- .Values.global.DATABASE_URL -}}
{{- end -}}
