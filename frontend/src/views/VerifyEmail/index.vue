<template>
  <section class="verify-email fill-height">
    <v-container fluid class="fill-height pa-0">
      <v-row class="fill-height ma-0" justify="center" align="center">
        <v-col cols="12" sm="12" md="10" lg="8" xl="6">
          <div class="content-wrapper">
            <!-- Logo -->
            <div class="text-center mb-4">
              <v-img src="/logo.png" alt="ThreeFold" width="48" height="48" class="mx-auto mb-4"></v-img>
            </div>
            
            <!-- Page Header -->
            <div class="text-center mb-6">
              <h1 class="page-title mb-2">
                ThreeFold Connect
              </h1>
              <p class="page-subtitle">
                Email Verification
              </p>
            </div>
            
            <v-card class="verify-card">

          <v-card-text class="text-center px-6 pb-8">
            <!-- Checking State -->
            <div v-if="store.emailVerificationStatus.checking">
              <v-progress-circular 
                :size="100" 
                :width="8" 
                color="primary" 
                indeterminate
                class="mb-4"
              ></v-progress-circular>
              <p class="text-body-1">
                Please wait while we validate your email address...
              </p>
            </div>

            <!-- Success State -->
            <div v-if="store.emailVerificationStatus.checked && store.emailVerificationStatus.valid">
              <v-icon :size="120" color="success" class="mb-4">mdi-check-circle</v-icon>
              <h2 class="text-h6 font-weight-bold mb-2">
                Email Verified!
              </h2>
              <p class="text-body-1 mb-6">
                Your email address has been successfully verified
              </p>
              <v-btn 
                v-if="isMobile" 
                color="primary" 
                variant="elevated"
                size="large"
                rounded="lg"
                @click="openApp"
                class="text-none font-weight-semibold"
              >
                <v-icon start>mdi-open-in-app</v-icon>
                Open ThreeFold Connect App
              </v-btn>
            </div>

            <!-- Error State -->
            <div v-if="store.emailVerificationStatus.checked && !store.emailVerificationStatus.valid">
              <v-icon :size="120" color="error" class="mb-4">mdi-close-circle</v-icon>
              <h2 class="text-h6 font-weight-bold mb-2">
                Verification Failed
              </h2>
              <p class="text-body-1 mb-4">
                There was a problem validating your email.
              </p>
              <v-alert
                type="error"
                variant="tonal"
                rounded="lg"
                class="mb-4 centered-icon-alert"
                density="compact"
                icon="mdi-alert-circle"
              >
                <div class="text-body-2">
                  If this problem persists, please contact support at<br>
                  <a href="https://support.grid.tf/" target="_blank" class="text-primary font-weight-medium">
                    support.grid.tf
                  </a>
                </div>
              </v-alert>
            </div>
          </v-card-text>

            </v-card>
            
            <!-- App Store Badges -->
            <div class="mt-8 text-center">
              <p class="app-badges-text mb-4">
                Don't have an account? Download the app to get started
              </p>
              <div class="d-flex justify-center align-center gap-3 flex-wrap">
                <a 
                  href="https://play.google.com/store/apps/details?id=org.jimber.threebotlogin" 
                  target="_blank"
                  class="app-badge"
                >
                  <img src="/googleplay.png" height="40" alt="Get it on Google Play" class="badge-img" />
                </a>
                <a 
                  href="https://itunes.apple.com/be/app/3bot-login/id1459845885?l=nl&mt=8" 
                  target="_blank"
                  class="app-badge"
                >
                  <img src="/applestore.png" height="40" alt="Download on the App Store" class="badge-img" />
                </a>
              </div>
            </div>
          </div>
        </v-col>
      </v-row>
    </v-container>
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useAppStore } from '@/stores/app'
import config from '@/config'

const route = useRoute()
const store = useAppStore()
const isMobile = ref(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))

onMounted(() => {
  store.validateEmail({
    userId: route.query.userId as string,
    verificationCode: route.query.verificationCode as string
  })
})

const openApp = () => {
  if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
    window.location.replace(`${config.deeplink}login/`)
  } else {
    window.location.href = `${config.deeplink}login/`
  }
}
</script>

<style src="./VerifyEmail.scss" scoped lang="scss"></style>
