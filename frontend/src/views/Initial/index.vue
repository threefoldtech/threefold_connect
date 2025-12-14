<template>
  <section class="initial fill-height">
    <v-row v-if="isMobile" style="width: 100%;" class="fill-height" align="center" justify="center">
      <v-col cols="12" class="text-center py-5">
        <v-avatar class="mb-4" size="200">
          <v-img src="/logo.png"></v-img>
        </v-avatar>
        <v-btn color="accent" @click="promptLoginToMobileUser">
          Open ThreeFold Connect app
        </v-btn>
      </v-col>
    </v-row>
    
    <v-row v-else>
      <v-progress-linear style="position:fixed; top:0; left: 0;" class="ma-0" indeterminate v-if="store.nameCheckStatus.checking"></v-progress-linear>
      <v-col cols="12" md="8" offset-md="2">
        <v-card>
          <v-toolbar color="primary" class="pa-4">
            <v-toolbar-title class="text-h5 text-white">
              ThreeFold Connect Authenticator
            </v-toolbar-title>
          </v-toolbar>
          <v-form class="pa-4" v-model="valid" @submit.prevent="login">
            <v-card-text>
              <p class="text-subtitle-1 pb-2">
                Welcome to the ThreeFold Connect two-factor authenticator, enabling you access to ThreeFold Grid tools and solutions. Not a single person in the world will be able to log in to your account, not even us.
                <br><br>
                Make sure your ThreeFold Connect app is open before sending the login request.
                <br><br>
              </p>
              <p class="text-subtitle-1 font-weight-bold">
                What is your ThreeFold Connect ID?
              </p>
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
                  v-if="store.nameCheckStatus.checked"
                  type="submit"
                  class="sign-in mb-3"
                  elevation="0"
                  color="accent"
                  :disabled="!store.nameCheckStatus.checking && store.nameCheckStatus.available"
                >
                  Sign in
                </v-btn>
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

    <v-row class="pt-5" justify="center">
      <v-col cols="auto">
        <a href="https://play.google.com/store/apps/details?id=org.jimber.threebotlogin" target="_blank" class="mx-2">
          <img src="/googleplay.png" height="50" />
        </a>
        <a href="https://itunes.apple.com/be/app/3bot-login/id1459845885?l=nl&mt=8" target="_blank" class="mx-2">
          <img src="/applestore.png" height="50" />
        </a>
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

const login = () => {
  store.loginUser({
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
    window.open(url)
  }
  
  router.push({ name: 'login' })
}

const promptLoginToMobileUser = () => {
  const randomRoom = localStorage.getItem('randomRoom') || ''
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

onMounted(() => {
  const appid = route.query.appid as string
  if (!appid) {
    router.push({ name: 'error' })
    return
  }
  
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
  
  store._state = route.query.state as string || null
  store.redirectUrl = route.query.redirecturl as string || null
  store.appId = route.query.appid as string || null
  store.appPublicKey = route.query.publickey as string || null
  store.scope = route.query.scope as string || null
})
</script>

<style src="./Initial.scss" scoped lang="scss"></style>
