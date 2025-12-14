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
              <v-row v-if="store.loginTimeleft > 0" align="center" justify="center">
                <v-col cols="12" class="text-center">
                  <p class="text-subtitle-1 pt-3">
                    Please open the ThreeFold Connect app on your mobile device, authenticate either with pin or Touch ID, and then match the following icon from the choices given.
                  </p>
                  <v-progress-circular :size="100" :width="15" color="accent" indeterminate v-if="!loggedIn">
                    <img v-if="!isMobile && !loggedIn" :src="`/icons/${store.randomImageId}.png`" height="37" />
                  </v-progress-circular>
                  <v-progress-circular v-else :size="100" :width="0">
                    <v-icon color="accent" size="75">mdi-check</v-icon>
                  </v-progress-circular>
                  <p class="text-subtitle-1 pt-3">Please enter your pincode or use fingerprint and select this icon on your mobile phone.</p>
                  <p>Your login attempt is valid for another {{store.loginTimeleft}} seconds.</p>
                  <v-btn v-if="!store.firstTime && !isMobile" color="accent" class="mt-3" @click="triggerResendNotification">
                    <v-icon start>mdi-refresh</v-icon>
                    RESEND NOTIFICATION
                  </v-btn>
                  <v-btn v-if="isMobile" color="accent" class="mt-3" @click="openApp">
                    Open ThreeFold Connect app
                  </v-btn>
                </v-col>
              </v-row>
              <v-row v-else>
                <v-col cols="12">
                  <b v-if="ref">This login attempt is no longer valid, please click <a :href="ref">here</a> to return.</b>
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
const ref = ref(document.referrer)

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
  // Resend notification logic would go here
  console.log('Resending notification')
}

watch(() => store.signedAttempt, (val) => {
  if (val) {
    loggedIn.value = true
    const data = encodeURIComponent(JSON.stringify(val))
    const union = store.redirectUrl?.indexOf('?') >= 0 ? '&' : '?'
    const safeRedirectUri = store.redirectUrl?.[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
    const url = `//${store.appId}${safeRedirectUri}${union}signedAttempt=${data}`
    window.location.href = url
  }
})

onMounted(() => {
  // Reset timer or other initialization
})
</script>

<style src="./Login.scss" scoped lang="scss"></style>
