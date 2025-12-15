<template>
  <section class="login">
    <v-row justify="center">
      <v-col cols="12" md="8">
        <v-card>
          <v-toolbar color="primary">
            <v-toolbar-title class="text-h5 text-white">Sign data</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-btn icon="mdi-help" variant="outlined" color="white" @click="dialog = true"></v-btn>
          </v-toolbar>
          
          <v-row v-if="isMobile" class="fill-height" align="center" justify="center">
            <v-col cols="12" class="text-center py-5">
              <v-avatar class="mb-4" size="200">
                <v-img src="/logo.png"></v-img>
              </v-avatar>
              <v-btn color="accent" @click="promptToSignMobile">
                Open ThreeFold Connect app
              </v-btn>
            </v-col>
          </v-row>
          
          <v-form v-else class="pa-4" v-model="valid" @submit.prevent="onSignIn">
            <v-card-text>
              <v-text-field
                @input="checkNameAvailability"
                :disabled="store.nameCheckStatus.checking"
                :rules="nameRules"
                v-model="doubleName"
                variant="outlined"
                label="Type in your ThreeFold Connect ID"
                :hint="doubleName ? `Your ThreeFold ID: ${doubleName}` : 'Whats your ThreeFold ID?'"
                required
                counter="50"
              ></v-text-field>
            </v-card-text>
            
            <v-card-actions>
              <v-col cols="12" class="text-center">
                <v-btn
                  v-if="store.nameCheckStatus.checked && !isSignAttemptOnGoing"
                  type="submit"
                  class="sign-in mb-3"
                  elevation="0"
                  color="accent"
                  :disabled="!store.nameCheckStatus.checking && store.nameCheckStatus.available"
                >
                  Sign in
                </v-btn>
                
                <div v-if="isSignAttemptOnGoing" class="text-center mb-4">
                  <v-progress-circular indeterminate color="accent" class="mb-3"></v-progress-circular>
                  <v-btn v-if="!store.firstTime && !isMobile" color="accent" @click="triggerResendSignSocket">
                    <v-icon start>mdi-refresh</v-icon>
                    RESEND NOTIFICATION
                  </v-btn>
                </div>
                
                <div v-if="store.nameCheckStatus.checked && !store.nameCheckStatus.checking && valid && store.nameCheckStatus.available">
                  This account doesn't exist yet. Please register using the mobile app!<br>
                  If you don't have the app, you can download by clicking below.
                </div>
                <div v-else>
                  If you do not have an ID, please download ThreeFold Connect<br>on the Google Play / Apple App store and create an account.
                </div>
              </v-col>
            </v-card-actions>
          </v-form>
        </v-card>
      </v-col>
    </v-row>
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
const isSignAttemptOnGoing = ref(false)
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

const triggerResendSignSocket = async () => {
  await store.resendSignNotification()
}

onMounted(() => {
  const query = route.query
  if (!query.appId || !query.dataHash || !query.dataUrl || !query.isJson || !query.redirectUrl || !query.state || !query.friendlyName) {
    router.push({ name: 'error' })
  }
})
</script>

<style src="./sign.scss" scoped lang="scss"></style>
