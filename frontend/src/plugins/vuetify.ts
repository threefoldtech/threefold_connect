import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'

export default createVuetify({
  components,
  directives,
  theme: {
    defaultTheme: 'dark',
    themes: {
      light: {
        dark: false,
        colors: {
          primary: '#1AA18F',
          secondary: '#2C3E50',
          accent: '#1AA18F',
          error: '#EF5350',
          warning: '#FFC107',
          info: '#42A5F5',
          success: '#66BB6A',
          background: '#F8FAFB',
          surface: '#FFFFFF',
          'surface-variant': '#F5F7FA',
          'on-primary': '#FFFFFF',
          'on-secondary': '#FFFFFF',
          'on-surface': '#1E293B',
          'on-background': '#1E293B'
        }
      },
      dark: {
        dark: true,
        colors: {
          primary: '#1AA18F',
          secondary: '#34495E',
          accent: '#1AA18F',
          error: '#EF5350',
          warning: '#FFC107',
          info: '#42A5F5',
          success: '#66BB6A',
          background: '#0F172A',
          surface: '#1E293B',
          'surface-variant': '#334155',
          'on-primary': '#FFFFFF',
          'on-secondary': '#FFFFFF',
          'on-surface': '#F1F5F9',
          'on-background': '#F1F5F9'
        }
      }
    }
  },
  defaults: {
    VBtn: {
      style: 'text-transform: none; letter-spacing: 0;',
      rounded: 'lg',
      elevation: 0
    },
    VCard: {
      rounded: 'xl',
      elevation: 0,
      style: 'border: 1px solid rgba(0,0,0,0.06);'
    },
    VTextField: {
      variant: 'outlined',
      rounded: 'lg',
      color: 'primary'
    },
    VToolbar: {
      rounded: 'xl',
      elevation: 0
    }
  }
})
