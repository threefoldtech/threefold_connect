<template>
  <v-app>
    <v-content fill-height>
      <v-layout justify-center fill-height>
        <v-layout column align-center justify-center>
          <router-view/>
        </v-layout>
      </v-layout>
    </v-content>
  </v-app>
</template>

<script>
export default {
  name: 'App'
}
</script>
<style>
#app {
  background: url("./assets/background.jpg");
  background-position: center;
  background-size: cover;
  background-repeat: no-repeat;
}
</style>
