{{- define "frontend.FULL_NAME" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "frontend" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "frontend.IMAGE" -}}
{{- .Values.global.FRONTEND_IMAGE -}}
{{- end -}}
