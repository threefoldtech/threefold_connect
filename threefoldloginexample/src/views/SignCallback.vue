<template>
  <div class="callback">
    <p>Processing signature...</p>
  </div>
</template>

<script lang="ts">
import { ThreefoldLogin } from '@threefoldjimber/threefold_login';
import { threefoldBackend, sign_redirect_url, appId, seedPhrase, kycBackend } from '../config/config';
import { defineComponent } from 'vue';

export default defineComponent({
  async setup() {
    const login = new ThreefoldLogin(
      threefoldBackend,
      appId,
      seedPhrase,
      sign_redirect_url,
      kycBackend
    );

    await login.init();

    const state = window.localStorage.getItem("state") as string;
    const redirectUrl = new URL(window.location.href);

    try {
      const signedData = await login.parseAndValidateRedirectUrl(redirectUrl, state);
      window.opener.postMessage({ message: 'threefoldSignRedirectSuccess', signedData: signedData });
      console.log('Signed data:', signedData);
    } catch (e) {
      console.error("Error processing signature", e);
    }
  }
});
</script>

<style scoped>
.callback {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  font-size: 18px;
  color: #42b983;
}
</style>
