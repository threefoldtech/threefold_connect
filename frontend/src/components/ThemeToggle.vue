<template>
  <v-btn
    :icon="currentTheme === 'dark' ? 'mdi-weather-sunny' : 'mdi-weather-night'"
    @click="toggleTheme"
    :aria-label="currentTheme === 'dark' ? 'Switch to light mode' : 'Switch to dark mode'"
    variant="text"
    color="primary"
    class="theme-toggle-btn"
  >
  </v-btn>
</template>

<script setup lang="ts">
import { useTheme } from '@/composables/useTheme'

const { currentTheme, toggleTheme } = useTheme()
</script>

<style scoped lang="scss">
.theme-toggle-btn {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  
  &:hover {
    transform: rotate(20deg);
  }
}
</style>
