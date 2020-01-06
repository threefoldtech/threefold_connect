<template>
  <v-app>
    <div class="overlay primary darken-2"></div>
    <v-content class="fill-height">
      <v-container class="fill-height">
        <router-view/>
      </v-container>
    </v-content>
  </v-app>
</template>

<script>
export default {
  name: 'App'
}
</script>
