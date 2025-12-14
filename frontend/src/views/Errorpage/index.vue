<template>
  <section class="errorpage">
    <v-row justify="center">
      <v-col cols="12" md="8">
        <v-card>
          <v-toolbar color="primary">
            <v-toolbar-title class="text-h5 text-white">
              Oops... Something went wrong
            </v-toolbar-title>
          </v-toolbar>
          <v-form>
            <v-card-text>
              <p>We didn't get the required parameters to make this work</p>
              <p>You need to come from a third party app to use this.</p>
              <p>If you want to register, you can do this from the ThreeFold Connect app.</p>
            </v-card-text>
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
</script>

<style src="./Errorpage.scss" scoped lang="scss"></style>
