<template>
  <div class="home">
    <p>ThreeFold login example, please choose a type of login</p>
    <div class="buttons">
      <button @click="loginWithCustomScope({email: false})">Authenticate and get the users email.</button>
      <button @click="loginWithCustomScope({derivedSeed: false})">Authenticate and get the derived seed.</button>
      <button @click="loginWithCustomScope({email: false, derivedSeed: false})">Authenticate and get the users email and derived seed.</button>
      <br>
      <button @click="loginWithCustomScope({email: true})">Authenticate and get the users email.[Mandatory]</button>
      <button @click="loginWithCustomScope({derivedSeed: true})">Authenticate and get the derived seed.[Mandatory]</button>
      <button @click="loginWithCustomScope({email: true, derivedSeed: true})">Authenticate and get the users email and derived seed.[Mandatory]</button>
    </div>


    <p>Login object</p>
    <pre>{{profile}}</pre>
  </div>
</template>

<script lang="ts">
  import { ThreefoldLogin, generateRandomString } from '@threefoldjimber/threefold_login';
import { threefoldBackend, redirect_url, appId, seedPhrase, kycBackend } from '../config/config'
  import { defineComponent, ref } from 'vue'

  const profile = ref({});

  const popupCenter = (url: string, title: string, w: number, h: number) => {
    // Fixes dual-screen position                             Most browsers      Firefox
    const dualScreenLeft = window.screenLeft !==  undefined ? window.screenLeft : window.screenX;
    const dualScreenTop = window.screenTop !==  undefined   ? window.screenTop  : window.screenY;

    const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    const systemZoom = width / window.screen.availWidth;
    const left = (width - w) / 2 / systemZoom + dualScreenLeft
    const top = (height - h) / 2 / systemZoom + dualScreenTop
    const newWindow = window.open(url, title,
        `
      scrollbars=yes,
      width=${w / systemZoom},
      height=${h / systemZoom},
      top=${top},
      left=${left}
      `
    )

    if (newWindow) newWindow.focus();

    return newWindow
  }

  const loginWithCustomScope = async (scope: Record<string, boolean>) => {
    const login = new ThreefoldLogin(threefoldBackend,
        appId,
        seedPhrase,
        redirect_url,
        kycBackend);

    await login.init();

    const state = generateRandomString();

    const extraParams = {
      scope: JSON.stringify(scope),
    };

    window.localStorage.setItem("state", state)
    const loginUrl = login.generateLoginUrl(state, extraParams);

    const popup = popupCenter(loginUrl, 'ThreeFold login', 800, 550);

    window.onmessage = function (e: MessageEvent) {
      if (e.data.message === 'threefoldLoginRedirectSuccess') {
        profile.value = e.data.profileData
        popup?.close();
      }
    };
  }

  export default defineComponent({
    setup() {
      return { loginWithCustomScope, profile }
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