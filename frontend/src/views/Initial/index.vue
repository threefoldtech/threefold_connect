<template>
  <section class="initial fill-height">
    <!-- Mobile View -->
    <v-row v-if="isMobile" class="fill-height" align="center" justify="center">
      <v-col cols="12" class="text-center px-6">
        <v-avatar class="mb-8 logo-avatar" size="160">
          <v-img src="/logo.png" alt="ThreeFold Connect Logo"></v-img>
        </v-avatar>
        <h1 class="text-h4 font-weight-bold mb-3" style="color: #1E293B;">
          ThreeFold Connect
        </h1>
        <p class="text-body-1 mb-8" style="color: #64748B; max-width: 400px; margin: 0 auto;">
          Secure authentication for ThreeFold Grid
        </p>
        <v-btn 
          color="primary" 
          size="x-large"
          variant="elevated"
          rounded="xl"
          class="px-8 py-6"
          @click="promptLoginToMobileUser"
        >
          <v-icon start>mdi-open-in-app</v-icon>
          Open ThreeFold Connect App
        </v-btn>
      </v-col>
    </v-row>
    
    <!-- Desktop View -->
    <v-row v-else class="fill-height" align="center" justify="center">
      <v-progress-linear 
        v-if="store.nameCheckStatus.checking" 
        color="primary"
        indeterminate
        style="position: fixed; top: 0; left: 0; right: 0; z-index: 9999;"
      ></v-progress-linear>
      
      <v-col cols="12" sm="10" md="8" lg="6" xl="5">
        <v-card class="modern-card pa-4">
          <!-- Header -->
          <div class="text-center mb-8 mt-4">
            <v-avatar size="100" class="mb-4">
              <v-img src="/logo.png" alt="ThreeFold Connect Logo"></v-img>
            </v-avatar>
            <h1 class="text-h4 font-weight-bold mb-2" style="color: #1E293B;">
              ThreeFold Connect
            </h1>
            <p class="text-subtitle-1" style="color: #64748B;">
              Secure Two-Factor Authentication
            </p>
          </div>

          <v-form v-model="valid" @submit.prevent="login">
            <v-card-text class="px-6">
              <!-- Welcome Message -->
              <v-alert
                type="info"
                variant="tonal"
                rounded="lg"
                class="mb-6"
                border="start"
                border-color="primary"
              >
                <div class="text-body-2" style="line-height: 1.6;">
                  Welcome to the ThreeFold Connect authenticator. Your account is secured with military-grade encryption - not even we can access it.
                  <br><br>
                  <strong>Before continuing:</strong> Please ensure your ThreeFold Connect mobile app is open and ready.
                </div>
              </v-alert>
              <!-- Username Input -->
              <div class="mb-6">
                <label class="text-subtitle-2 font-weight-medium mb-2 d-block" style="color: #1E293B;">
                  ThreeFold Connect ID
                </label>
                <v-text-field
                  v-model="doubleName"
                  @input="checkNameAvailability"
                  :disabled="store.nameCheckStatus.checking"
                  :rules="nameRules"
                  variant="outlined"
                  placeholder="Enter your ThreeFold Connect ID"
                  hint="Enter your Threefold Connect ID"
                  persistent-hint
                  density="comfortable"
                  :loading="store.nameCheckStatus.checking"
                >
                  <template v-slot:append-inner>
                    <v-icon v-if="store.nameCheckStatus.checked && store.nameCheckStatus.available" color="error" size="small">
                      mdi-close-circle
                    </v-icon>
                    <v-icon v-if="store.nameCheckStatus.checked && !store.nameCheckStatus.available" color="success" size="small">
                      mdi-check-circle
                    </v-icon>
                  </template>
                </v-text-field>
              </div>
              <!-- Status Messages -->
              <v-alert 
                v-if="store.nameCheckStatus.checked && store.nameCheckStatus.available" 
                type="error"
                variant="tonal"
                rounded="lg"
                class="mb-4"
              >
                <div class="d-flex align-center">
                  <v-icon start>mdi-alert-circle</v-icon>
                  <span>This ThreeFold Connect ID is not registered yet. Please check your spelling or register a new account.</span>
                </div>
              </v-alert>
              
              <v-alert 
                v-if="store.nameCheckStatus.checked && !store.nameCheckStatus.available" 
                type="success"
                variant="tonal"
                rounded="lg"
                class="mb-4"
              >
                <div class="d-flex align-center">
                  <v-icon start>mdi-check-circle</v-icon>
                  <span>ThreeFold Connect ID verified! You can proceed with login.</span>
                </div>
              </v-alert>
            </v-card-text>
            
            <!-- Actions -->
            <v-card-actions class="px-6 pb-6 pt-2">
              <v-btn
                type="submit"
                color="primary"
                size="large"
                variant="elevated"
                rounded="lg"
                block
                :disabled="!valid || store.nameCheckStatus.available"
                class="text-none font-weight-semibold"
              >
                <v-icon start>mdi-login</v-icon>
                Continue to Login
              </v-btn>
            </v-card-actions>
          </v-form>
        </v-card>
      </v-col>
    </v-row>

    <!-- App Store Badges -->
    <v-row class="mt-8" justify="center">
      <v-col cols="12" class="text-center">
        <p class="text-body-2 mb-4" style="color: #64748B;">
          Don't have an account? Download the app to get started
        </p>
        <div class="d-flex justify-center align-center gap-3 flex-wrap">
          <a 
            href="https://play.google.com/store/apps/details?id=org.jimber.threebotlogin" 
            target="_blank" 
            class="app-badge"
          >
            <img src="/googleplay.png" height="48" alt="Get it on Google Play" style="border-radius: 8px; transition: transform 0.2s;" />
          </a>
          <a 
            href="https://itunes.apple.com/be/app/3bot-login/id1459845885?l=nl&mt=8" 
            target="_blank"
            class="app-badge"
          >
            <img src="/applestore.png" height="48" alt="Download on the App Store" style="border-radius: 8px; transition: transform 0.2s;" />
          </a>
        </div>
      </v-col>
    </v-row>
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
const isMobile = ref(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
const nameCheckerTimeOut = ref<number | null>(null)

const nameRegex = /^(\w+)$/
const nameRules = [
  (v: string) => !!v || 'Name is required',
  (v: string) => nameRegex.test(v) || 'Name can only contain alphanumeric characters.',
  (v: string) => v.length <= 50 || 'Name must be less than 50 characters.'
]

const checkNameAvailability = () => {
  store.clearCheckStatus()
  if (doubleName.value) {
    if (nameCheckerTimeOut.value != null) {
      clearTimeout(nameCheckerTimeOut.value)
    }
    nameCheckerTimeOut.value = window.setTimeout(() => {
      store.checkName(doubleName.value)
    }, 500)
  }
}

const login = async () => {
  try {
    console.log('Starting login for:', doubleName.value)
    await store.loginUser({
      doubleName: doubleName.value,
      mobile: isMobile.value,
      firstTime: false
    })
    
    if (isMobile.value) {
      let url = `${config.deeplink}login/?state=${encodeURIComponent(store._state || '')}`
      if (store.scope) url += `&scope=${encodeURIComponent(store.scope)}`
      if (store.appId) url += `&appId=${encodeURIComponent(store.appId)}`
      if (store.appPublicKey) url += `&appPublicKey=${encodeURIComponent(store.appPublicKey)}`
      if (store.redirectUrl) url += `&redirecturl=${encodeURIComponent(store.redirectUrl)}`
      
      console.log('Opening mobile app with URL:', url)
      window.open(url)
    }
    
    console.log('Navigating to login page')
    router.push({ name: 'login' })
  } catch (error) {
    console.error('Login failed:', error)
    alert('Login failed. Please check console for details.')
  }
}

const promptLoginToMobileUser = () => {
  const randomRoom = localStorage.getItem('randomRoom') || ''
  store.loginUserMobile({
    mobile: isMobile.value,
    firstTime: false
  })
  store.setRandomRoom(randomRoom)
  
  let url = `${config.deeplink}login?state=${encodeURIComponent(store._state || '')}&randomRoom=${randomRoom}`
  if (store.scope) url += `&scope=${encodeURIComponent(store.scope)}`
  if (store.appId) url += `&appId=${encodeURIComponent(store.appId)}`
  if (store.appPublicKey) url += `&appPublicKey=${encodeURIComponent(store.appPublicKey)}`
  if (store.redirectUrl) url += `&redirecturl=${encodeURIComponent(store.redirectUrl)}`
  
  if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
    window.location.replace(url)
  } else {
    window.location.href = url
  }
}

