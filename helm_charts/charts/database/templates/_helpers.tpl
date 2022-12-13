{{- define "database.FULL_NAME" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "database" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "database.DATABASE_PASSWORD" -}}
{{- .Values.global.DATABASE_PASSWORD -}}
{{- end -}}
