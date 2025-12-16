<template>
  <section class="verify-email fill-height">
    <v-row justify="center" align="center" class="fill-height">
      <v-col cols="12" sm="10" md="8" lg="6" xl="5">
        <v-card class="modern-card">
          <div class="text-center pa-6 pb-4">
            <v-avatar size="80" class="mb-4">
              <v-img src="/logo.png" alt="ThreeFold Connect"></v-img>
            </v-avatar>
            <h1 class="text-h5 font-weight-bold mb-2">
              Email Verification
            </h1>
            <p class="text-body-2">
              Verifying your email address
            </p>
          </div>

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
                class="mb-4"
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

          <!-- App Store Badges -->
          <div class="text-center pb-6">
            <p class="text-body-2 mb-3">
              Don't have the app yet?
            </p>
            <div class="d-flex justify-center gap-3">
              <a 
                href="https://play.google.com/store/apps/details?id=org.jimber.threebotlogin" 
                target="_blank"
              >
                <img src="/googleplay.png" height="48" alt="Get it on Google Play" style="border-radius: 8px;" />
              </a>
              <a 
                href="https://itunes.apple.com/be/app/3bot-login/id1459845885?l=nl&mt=8" 
                target="_blank"
              >
                <img src="/applestore.png" height="48" alt="Download on the App Store" style="border-radius: 8px;" />
              </a>
            </div>
          </div>
        </v-card>
      </v-col>
    </v-row>
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
  window.location.href = `${config.deeplink}`
}
</script>

<style src="./VerifyEmail.scss" scoped lang="scss"></style>
