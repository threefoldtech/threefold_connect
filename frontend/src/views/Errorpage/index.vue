<template>
  <section class="errorpage fill-height">
    <v-row justify="center" align="center" class="fill-height">
      <v-col cols="12" sm="10" md="8" lg="6" xl="5">
        <v-card class="modern-card">
          <div class="text-center pa-6 pb-4">
            <v-avatar size="80" class="mb-4">
              <v-img src="/logo.png" alt="ThreeFold Connect"></v-img>
            </v-avatar>
            <h1 class="text-h5 font-weight-bold mb-2" style="color: #1E293B;">
              Oops! Something Went Wrong
            </h1>
            <p class="text-body-2" style="color: #64748B;">
              We couldn't process your request
            </p>
          </div>

          <v-card-text class="px-6 pb-6">
            <v-alert
              type="warning"
              variant="tonal"
              rounded="lg"
              class="mb-6"
            >
              <div class="text-body-2">
                <strong>Missing Parameters:</strong> We didn't receive the required information to complete this action.
              </div>
            </v-alert>

            <div class="mb-6">
              <p class="text-body-1 mb-3" style="color: #475569;">
                This page requires specific parameters from a third-party application. You cannot access it directly.
              </p>
              <p class="text-body-2" style="color: #64748B;">
                If you want to register a new account, please download the ThreeFold Connect app:
              </p>
            </div>

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

            <v-divider class="my-6"></v-divider>

            <div class="text-center">
              <p class="text-body-2 mb-4" style="color: #64748B;">
                Need help? Visit our support center
              </p>
              <v-btn
                href="https://support.grid.tf/"
                target="_blank"
                color="primary"
                variant="outlined"
                rounded="lg"
                class="text-none"
              >
                <v-icon start>mdi-help-circle</v-icon>
                Contact Support
              </v-btn>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </section>
</template>

<script setup lang="ts">
</script>

<style src="./Errorpage.scss" scoped lang="scss"></style>
