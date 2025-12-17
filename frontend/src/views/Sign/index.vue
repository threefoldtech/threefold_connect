<template>
  <section class="sign fill-height">
    <v-container fluid class="fill-height pa-0">
      <v-row class="fill-height ma-0" justify="center" align="center">
        <v-col cols="12" sm="12" md="10" lg="8" xl="6">
          <div class="content-wrapper">
            <!-- Logo -->
            <div class="text-center mb-6">
              <v-img src="/logo.png" alt="ThreeFold" width="48" height="48" class="mx-auto mb-4"></v-img>
            </div>
            
            <!-- Page Header -->
            <div class="text-center mb-6">
              <h1 class="page-title mb-2">
                ThreeFold Connect
              </h1>
              <p class="page-subtitle">
                Sign Data
              </p>
            </div>
            
            <!-- Mobile View -->
            <v-card v-if="isMobile" class="sign-card">
          <div class="text-center pa-8">
            <v-avatar size="120" class="mb-6">
              <v-img src="/logo.png" alt="ThreeFold Connect"></v-img>
            </v-avatar>
            <h1 class="text-h5 font-weight-bold mb-3">
              Sign Data Request
            </h1>
            <p class="text-body-1 mb-6">
              Open your ThreeFold Connect app to sign this data
            </p>
            <v-btn 
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
          </div>
        </v-card>

            <!-- Desktop View -->
            <v-card v-else class="sign-card">

          <v-form v-model="valid" @submit.prevent="onSignIn">
            <v-card-text class="px-6 pb-6">
              <v-alert
                type="info"
                variant="tonal"
                rounded="lg"
                class="mb-4 centered-icon-alert"
                border="start"
                border-color="primary"
                density="compact"
                icon="mdi-information"
              >
                <div class="text-body-2">
                  You're about to sign data with your ThreeFold identity. Please verify your 3Bot name below.
                </div>
              </v-alert>

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
                  hint="Enter your ThreeFold Connect ID"
                  persistent-hint
                  density="comfortable"
                  :loading="store.nameCheckStatus.checking"
                >
                  <template v-slot:prepend-inner>
                    <v-avatar size="24" class="mr-2">
                      <v-img src="/logo.png" alt="ThreeFold"></v-img>
                    </v-avatar>
                  </template>
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

              <v-alert 
                v-if="store.nameCheckStatus.checked && store.nameCheckStatus.available" 
                type="error"
                variant="tonal"
                rounded="lg"
                class="mb-4 centered-icon-alert"
                density="compact"
              >
                <div class="d-flex align-center">
                  <v-icon start>mdi-alert-circle</v-icon>
                  <span>This ThreeFold Connect ID is not registered. Please check your spelling.</span>
                </div>
              </v-alert>
              
              <v-alert 
                v-if="store.nameCheckStatus.checked && !store.nameCheckStatus.available" 
                type="success"
                variant="tonal"
                rounded="lg"
                class="mb-4 centered-icon-alert"
                density="compact"
              >
                <div class="d-flex align-center">
                  <v-icon start>mdi-check-circle</v-icon>
                  <span>ThreeFold Connect ID verified! You can proceed.</span>
                </div>
              </v-alert>
            </v-card-text>
            
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
                <v-icon start>mdi-draw</v-icon>
                Continue to Sign
              </v-btn>
            </v-card-actions>
          </v-form>

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
import { ref, onMounted } from 'vue'
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
  const randomRoom = localStorage.getItem('randomRoom') || ''
  
  store.setRandomRoom(randomRoom)
  
  store.signUserMobile({
    state: query.state as string,
    appId: query.appId as string,
    dataUrlHash: query.dataHash as string,
    dataUrl: query.dataUrl as string,
    isJson: query.isJson as string,
    redirectUrl: query.redirectUrl as string,
    friendlyName: query.friendlyName as string
  })
  
  let url = `${config.deeplink}sign/?state=${encodeURIComponent(store._state || '')}&randomRoom=${randomRoom}`
  if (store.appId) url += `&appId=${encodeURIComponent(store.appId)}`
  if (store.dataUrlHash) url += `&dataHash=${encodeURIComponent(store.dataUrlHash)}`
  if (store.dataUrl) url += `&dataUrl=${encodeURIComponent(store.dataUrl)}`
  if (store.isJson) url += `&isJson=${encodeURIComponent(store.isJson.toString())}`
  if (store.redirectUrl) url += `&redirectUrl=${encodeURIComponent(store.redirectUrl)}`
  if (store.friendlyName) url += `&friendlyName=${encodeURIComponent(store.friendlyName)}`
  
  if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
    window.location.replace(url)
  } else {
    window.location.href = url
  }
}

onMounted(() => {
  const query = route.query
  if (!query.appId || !query.dataHash || !query.dataUrl || !query.isJson || !query.redirectUrl || !query.state || !query.friendlyName) {
    router.push({ name: 'error' })
  }
})
</script>

<style src="./sign.scss" scoped lang="scss"></style>
