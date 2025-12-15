<template>
  <v-app>
    <div class="overlay primary darken-2"></div>
    <v-main class="fill-height">
      <v-container>
        <router-view/>
      </v-container>
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
