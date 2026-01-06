<template>
  <section class="login fill-height">
    <v-container fluid class="fill-height pa-0">
      <v-row class="fill-height ma-0" justify="center" align="center">
      <v-col cols="12" sm="12" md="10" lg="8" xl="6">
        <div class="content-wrapper">
          <!-- Logo -->
          <div class="text-center mb-4">
            <v-img src="/logo.png" alt="ThreeFold" width="48" height="48" class="mx-auto mb-4"></v-img>
          </div>
          
          <!-- Page Header -->
          <div class="text-center page-header">
      <h1 class="page-title mb-2">
        ThreeFold Connect
      </h1>
      <p class="page-subtitle">
        Secure Two-Factor Authentication
      </p>
          </div>
          
          <!-- Login In Progress Card -->
        <v-card v-if="store.loginTimeleft > 0 && !loggedIn" class="login-card">
          <v-card-text class="text-center pa-8">
            <h2 class="login-title mb-6">
              Signing in...
            </h2>
            
            <p class="login-instruction mb-6">
              Please open the ThreeFold Connect app on your mobile device, authenticate either with pin or Touch ID, and then match the following icon from the choices given.
            </p>
            
            <!-- Random Emoji Icon -->
            <div class="biometric-container mb-6">
              <div class="biometric-circle">
                <img v-if="!loggedIn" :src="`/icons/${store.randomImageId}.png`" height="48" alt="Select this icon" />
                <v-icon v-else size="48" color="#14B8A6">mdi-check</v-icon>
              </div>
            </div>
            
            <p class="timer-text mb-4">
              Please enter your pincode or use fingerprint and select this icon on your mobile phone.
            </p>
            
            <p class="countdown-text mb-6">
              Your login attempt is valid for another <strong>{{ store.loginTimeleft }} seconds.</strong>
            </p>
            
            <!-- Resend Button -->
            <v-btn
              v-if="!store.firstTime && !isMobile"
              color="primary"
              variant="flat"
              size="large"
              rounded="lg"
              block
              @click="triggerResendNotification"
              class="resend-btn text-none"
            >
              <v-icon start size="20">mdi-refresh</v-icon>
              RESEND NOTIFICATION
            </v-btn>
            
            <v-btn
              v-if="isMobile"
              color="primary"
              variant="flat"
              size="large"
              rounded="lg"
              block
              @click="openApp"
              class="resend-btn text-none"
            >
              <v-icon start>mdi-open-in-app</v-icon>
              Open ThreeFold Connect App
            </v-btn>
          </v-card-text>
        </v-card>

        <!-- Success State -->
        <v-card v-else-if="loggedIn" class="success-card">
          <v-card-text class="text-center pa-8">
            <v-icon :size="55" color="#14B8A6" class="mb-4">mdi-check-circle</v-icon>
            <h2 class="success-title mb-2">
              Login Successful!
            </h2>
            <p class="success-text mb-4">
              Redirecting you now...
            </p>
            <v-progress-linear indeterminate color="#14B8A6" class="mt-4"></v-progress-linear>
          </v-card-text>
        </v-card>

        <!-- Expired State -->
        <v-card v-else class="expired-card">
          <v-card-text class="text-center pa-8">
            <v-icon :size="55" color="#EF4444" class="mb-4">mdi-close-circle</v-icon>
            <h2 class="expired-title mb-2">
              Login Expired
            </h2>
            <p class="expired-text mb-4">
              <span v-if="referrer">
                This login attempt is no longer valid. Please <a :href="referrer" class="expired-link">click here</a> to return.
              </span>
              <span v-else>
                This login attempt is no longer valid. Please go back to the previous page.
              </span>
            </p>
            <v-btn
              color="primary"
              variant="flat"
              size="large"
              rounded="lg"
              @click="$router.push({ name: 'initial' })"
              class="back-btn text-none"
            >
              <v-icon start>mdi-arrow-left</v-icon>
              Back to Login
            </v-btn>
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

    <!-- Help Dialog -->
    <v-dialog v-model="dialog" max-width="600">
      <v-card rounded="xl">
        <v-card-title class="text-h5 font-weight-bold pa-6">
          Need Help?
        </v-card-title>
        <v-card-text class="px-6">
          <p class="text-body-1 mb-4">
            If you don't have the ThreeFold Connect app yet, download it from your app store:
          </p>
          
          <div class="d-flex justify-center gap-3 mb-6">
            <a 
              href="https://play.google.com/store/apps/details?id=org.jimber.threebotlogin" 
              target="_blank"
            >
              <img src="/googleplay.png" height="56" alt="Get it on Google Play" style="border-radius: 8px;" />
            </a>
            <a 
              href="https://itunes.apple.com/be/app/3bot-login/id1459845885?l=nl&mt=8" 
              target="_blank"
            >
              <img src="/applestore.png" height="56" alt="Download on the App Store" style="border-radius: 8px;" />
            </a>
          </div>

          <v-divider class="my-4"></v-divider>

          <p class="text-body-2">
            <strong>Account Recovery:</strong> If you have an account but it's not active on your device, open the app and click the 'Recover Account' button for instructions.
          </p>
        </v-card-text>
        <v-card-actions class="px-6 pb-6">
          <v-spacer></v-spacer>
          <v-btn 
            color="primary" 
            variant="elevated"
            rounded="lg"
            @click="dialog = false"
            class="text-none font-weight-semibold"
          >
            Got It
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useAppStore } from '@/stores/app'
import config from '@/config'

const store = useAppStore()

const isMobile = ref(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
const dialog = ref(false)
const loggedIn = ref(false)
const referrer = ref(document.referrer)

const openApp = () => {
  if (isMobile.value) {
    let url = `${config.deeplink}login/?state=${encodeURIComponent(store._state || '')}`
    if (store.scope) url += `&scope=${encodeURIComponent(store.scope)}`
    if (store.appId) url += `&appId=${encodeURIComponent(store.appId)}`
    if (store.appPublicKey) url += `&appPublicKey=${encodeURIComponent(store.appPublicKey)}`
    
    if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
      window.location.replace(url)
    } else if (/Android|webOS|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
      window.open(url)
    }
  }
}

const triggerResendNotification = () => {
  store.resendNotification()
}

watch(() => store.signedAttempt, (val) => {
  if (!val) return
  
  loggedIn.value = true
  const data = encodeURIComponent(JSON.stringify(val))
  const union = (store.redirectUrl?.indexOf('?') ?? -1) >= 0 ? '&' : '?'
  const safeRedirectUri = store.redirectUrl?.[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
  const url = `//${store.appId}${safeRedirectUri}${union}signedAttempt=${data}`
  window.location.href = url
}, { once: true })

onMounted(() => {
  store.resetTimer()
  store.setAttemptCanceled(false)
})

onUnmounted(() => {
  if (store.loginTimeout) clearTimeout(store.loginTimeout)
  if (store.loginInterval) clearInterval(store.loginInterval)
})

watch(() => store.cancelLoginUp, (val) => {
  if (!val || !store.redirectUrl || !store.appId) return
  
  const safeRedirectUri = store.redirectUrl[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
  const url = `//${store.appId}${safeRedirectUri}?error=CancelledByUser`
  window.location.href = url
}, { once: true })
</script>

<style src="./Login.scss" scoped lang="scss"></style>
