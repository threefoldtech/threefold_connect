
<template>
  <v-app>
    <v-main fill-height>
      <v-btn id="skip" @click="showDisclaimerBeforeSkip" class="mt-5" absolute top right text>Skip</v-btn>
      <v-carousel
        light
        :continuous="false"
        class="pt-5"
        height="100%"
        hide-delimiter-background
      >
          <v-carousel-item>
            <v-col>
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Original.png"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">ThreeFold Connect</h3>
                  <p
                    class="subtitle-1 textCentered"
                  >Designed for you to connect and engage with the ThreeFold network.</p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item height="100%">
            <v-col  height="100%">
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Original.png"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">Meet ThreeFold's Vision</h3>
                  <p class="subtitle-1 textCentered">
                    A revolutionary digital network that executes your digital needs.
                    With ThreeFold, everything changes: move from an app-centric to a you-centric digital world. Start your journey towards digital freedom.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item>
            <v-col height="100%" >
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Social.png"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">You are at the centre</h3>
                  <p class="subtitle-1 textCentered">
                    Enter a decentralised, private social space where you own and control your privacy & personal data.
                    <br />No Ads. No fake news. No gimmicks.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item>
            <v-col height="100%" >
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Wallet.png"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">Be your own bank</h3>
                  <p class="subtitle-1 textCentered">
                    ThreeFold Connect is equipped with its own digital wallet,
                    giving you access to a global market of currencies and assets.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>

          <v-carousel-item>
            <v-col height="100%" >
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Assistance.png"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">What's coming next?</h3>
                  <p class="subtitle-1 textCentered">
                    Have your own personal assistant, social media, messaging and video conferencing,
                    office suite, browser, website publisher, circles, and more – all in one place.
                    Any application or service can live on the grid.
                    <br />Turn your imagination into a reality..
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item>
            <v-col height="100%" >
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Original.png"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3" justify="center">
                <div class="text-center">
                  <h3 class="mb-3">Get started</h3>
                  <p class="subtitle-1 textCentered">
                    Before you can start using the app, you must accept the
                    <v-btn
                    text
                    small
                    @click="showDisclaimer = true"
                  >Terms and conditions</v-btn>
                  </p>
                  <v-row justify="center">
                    <v-checkbox v-model="acceptedTT" label="I Accept the terms and conditions"></v-checkbox>
                  </v-row>
                  <v-btn
                    color="primary"
                    :disabled="!acceptedTT"
                    @click="finish"
                  >Get started!</v-btn>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
      </v-carousel>
    </v-main>
    <v-dialog v-model="showDialog" width="500">
      <v-card>
        <v-card-title>Accept the terms and conditions?</v-card-title>
        <v-card-text>
          <p>
            Before you can start using the app, you must accept the
            <v-btn
              text
              small
              @click="showDisclaimer = true"
            >Terms and conditions</v-btn>
          </p>
          <v-checkbox v-model="acceptedTT" label="I Accept the terms and conditions"></v-checkbox>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn :disabled="!acceptedTT" text @click="finish">continue</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
    <v-dialog v-model="showDisclaimer" fullscreen>
      <v-card>
        <v-card-title>
          <v-row>
            Terms & conditions
            <v-spacer></v-spacer>
            <v-btn icon @click="showDisclaimer = false">
              <v-icon>fas fa-times</v-icon>
            </v-btn>
          </v-row>
        </v-card-title>
          <iframe style="height:calc(100vh - 62px); width: 100%" src="https://wiki.threefold.io/#/legal" frameborder="0"></iframe>
      </v-card>
    </v-dialog>
  </v-app>
</template>

<script>
export default {
  name: 'App',
  data () {
    return {
      acceptedTT: false,
      showDisclaimer: false,
      showDialog: false
    }
  },
  methods: {
    showDisclaimerBeforeSkip () {
      this.showDialog = true
    },
    finish () {
      window.flutter_inappwebview.callHandler('FINISH')
    }
  }
}
</script>
<style>
#app {
}
#skip {
  z-index: 2;
}
.v-window__prev, .v-window__next {
  background-color: rgba(0, 0, 0, 0) !important;
}
</style>
