{{- define "backend.fullname" -}}
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


{{- define "imagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.DOCKER_REGISTRY (printf "%s:%s" .Values.global.DOCKER_USERNAME .Values.global.DOCKER_PASSWORD | b64enc) | b64enc }}
{{- end }}
