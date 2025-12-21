<template>
  <section class="sign fill-height">
    <v-container fluid class="fill-height pa-0">
      <v-row class="fill-height ma-0" justify="center" align="center">
        <v-col cols="12" sm="12" md="10" lg="8" xl="6">
          <div class="content-wrapper">
            <!-- Logo -->
            <div class="text-center mb-4">
              <v-img src="/logo.png" alt="ThreeFold" width="48" height="48" class="mx-auto mb-4"></v-img>
            </div>
            
            <!-- Page Header -->
            <div class="text-center mb-4">
              <h1 class="page-title mb-2">
                ThreeFold Connect
              </h1>
              <p class="page-subtitle">
                Sign Data
              </p>
            </div>
            
            <!-- Mobile View -->
            <v-btn v-if="isMobile"
              color="primary" 
              size="x-large"
              variant="elevated"
              rounded="xl"
              class="px-8"
              @click="promptToSignMobile"
            >
              <v-icon start>mdi-open-in-app</v-icon>
              Open ThreeFold Connect App
            </v-btn>

            <!-- Desktop View -->
            <v-card v-else class="sign-card">
          <!-- Initial Form -->
          <v-form v-if="!store.signAttemptOnGoing" v-model="valid" @submit.prevent="onSignIn">
            <v-card-text class="px-6 pb-6">
              <div class="info-text mb-4 text-body-2 text-center" style="color: rgba(255, 255, 255, 0.7);">
                You're about to sign data with your ThreeFold identity. Please verify your 3Bot name below.
              </div>

              <div class="mb-6">
                <label class="text-subtitle-2 font-weight-medium mb-2 d-block">
                  ThreeFold Connect ID
                </label>
                <v-text-field
                  v-model="doubleName"
                  @input="checkNameAvailability"
                  :disabled="store.nameCheckStatus.checking"
                  :rules="nameRules"
                  variant="outlined"
                  placeholder="Enter your ThreeFold Connect ID"
                  density="comfortable"
                  :loading="store.nameCheckStatus.checking"
                  class="custom-input"
                  :error="store.nameCheckStatus.checked && store.nameCheckStatus.available"
                  :error-messages="store.nameCheckStatus.checked && store.nameCheckStatus.available ? 'This ThreeFold Connect ID is not registered. Please check your spelling.' : ''"
                  :success="store.nameCheckStatus.checked && !store.nameCheckStatus.available"
                  :hint="store.nameCheckStatus.checked && !store.nameCheckStatus.available ? 'ThreeFold Connect ID verified! You can proceed with signing.' : ''"
                  persistent-hint
                >
                  <template v-slot:append-inner>
                    <v-icon v-if="store.nameCheckStatus.checked && !store.nameCheckStatus.available" color="success" size="small">
                      mdi-check-circle
                    </v-icon>
                    <v-icon v-else-if="store.nameCheckStatus.checked && store.nameCheckStatus.available" color="error" size="small">
                      mdi-close-circle
                    </v-icon>
                  </template>
                </v-text-field>
              </div>
            </v-card-text>
            
            <v-card-actions class="px-6 pb-6 pt-2">
              <v-btn
                type="submit"
                color="primary"
                size="large"
                variant="elevated"
                rounded="lg"
                block
                :disabled="!valid || !store.nameCheckStatus.checked || store.nameCheckStatus.available"
                class="text-none font-weight-semibold"
              >
                <v-icon start>mdi-draw</v-icon>
                Continue to Sign
              </v-btn>
            </v-card-actions>
          </v-form>

          <!-- Signing In Progress -->
          <v-card-text v-else class="text-center pa-8">
            <h2 class="sign-title mb-6">
              Signing Data...
            </h2>
            
            <p class="sign-instruction mb-6">
              Please open the ThreeFold Connect app on your mobile device and approve the signing request.
            </p>
            
            <v-progress-circular
              indeterminate
              color="#14B8A6"
              :size="80"
              :width="6"
              class="mb-6"
            ></v-progress-circular>
            
            <p class="timer-text mb-4">
              Waiting for your approval...
            </p>
            
            <v-btn
              v-if="!store.firstTime && !isMobile"
              color="primary"
              variant="flat"
              size="large"
              rounded="lg"
              block
              @click="triggerResendSignSocket"
              class="resend-btn text-none"
            >
              <v-icon start size="20">mdi-refresh</v-icon>
              RESEND NOTIFICATION
            </v-btn>
          </v-card-text>

            </v-card>
            
            <!-- App Store Badges -->
            <div class="mt-6 text-center">
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
          About Data Signing
        </v-card-title>
        <v-card-text class="px-6 pb-6">
          <p class="text-body-1">
            Data signing allows you to cryptographically prove that you authorized specific data or transactions using your ThreeFold identity.
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
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAppStore } from '@/stores/app'
import config from '@/config'

const router = useRouter()
const route = useRoute()
const store = useAppStore()

