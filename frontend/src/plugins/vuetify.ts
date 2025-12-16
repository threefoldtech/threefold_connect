import 'vuetify/styles'
import '@mdi/font/css/materialdesignicons.css'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { aliases, mdi } from 'vuetify/iconsets/mdi'

export default createVuetify({
  components,
  directives,
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi,
    },
  },
  theme: {
    defaultTheme: 'light',
    themes: {
      light: {
        dark: false,
        colors: {
          primary: '#1AA18F',
          secondary: '#64748B',
          accent: '#14B8A6',
          error: '#EF4444',
          warning: '#F59E0B',
          info: '#3B82F6',
          success: '#10B981',
          background: '#FFFFFF',
          surface: '#FFFFFF',
          'surface-variant': '#F8FAFC',
          'surface-bright': '#FFFFFF',
          'on-primary': '#FFFFFF',
          'on-secondary': '#FFFFFF',
          'on-surface': '#0F172A',
          'on-background': '#0F172A',
          'on-surface-variant': '#475569'
        }
      },
      dark: {
        dark: true,
        colors: {
          primary: '#14B8A6',
          secondary: '#64748B',
          accent: '#2DD4BF',
          error: '#F87171',
          warning: '#FBBF24',
          info: '#60A5FA',
          success: '#34D399',
          background: '#0F172A',
          surface: '#1E293B',
          'surface-variant': '#334155',
          'surface-bright': '#475569',
          'on-primary': '#FFFFFF',
          'on-secondary': '#F1F5F9',
          'on-surface': '#F1F5F9',
          'on-background': '#F1F5F9',
          'on-surface-variant': '#CBD5E1'
        }
      }
    }
  },
  defaults: {
    VBtn: {
      style: [
        'text-transform: none',
        'letter-spacing: 0',
        'font-weight: 600',
        'transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1)'
      ].join(';'),
      rounded: 'lg',
      elevation: 0
    },
    VCard: {
      rounded: 'xl',
      elevation: 2,
      style: 'transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1)'
    },
    VTextField: {
      variant: 'outlined',
      rounded: 'lg',
      color: 'primary',
      density: 'comfortable'
    },
    VTextarea: {
      variant: 'outlined',
      rounded: 'lg',
      color: 'primary'
    },
    VSelect: {
      variant: 'outlined',
      rounded: 'lg',
      color: 'primary'
    },
    VAutocomplete: {
      variant: 'outlined',
      rounded: 'lg',
      color: 'primary'
    },
    VAlert: {
      rounded: 'lg',
      density: 'comfortable'
    },
    VToolbar: {
      rounded: 'xl',
      elevation: 0
    },
    VAvatar: {
      style: 'transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1)'
    }
  }
})