const redirectOrError = () => {
  const returnUrl = localStorage.getItem('returnUrl')
  if (returnUrl) {
    if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
      window.location.replace(returnUrl)
    } else {
      window.location.href = returnUrl
    }
  } else {
    router.push({ name: 'error' })
  }
}

onMounted(() => {
  // Handle return URL
  if (document.referrer) {
    try {
      if (new URL(document.referrer).host !== new URL(window.location.href).host) {
        localStorage.setItem('returnUrl', document.referrer)
      }
    } catch (e) {
      localStorage.setItem('returnUrl', '')
    }
  } else {
    localStorage.setItem('returnUrl', '')
  }
  
  // Setup mobile random room
  if (isMobile.value) {
    let randomRoom = localStorage.getItem('randomRoom')
    if (!randomRoom) {
      randomRoom = crypto.randomUUID()
      localStorage.setItem('randomRoom', randomRoom)
    }
    store.setRandomRoom(randomRoom)
  }
  
  const appid = route.query.appid as string
  if (!appid) {
    redirectOrError()
    return
  }
  
  store.setAttemptCanceled(false)
  
  if (route.query.username) {
    doubleName.value = (route.query.username as string).split('.')[0]
    checkNameAvailability()
  } else {
    const tempName = localStorage.getItem('username')
    if (tempName) {
      doubleName.value = tempName.split('.')[0]
      checkNameAvailability()
    }
  }
  
  if (route.query.state) store.setState(route.query.state as string)
  if (route.query.redirecturl) store.setRedirectUrl(route.query.redirecturl as string)
  if (route.query.appid) store.setAppId(route.query.appid as string)
  if (route.query.publickey) store.setAppPublicKey(route.query.publickey as string)
  if (route.query.scope) store.setScope(route.query.scope as string)
})

watch(() => store.signedAttempt, (val) => {
  if (!isMobile.value || !val || !store.redirectUrl || !store.appId) return
  
  localStorage.setItem('username', doubleName.value)
  const data = encodeURIComponent(JSON.stringify(val))
  const union = (store.redirectUrl.indexOf('?') ?? -1) >= 0 ? '&' : '?'
  const safeRedirectUri = store.redirectUrl[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
  const url = `//${store.appId}${safeRedirectUri}${union}signedAttempt=${data}`
  window.location.href = url
}, { once: true })

watch(() => store.cancelLoginUp, (val) => {
  if (!val || !store.redirectUrl || !store.appId) return
  
  const safeRedirectUri = store.redirectUrl[0] === '/' ? store.redirectUrl : '/' + store.redirectUrl
  const url = `//${store.appId}${safeRedirectUri}?error=CancelledByUser`
  window.location.href = url
}, { once: true })
</script>

<style src="./Initial.scss" scoped lang="scss"></style>
