<template>
  <section class="login fill-height">
    <v-row justify="center" align="center" class="fill-height">
      <v-col cols="12" sm="10" md="8" lg="6" xl="5">
        <!-- Active Login State -->
        <v-card v-if="store.loginTimeleft > 0 && !loggedIn" class="modern-card">
          <div class="text-center pa-6 pb-4">
            <h1 class="text-h5 font-weight-bold mb-2" style="color: #1E293B;">
              Verify Your Identity
            </h1>
            <p class="text-body-2" style="color: #64748B;">
              Select the matching emoji in your ThreeFold Connect app
            </p>
          </div>

          <v-card-text class="text-center px-6 pb-6">
            <v-alert
              type="info"
              variant="tonal"
              rounded="lg"
              class="mb-4"
              border="start"
              border-color="primary"
              density="compact"
            >
              <div class="text-body-2">
                Please open your ThreeFold Connect app, authenticate with PIN or biometrics, and select the matching emoji
              </div>
            </v-alert>

            <!-- Emoji Display -->
            <div class="emoji-container mb-6">
              <div class="emoji-card" style="display: flex; justify-content: center; align-items: center;">
                <v-img 
                  v-if="!isMobile"
                  :src="`/icons/${store.randomImageId}.png`" 
                  alt="Login emoji"
                  width="80"
                  height="80"
                  class="emoji-image"
                ></v-img>
                <v-progress-circular 
                  v-else
                  indeterminate 
                  color="primary" 
                  :size="100" 
                  :width="8"
                  class="mb-4"
                ></v-progress-circular>
              </div>
            </div>

            <!-- Timer -->
            <div class="timer-section mb-6 text-center">
              <v-chip
                size="large"
                variant="tonal"
                color="primary"
                class="px-6 py-6"
              >
                <span class="text-h6 font-weight-bold">{{ store.loginTimeleft }}s</span>
              </v-chip>
              <p class="text-caption mt-2" style="color: #64748B;">
                Time remaining to complete verification
              </p>
            </div>

            <!-- Actions -->
            <div class="d-flex flex-column gap-3">
              <v-btn
                v-if="!store.firstTime && !isMobile"
                color="primary"
                variant="elevated"
                size="large"
                rounded="lg"
                @click="triggerResendNotification"
                class="text-none font-weight-semibold"
              >
                <v-icon start>mdi-refresh</v-icon>
                Resend Notification
              </v-btn>
              
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
              
              <v-btn
                variant="text"
                color="secondary"
                size="large"
                rounded="lg"
                @click="dialog = true"
                class="text-none"
              >
                <v-icon start>mdi-help-circle</v-icon>
                Need Help?
              </v-btn>
            </div>
          </v-card-text>
        </v-card>

        <!-- Success State -->
        <v-card v-else-if="loggedIn" class="modern-card">
          <v-card-text class="text-center pa-8">
            <v-icon :size="120" color="success" class="mb-4">mdi-check-circle</v-icon>
            <h2 class="text-h5 font-weight-bold mb-2" style="color: #1E293B;">
              Login Successful!
            </h2>
            <p class="text-body-1" style="color: #64748B;">
              Redirecting you now...
            </p>
            <v-progress-linear indeterminate color="primary" class="mt-4"></v-progress-linear>
          </v-card-text>
        </v-card>

        <!-- Expired State -->
        <v-card v-else class="modern-card">
          <v-card-text class="text-center pa-8">
            <v-icon :size="120" color="error" class="mb-4">mdi-close-circle</v-icon>
            <h2 class="text-h5 font-weight-bold mb-2" style="color: #1E293B;">
              Login Expired
            </h2>
            <p class="text-body-1 mb-4" style="color: #64748B;">
              <span v-if="referrer">
                This login attempt is no longer valid. Please <a :href="referrer" class="text-primary">click here</a> to return.
              </span>
              <span v-else>
                This login attempt is no longer valid. Please go back to the previous page.
              </span>
            </p>
            <v-btn
              color="primary"
              variant="elevated"
              size="large"
              rounded="lg"
              @click="$router.push({ name: 'initial' })"
              class="text-none font-weight-semibold"
            >
              <v-icon start>mdi-arrow-left</v-icon>
              Back to Login
            </v-btn>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

    <!-- Help Dialog -->
    <v-dialog v-model="dialog" max-width="600">
      <v-card rounded="xl">
        <v-card-title class="text-h5 font-weight-bold pa-6" style="color: #1E293B;">
          Need Help?
        </v-card-title>
        <v-card-text class="px-6">
          <p class="text-body-1 mb-4" style="color: #475569;">
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

          <p class="text-body-2" style="color: #64748B;">
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
