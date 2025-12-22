<template>
  <v-app class="app-background">
    <div class="background-overlay"></div>
    
    <v-main class="fill-height">
      <router-view/>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
import { onErrorCaptured } from 'vue'
import { useSocket } from '@/composables/useSocket'

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
  background-image: url('/map2_blur.png');
  background-repeat: no-repeat;
  background-position: center center;
  background-size: cover;
  background-attachment: fixed;
  position: relative;
}

.background-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.31);
  backdrop-filter: blur(2px);
  pointer-events: none;
  z-index: 0;
}

.background-overlay::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, rgba(0, 0, 0, 0.4) 0%, transparent 50%, rgba(0, 0, 0, 0.6) 100%);
}

.top-logo {
  position: fixed;
  top: 1.5rem;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1000;
}

.v-main {
  position: relative;
  z-index: 1;
}
</style>
