<template>
  <section class="login">
    <v-row justify="center">
      <v-col cols="12" md="8">
        <v-card>
          <v-toolbar color="primary">
            <v-toolbar-title class="text-h5 text-white">Signing in...</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon="mdi-help" variant="outlined" color="white" @click="dialog = true"></v-btn>
          </v-toolbar>
          <v-form class="pa-4">
            <v-card-text>
              <v-row v-if="store.loginTimeleft > 0 && !loggedIn" align="center" justify="center">
                <v-col cols="12" class="text-center">
                  <p class="text-subtitle-1 pt-3">
                    Please open the ThreeFold Connect app on your mobile device, authenticate either with pin or Touch ID, and then match the following icon from the choices given.
                  </p>
                  <v-progress-circular indeterminate color="accent" :size="100" :width="15">
                    <img v-if="!isMobile" :src="`/icons/${store.randomImageId}.png`" height="37" />
                  </v-progress-circular>
                  <p class="text-body-2 pt-3">Time remaining: {{ store.loginTimeleft }}s</p>
                  <v-btn v-if="!store.firstTime && !isMobile" color="accent" class="mt-3" @click="triggerResendNotification">
                    <v-icon start>mdi-refresh</v-icon>
                    RESEND NOTIFICATION
                  </v-btn>
                  <v-btn v-if="isMobile" color="accent" class="mt-3" @click="openApp">
                    Open ThreeFold Connect app
                  </v-btn>
                </v-col>
              </v-row>
              <v-row v-else-if="loggedIn" align="center" justify="center">
                <v-col cols="12" class="text-center">
                  <v-icon :size="100" color="accent">mdi-check-circle</v-icon>
                  <p class="text-subtitle-1 pt-3">Login successful! Redirecting...</p>
                </v-col>
              </v-row>
              <v-row v-else align="center" justify="center">
                <v-col cols="12" class="text-center">
                  <v-icon :size="100" color="error">mdi-close-circle</v-icon>
                  <b v-if="referrer">This login attempt is no longer valid, please click <a :href="referrer">here</a> to return.</b>
                  <b v-else>This login attempt is no longer valid, please go back to the previous page.</b>
                </v-col>
              </v-row>
            </v-card-text>
          </v-form>
        </v-card>
      </v-col>
    </v-row>

    <v-dialog v-model="dialog" max-width="500">
      <v-card class="text-center">
        <v-card-title class="text-h5"></v-card-title>
        <v-card-text class="text-subtitle-1 pt-3">
          If you do not yet have the ThreeFold Connect app on your device, you can download it on the Google Play / Apple App store.
        </v-card-text>
        <v-row justify="center">
          <v-col cols="auto">
            <a href="https://play.google.com/store/apps/details?id=org.jimber.threebotlogin" target="_blank" class="mx-2">
              <img src="/googleplay.png" height="50" />
            </a>
            <a href="https://itunes.apple.com/be/app/3bot-login/id1459845885?l=nl&mt=8" target="_blank" class="mx-2">
              <img src="/applestore.png" height="50" />
            </a>
          </v-col>
        </v-row>
        <v-card-text class="text-subtitle-1 pt-3">
          Have you already created an account but it is not active on your device? Click the 'recover account' button in the app and you will be instructed on how to regain access.
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="accent" class="ma-3" @click="dialog = false">Close Window</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
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
  if (val) {
    loggedIn.value = true
    const data = encodeURIComponent(JSON.stringify(val))
    const union = (store.redirectUrl?.indexOf('?') ?? -1) >= 0 ? '&' : '?'
    const safeRedirectUri = store.redirectUrl?.[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
    const url = `//${store.appId}${safeRedirectUri}${union}signedAttempt=${data}`
    window.location.href = url
  }
})

onMounted(() => {
  store.resetTimer()
  store.setAttemptCanceled(false)
})

watch(() => store.cancelLoginUp, (val) => {
  if (val && store.redirectUrl && store.appId) {
    const safeRedirectUri = store.redirectUrl[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
    const url = `//${store.appId}${safeRedirectUri}?error=CancelledByUser`
    window.location.href = url
  }
})
</script>

<style src="./Login.scss" scoped lang="scss"></style>
