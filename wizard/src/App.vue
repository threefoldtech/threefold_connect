
<template>
  <v-app>
    <v-content fill-height>
      <v-btn
        onclick="window.flutter_inappwebview.callHandler('FINISH')"
        class="mt-5"
        absolute
        top
        right
        text
      >Skip</v-btn>
      <v-carousel :continuous="false" class="pt-5" height="100%" delimiter-icon="fas fa-circle" next-icon="fas fa-chevron-right" prev-icon="fas fa-chevron-left">
        <v-col justify="center" class="fill-height">
          <v-carousel-item class="fill-height">
            <v-col class="fill-height">
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
                <div class="black--text text-center">
                  <h3 class="mb-3">3Bot Connect</h3>
                  <p
                    class="subtitle-1 textCentered"
                  >Designed for you to connect and engage with your 3Bot.</p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item height="100%">
            <v-col color="white" align="center" justify="center" height="100%">
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
                <div class="black--text text-center">
                  <h3 class="mb-3">Meet 3Bot's Vision</h3>
                  <p class="subtitle-1 textCentered">
                    A revolutionary digital avatar that executes your digital needs. With
                    3Bot, everything changes: move from an app-centric to a you-centric digital world. Start your journey
                    towards digital freedom.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item>
            <v-col color="white" height="100%">
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
                <div class="black--text text-center">
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
            <v-col color="white" height="100%">
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
                <div class="black--text text-center">
                  <h3 class="mb-3">Be your own bank</h3>
                  <p class="subtitle-1 textCentered">
                    3Bot is equipped with its own digital wallet, giving you access to a
                    global market of currencies and assets.
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>

          <v-carousel-item>
            <v-col color="white" height="100%">
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
                <div class="black--text text-center">
                  <h3 class="mb-3">What's coming next?</h3>
                  <p class="subtitle-1 textCentered">
                    Have your own personal assistant, social media, messaging and video conferencing, office suite,
                    browser,
                    website publisher, circles, and more – all in one place.
                    Any application or service can live on 3Bot.
                    <br />Turn your imagination into a reality..
                  </p>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
          <v-carousel-item>
            <v-col color="white" height="100%">
              <v-row justify="center" class="mb-5">
                <v-img
                  src="3Bot_Original.png"
                  class="mb-5"
                  aspect-ratio="1"
                  contain
                  max-width="270"
                  max-height="300"
                ></v-img>
              </v-row>
              <v-row class="ma-3 mt-5" justify="center">
                <div class="text-center mt-5">
                  <v-btn
                    color="primary"
                    onclick="window.flutter_inappwebview.callHandler('FINISH')"
                  >Get started!</v-btn>
                </div>
              </v-row>
            </v-col>
          </v-carousel-item>
        </v-col>
      </v-carousel>
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
}
</style>
