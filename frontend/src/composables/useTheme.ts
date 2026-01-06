import { ref, watch } from 'vue'
import { useTheme as useVuetifyTheme } from 'vuetify'

const THEME_STORAGE_KEY = 'threefold-theme'

export function useTheme() {
  const vuetifyTheme = useVuetifyTheme()
  
  // Initialize from localStorage or default to 'light'
  const savedTheme = localStorage.getItem(THEME_STORAGE_KEY) as 'light' | 'dark' | null
  const currentTheme = ref<'light' | 'dark'>(savedTheme || 'light')
  
  // Set initial theme
  vuetifyTheme.global.name.value = currentTheme.value
  
  // Watch for theme changes and persist to localStorage
  watch(currentTheme, (newTheme) => {
    vuetifyTheme.global.name.value = newTheme
    localStorage.setItem(THEME_STORAGE_KEY, newTheme)
  })
  
  const toggleTheme = () => {
    currentTheme.value = currentTheme.value === 'light' ? 'dark' : 'light'
  }
  
  const setTheme = (theme: 'light' | 'dark') => {
    currentTheme.value = theme
  }
  
  const isDark = () => currentTheme.value === 'dark'
  
  return {
    currentTheme,
    toggleTheme,
    setTheme,
    isDark
  }
}
