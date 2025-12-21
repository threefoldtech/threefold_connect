<template>
  <div class="sign">
    <h1>ThreeFold Sign Example</h1>
    <p>This example demonstrates how to request a user to sign data using ThreeFold Connect.</p>
    
    <div class="form-section">
      <h2>Data to Sign</h2>
      <textarea 
        v-model="dataToSign" 
        placeholder="Enter the data you want the user to sign..."
        rows="6"
      ></textarea>
      
      <div class="options">
        <label>
          <input type="checkbox" v-model="isJson" />
          Data is JSON
        </label>
      </div>
      
      <button @click="requestSignature" :disabled="!dataToSign">
        Request Signature
      </button>
    </div>
    
    <div v-if="signedData" class="result-section">
      <h2>Signed Result</h2>
      <pre>{{ JSON.stringify(signedData, null, 2) }}</pre>
    </div>
  </div>
</template>

<script lang="ts">
import { ThreefoldLogin, generateRandomString } from '@threefoldjimber/threefold_login';
import { threefoldBackend, sign_redirect_url, appId, seedPhrase, kycBackend } from '../config/config';
import { defineComponent, ref } from 'vue';

const popupCenter = (url: string, title: string, w: number, h: number) => {
  const dualScreenLeft = window.screenLeft !== undefined ? window.screenLeft : window.screenX;
  const dualScreenTop = window.screenTop !== undefined ? window.screenTop : window.screenY;

  const width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
  const height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

  const systemZoom = width / window.screen.availWidth;
  const left = (width - w) / 2 / systemZoom + dualScreenLeft;
  const top = (height - h) / 2 / systemZoom + dualScreenTop;
  const newWindow = window.open(url, title,
    `
    scrollbars=yes,
    width=${w / systemZoom},
    height=${h / systemZoom},
    top=${top},
    left=${left}
    `
  );

  if (newWindow) newWindow.focus();
  return newWindow;
};

export default defineComponent({
  setup() {
    const dataToSign = ref('{"message": "Hello from ThreeFold Connect!"}');
    const isJson = ref(true);
    const signedData = ref(null);

    const requestSignature = async () => {
      const login = new ThreefoldLogin(
        threefoldBackend,
        appId,
        seedPhrase,
        sign_redirect_url,
        kycBackend
      );

      await login.init();

      const state = generateRandomString();
      window.localStorage.setItem("state", state);

      // Hash the data to sign
      const encoder = new TextEncoder();
      const data = encoder.encode(dataToSign.value);
      const hashBuffer = await crypto.subtle.digest('SHA-256', data);
      const hashArray = Array.from(new Uint8Array(hashBuffer));
      const dataHash = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
      
      // Create a data URL (you can use a real URL or base64 data URL)
      const dataUrl = `data:text/plain;base64,${btoa(dataToSign.value)}`;
      const friendlyName = 'Sign Example Data';

      // Create sign URL with data
      const signUrl = login.generateSignUrl(
        state,
        dataHash,
        dataUrl,
        isJson.value,
        friendlyName,
        sign_redirect_url
      );

      const popup = popupCenter(signUrl, 'ThreeFold Sign', 800, 550);

      window.onmessage = function (e: MessageEvent) {
        if (e.data.message === 'threefoldSignRedirectSuccess') {
          signedData.value = e.data.signedData;
          popup?.close();
        }
      };
    };

    return {
      dataToSign,
      isJson,
      signedData,
      requestSignature
    };
  }
});
</script>

<style scoped>
.sign {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

h1 {
  color: #2c3e50;
  margin-bottom: 10px;
}

h2 {
  color: #42b983;
  margin-top: 30px;
  margin-bottom: 15px;
}

.form-section {
  background: #f5f5f5;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-family: monospace;
  font-size: 14px;
  resize: vertical;
}

.options {
  margin: 15px 0;
}

.options label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

button {
  display: block;
  padding: 12px 24px;
  background: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  width: 100%;
  margin-top: 10px;
}

button:hover:not(:disabled) {
  background: #35a372;
}

button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.result-section {
  background: #f9f9f9;
  padding: 20px;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
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
