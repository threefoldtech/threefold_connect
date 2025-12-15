<template>
  <section class="verify-phone">
    <v-row justify="center">
      <v-col cols="12" md="8">
        <v-card>
          <v-toolbar color="primary">
            <v-toolbar-title class="text-h5 text-white">Verifying Phone number</v-toolbar-title>
          </v-toolbar>
          <v-card-text>
            <v-row v-if="store.smsVerificationStatus.checking" align="center" justify="center">
              <v-col cols="12" class="text-center">
                <v-progress-circular :size="100" :width="15" color="accent" indeterminate></v-progress-circular>
                <p class="text-subtitle-1 pt-3">Please wait while we validate your phone number</p>
              </v-col>
            </v-row>
            <v-row v-if="store.smsVerificationStatus.checked && store.smsVerificationStatus.valid" align="center" justify="center">
              <v-col cols="12" class="text-center">
                <v-icon :size="100" color="accent">mdi-check-circle</v-icon>
                <p class="text-subtitle-1 pt-3">Phone Validated</p>
                <v-btn v-if="isMobile" color="accent" @click="openApp">Open ThreeFold Connect app</v-btn>
              </v-col>
            </v-row>
            <v-row v-if="store.smsVerificationStatus.checked && !store.smsVerificationStatus.valid" align="center" justify="center">
              <v-col cols="12" class="text-center">
                <v-icon :size="100" color="error">mdi-close</v-icon>
                <p class="text-subtitle-1 pt-3">There was a problem validating your phone,<br>please contact support if this problem persists.<br><a href="https://support.grid.tf/">https://support.grid.tf/</a></p>
              </v-col>
            </v-row>
          </v-card-text>
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
  store.validateSms({
    userId: route.query.userId as string,
    verificationCode: route.query.verificationCode as string
  })
})

const openApp = () => {
  window.location.href = `${config.deeplink}`
}
</script>

<style src="./VerifySms.scss" scoped lang="scss"></style>
