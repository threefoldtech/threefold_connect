<template>
  <v-app class="app-background">
    <div class="overlay primary darken-2"></div>
    
    <div class="theme-toggle-wrapper">
      <ThemeToggle />
    </div>
    
    <v-main class="fill-height">
      <v-container>
        <router-view/>
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { onErrorCaptured, onMounted } from 'vue'
import { useSocket } from '@/composables/useSocket'
import { useTheme } from '@/composables/useTheme'
import ThemeToggle from '@/components/ThemeToggle.vue'

// Initialize theme on app mount
const { currentTheme } = useTheme()

// Set up socket listeners with proper cleanup
useSocket()

// Global error boundary
onErrorCaptured((err, instance, info) => {
  console.error('Component error caught:', err)
  console.error('Error info:', info)
  console.error('Component instance:', instance)
  
  // Prevent error from propagating and crashing the app
  return false
})
</script>

<style scoped>
.app-background {
  background-image: url('/map.png');
  background-repeat: no-repeat;
  background-position: center center;
  background-size: cover;
  background-attachment: fixed;
}

.theme-toggle-wrapper {
  position: fixed;
  top: 1rem;
  right: 1rem;
  z-index: 1000;
}
</style>
