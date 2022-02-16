

{{- define "releaseName" -}}
{{ $.Chart.Name}}-{{.Values.environment }}
{{- end -}}
