<template>
  <div class="home">
    <p>Logging you in ...</p>
  </div>
</template>

<script lang="ts">
import { ThreefoldLogin, generateRandomString } from '@threefoldjimber/threefold_login/dist';
import { threefoldBackend, redirect_url, appId, seedPhrase } from '@/config/config'
import { defineComponent } from 'vue'

export default defineComponent({
  async setup() {
    const login = new ThreefoldLogin(threefoldBackend,
        appId,
        seedPhrase,
        redirect_url);

    await login.init();

    const state = window.localStorage.getItem("state") as string
    const redirectUrl = new URL(window.location.href)

    try {
      const profileData = await login.parseAndValidateRedirectUrl(redirectUrl, state);
      window.opener.postMessage({message: 'threefoldLoginRedirectSuccess', profileData: profileData});
      console.log(profileData)
    } catch (e){
      console.error("booboo was made", e)
    }
  }
})
</script>

<style>
button {
  display: block;
  padding: 5px;
  margin: 10px;
  width: 100%;

}
</style>