const doubleName = ref('')
const valid = ref(false)
const dialog = ref(false)
const isMobile = ref(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
const nameCheckerTimeOut = ref<number | null>(null)
const isRedirecting = ref(false)
const randomRoom = ref<string | null>(null)

const nameRegex = /^(\w+)$/
const nameRules = [
  (v: string) => !!v || 'Name is required',
  (v: string) => nameRegex.test(v) || 'Name can only contain alphanumeric characters.',
  (v: string) => v.length <= 50 || 'Name must be less than 50 characters.'
]

const checkNameAvailability = () => {
  if (doubleName.value) {
    if (nameCheckerTimeOut.value != null) {
      clearTimeout(nameCheckerTimeOut.value)
    }
    nameCheckerTimeOut.value = window.setTimeout(() => {
      store.checkName(doubleName.value)
    }, 500)
  }
}

const onSignIn = async () => {
  const query = route.query
  
  await store.signDataUser({
    doubleName: doubleName.value,
    appId: query.appId as string,
    isJson: query.isJson as string,
    dataUrlHash: query.dataHash as string,
    dataUrl: query.dataUrl as string,
    friendlyName: query.friendlyName as string,
    redirectUrl: query.redirectUrl as string,
    state: query.state as string
  })
}

const promptToSignMobile = () => {
  const query = route.query
  
  store.setRandomRoom(randomRoom.value!)
  
  store.signUserMobile({
    state: query.state as string,
    appId: query.appId as string,
    dataUrlHash: query.dataHash as string,
    dataUrl: query.dataUrl as string,
    isJson: query.isJson as string,
    redirectUrl: query.redirectUrl as string,
    friendlyName: query.friendlyName as string
  })
  
  if (isMobile.value) {
    let url = `${config.deeplink}sign/?state=${encodeURIComponent(store._state || '')}&randomRoom=${randomRoom.value}`
    if (store.appId) url += `&appId=${encodeURIComponent(store.appId)}`
    if (query.dataHash) url += `&dataHash=${encodeURIComponent(store.dataUrlHash!)}`
    if (query.dataUrl) url += `&dataUrl=${encodeURIComponent(store.dataUrl!)}`
    if (query.isJson) url += `&isJson=${encodeURIComponent(store.isJson!.toString())}`
    if (query.redirectUrl) url += `&redirectUrl=${encodeURIComponent(store.redirectUrl!)}`
    if (query.friendlyName) url += `&friendlyName=${encodeURIComponent(store.friendlyName!)}`
    
    if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
      window.location.replace(url)
    } else {
      window.location.href = url
    }
  }
}

const triggerResendSignSocket = async () => {
  await store.resendSignNotification()
}

const gotFocus = () => {
  randomRoom.value = localStorage.getItem('randomRoom')
  if (randomRoom.value) {
    store.setRandomRoom(randomRoom.value)
  }
}

// Watch for signed sign attempt
watch(() => store.signedSignAttempt, (val) => {
  if (!val) {
    console.log('Missing data')
    return
  }

  try {
    console.log('signedAttemptObject: ', val)
    console.log('signedAttemptObject: ', JSON.stringify(val))
    localStorage.setItem('username', doubleName.value)

    const data = encodeURIComponent(JSON.stringify(val))
    console.log('data', data)

    if (data) {
      let union = '?'
      console.log('redirect url: ', store.redirectUrl)
      if (store.redirectUrl && store.redirectUrl.indexOf('?') >= 0) {
        union = '&'
      }

      // Otherwise evil app could do appid+redirecturl = wallet.com + .evil.com = wallet.com.evil.com
      // Now its wallet.com/.evil.com
      let safeRedirectUri
      if (store.redirectUrl && store.redirectUrl[0] === '/') {
        safeRedirectUri = store.redirectUrl
      } else {
        safeRedirectUri = '/' + store.redirectUrl
      }

      console.log('!!!! doubleName: ', doubleName.value)
      const url = `//${store.appId}${safeRedirectUri}${union}signedAttempt=${data}`
      
      if (!isRedirecting.value) {
        isRedirecting.value = true
        console.log('Changing href: ', url)
        window.location.href = url
      }
    } else {
      console.log('Val was null')
    }
  } catch (e) {
    console.log('Something went wrong ... ', e)
  }
})

// Watch for cancel sign
watch(() => store.cancelSignUp, (val) => {
  if (val) {
    console.log('CANCELED', val)
    let safeRedirectUri
    if (store.redirectUrl && store.redirectUrl[0] === '/') {
      safeRedirectUri = store.redirectUrl
    } else {
      safeRedirectUri = '/' + store.redirectUrl
    }

    const url = `//${store.appId}${safeRedirectUri}?error=CancelledByUser`
    window.location.href = url
  }
})

onMounted(() => {
  window.onfocus = gotFocus
  
  const query = route.query
  
  if (isMobile.value) {
    randomRoom.value = localStorage.getItem('randomRoom')
    if (!randomRoom.value) {
      randomRoom.value = generateUUID()
      localStorage.setItem('randomRoom', randomRoom.value)
    }
    store.setRandomRoom(randomRoom.value)
  }
  
  if (!query.appId || !query.dataHash || !query.dataUrl || !query.isJson || !query.redirectUrl || !query.state || !query.friendlyName) {
    router.push({ name: 'error' })
  }
})

const generateUUID = (): string => {
  let d = new Date().getTime()
  let d2 = (performance?.now() * 1000) || 0
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    let r = Math.random() * 16
    if (d > 0) {
      r = (d + r) % 16 | 0
      d = Math.floor(d / 16)
    } else {
      r = (d2 + r) % 16 | 0
      d2 = Math.floor(d2 / 16)
    }
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16)
  })
}
</script>

<style src="./sign.scss" scoped lang="scss"></style>
