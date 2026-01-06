<template>
  <div class="home">
    <h1>ThreeFold Connect Examples</h1>
    
    <section class="section">
      <h2>Login Examples</h2>
      <p>Choose a type of login to test authentication flows:</p>
      <div class="buttons">
        <button @click="loginWithCustomScope({email: false})">Authenticate and get the users email.</button>
        <button @click="loginWithCustomScope({derivedSeed: false})">Authenticate and get the derived seed.</button>
        <button @click="loginWithCustomScope({email: false, derivedSeed: false})">Authenticate and get the users email and derived seed.</button>
        <br>
        <button @click="loginWithCustomScope({email: true})">Authenticate and get the users email.[Mandatory]</button>
        <button @click="loginWithCustomScope({derivedSeed: true})">Authenticate and get the derived seed.[Mandatory]</button>
        <button @click="loginWithCustomScope({email: true, derivedSeed: true})">Authenticate and get the users email and derived seed.[Mandatory]</button>
      </div>
    </section>

    <section class="section">
      <h2>Sign Example</h2>
      <p>Test the data signing flow:</p>
      <div class="buttons">
        <button @click="goToSign" class="sign-button">Go to Sign Example</button>
      </div>
    </section>

    <section v-if="profile && Object.keys(profile).length > 0" class="section">
      <h2>Login Result</h2>
      <pre>{{profile}}</pre>
    </section>
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
      const goToSign = () => {
        window.location.href = '/sign'
      }
      
      return { loginWithCustomScope, profile, goToSign }
    }
  })
</script>

<style scoped>
  .home {
    max-width: 900px;
    margin: 0 auto;
    padding: 20px;
  }

  h1 {
    color: #2c3e50;
    margin-bottom: 30px;
    text-align: center;
  }

  h2 {
    color: #42b983;
    margin-bottom: 15px;
  }

  .section {
    background: #f5f5f5;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
  }

  .section p {
    margin-bottom: 15px;
    color: #666;
  }

  .buttons {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  button {
    padding: 12px 20px;
    background: #42b983;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    transition: background 0.3s;
  }

  button:hover {
    background: #35a372;
  }

  .sign-button {
    background: #3498db;
    font-weight: bold;
  }

  .sign-button:hover {
    background: #2980b9;
  }

  pre {
    background: #2c3e50;
    color: #42b983;
    padding: 15px;
    border-radius: 4px;
    overflow-x: auto;
    font-size: 13px;
  }
</style>