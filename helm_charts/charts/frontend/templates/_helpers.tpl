{{- define "frontend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "frontend.IMAGE" -}}
{{- .Values.global.FRONTEND_IMAGE -}}
{{- end -}}

{{- define "imagePullSecret" -}}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .Values.global.DOCKER_REGISTRY (printf "%s:%s" .Values.global.DOCKER_USERNAME .Values.global.DOCKER_PASSWORD | b64enc) | b64enc }}
{{- end }}
