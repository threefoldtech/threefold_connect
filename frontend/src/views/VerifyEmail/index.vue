<template>
  <section class="verify-email">
    <v-row justify="center">
      <v-col cols="12" md="8">
        <v-card>
          <v-toolbar color="primary">
            <v-toolbar-title class="text-h5 text-white">Verifying email address</v-toolbar-title>
          </v-toolbar>
          <v-card-text>
            <v-row v-if="store.emailVerificationStatus.checking" align="center" justify="center">
              <v-col cols="12" class="text-center">
                <v-progress-circular :size="100" :width="15" color="accent" indeterminate></v-progress-circular>
                <p class="text-subtitle-1 pt-3">Please wait while we validate your email address</p>
              </v-col>
            </v-row>
            <v-row v-if="store.emailVerificationStatus.checked && store.emailVerificationStatus.valid" align="center" justify="center">
              <v-col cols="12" class="text-center">
                <v-icon :size="100" color="accent">mdi-check-circle</v-icon>
                <p class="text-subtitle-1 pt-3">Email validated</p>
                <v-btn v-if="isMobile" color="accent" @click="openApp">Open TF Connect app</v-btn>
              </v-col>
            </v-row>
            <v-row v-if="store.emailVerificationStatus.checked && !store.emailVerificationStatus.valid" align="center" justify="center">
              <v-col cols="12" class="text-center">
                <v-icon :size="100" color="error">mdi-close</v-icon>
                <p class="text-subtitle-1 pt-3">There was a problem validating your email,<br>please contact support if this problem persists.<br><a href="https://support.grid.tf/">https://support.grid.tf/</a></p>
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAppStore } from '@/stores/app'
import config from '@/config'

const store = useAppStore()
const isMobile = ref(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))

const openApp = () => {
  window.location.href = `${config.deeplink}`
}
</script>

<style src="./VerifyEmail.scss" scoped lang="scss"></style>
