<template>
  <section class="errorpage fill-height">
    <v-container fluid class="fill-height pa-0">
      <v-row class="fill-height ma-0" justify="center" align="center">
      <v-col cols="12" sm="12" md="10" lg="8" xl="6">
        <div class="content-wrapper">
          <!-- Logo -->
          <div class="text-center mb-4">
            <v-img src="/logo.png" alt="ThreeFold" width="48" height="48" class="mx-auto mb-4"></v-img>
          </div>
          
          <!-- Page Header -->
          <div class="text-center page-header">
      <h1 class="page-title mb-2">
        ThreeFold Connect
      </h1>
      <p class="page-subtitle">
        Secure Two-Factor Authentication
      </p>
          </div>
          
          <v-card class="error-card">
          <v-card-text class="text-center pa-6">
            <!-- Error Icon -->
            <div class="error-icon-container mb-4">
              <div class="error-circle">
                <v-icon size="55" color="error">mdi-alert-circle-outline</v-icon>
              </div>
            </div>
            
            <h2 class="error-title mb-4">
              Oops... Something went wrong
            </h2>
            
            <p class="error-text mb-3">
              We didn't get the required parameters to make this work
            </p>
            
            <p class="error-text mb-3">
              You need to come from a third party app to use this.
            </p>
            
            <p class="error-text mb-6">
              If you want to register, you can do this from the ThreeFold Connect app.
            </p>
            
          </v-card-text>
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
  </section>
</template>

<script setup lang="ts">
</script>

<style src="./Errorpage.scss" scoped lang="scss"></style>
