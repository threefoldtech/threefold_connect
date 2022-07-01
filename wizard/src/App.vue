<template>
  <v-app class="transparent">
    <v-main fill-height>
      <v-carousel
        light
        :continuous="false"
        height="100%"
        hide-delimiter-background
      >
        <v-carousel-item>
          <header>
            <h2>Welcome to</h2>
            <img
              class="logo"
              src="threefold_connect_logo.svg"
              alt="threefold connect"
            />
          </header>
          <main>
            <p>
              ThreeFold Connect is your main access point to the ThreeFold Grid
              and more. Please allow us to quickly show you around!
            </p>
          </main>
        </v-carousel-item>
        <v-carousel-item>
          <header>
            <h1>
              MAXIMUM <br />
              <b>SECURITY</b>
            </h1>
            <img
              class="finger-print"
              src="fingerprint.svg"
              alt="threefold connect"
            />
          </header>
          <main>
            <p>
              The app provides a secure authentication mechanism that protects
              your identity on the ThreeFold Grid.
            </p>
          </main>
        </v-carousel-item>
        <v-carousel-item>
          <header>
            <h1 style="font-size: 39px">
              THREEFOLD <br />
              <b style="font-size: 58px">WALLET</b>
            </h1>
            <img
              style="
                width: 170px;
                height: 170.95px;
                position: absolute;
                top: 24vh;
              "
              src="TFT.svg"
              alt="threefold connect"
            />
          </header>
          <main>
            <p>
              Access your ThreeFold Wallet and your ThreeFold Tokens (TFT).
            </p>
          </main>
        </v-carousel-item>
        <v-carousel-item>
          <header>
            <h1 style="font-size: 32px">
              THREEFOLD <br />
              <b style="font-size: 64px">NEWS</b>
            </h1>
            <img
              style="
                width: 200px;
                height: 355.56px;
                position: absolute;
                top: 15vh;
              "
              src="news.svg"
              alt="threefold connect"
            />
          </header>
          <main>
            <p>
              Stay updated with ThreeFold’s latest updates via the News section
              within the app.
            </p>
          </main>
        </v-carousel-item>
        <v-carousel-item>
          <div class="journey">
            <img
              style="width: 200px; height: 355.56px"
              src="journey.svg"
              alt="threefold connect"
            />
            <h1 class="pt-8 pb-4" style="font-size: 38px">
              START YOUR <br />
              <b style="font-size: 39px">THREEFOLD</b> <br />
              <i style="font-size: 49px">JOURNEY</i>
            </h1>
            <v-btn @click="finish" color="#57BE8E" dark elevation="0">GET STARTED</v-btn>
                <v-checkbox
                  v-model="acceptedTT"
                  style="width: 70vw; font-size: 11px; color:red; padding-left:2rem"
                  >
                  <template v-slot:label>
                    <div  :class="{'red--text':getStartedClicked && !acceptedTT, 'black--text':!getStartedClicked || !acceptedTT}" class="mr-3">
                      I agree to ThreeFold’s<button
                      style="text-decoration: underline; display:inline-block; margin-top: 2px"
                      @click.stop.prevent="showDisclaimer = true"
                    >
                      Terms and Conditions
                    </button>
                    </div>
                  </template>
                </v-checkbox>
            <div class="spacer"></div>
          </div>
        </v-carousel-item>
      </v-carousel>
      <v-btn
        id="skip"
        @click="showDisclaimerBeforeSkip"
        class="mt-5"
        absolute
        top
        right
        text
        >Skip</v-btn
      >
    </v-main>
    <v-dialog v-model="showDialog" width="500">
      <v-card>
        <v-card-title>Accept the terms and conditions?</v-card-title>
        <v-card-text>
          <p>
            Before you can start using the app, you must accept the
            <v-btn text small @click="showDisclaimer = true"
              >Terms and conditions
            </v-btn>
          </p>
          <v-checkbox
            v-model="acceptedTT"
            label="I Accept the terms and conditions"
          ></v-checkbox>
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
        <iframe
          style="height: calc(100vh - 62px); width: 100%"
          src="https://library.threefold.me/info/legal/#/"
          frameborder="0"
        ></iframe>
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
      showDialog: false,
      getStartedClicked: false
    }
  },
  methods: {
    showDisclaimerBeforeSkip () {
      this.showDialog = true
    },
    finish () {
      if (this.acceptedTT) {
        window.flutter_inappwebview.callHandler('FINISH')
        return
      }
      this.getStartedClicked = true
    }
  }
}
</script>
<style lang="scss">
@import url("https://fonts.googleapis.com/css2?family=Lato&display=swap");
@import url("https://use.fontawesome.com/releases/v5.6.3/css/all.css");

*,
.v-application,
.v-application * {
  font-family: "Lato", serif !important;
}

h2 {
  font-weight: bold;
  font-size: 30px;
}

.v-application--wrap {
  background: url("/bg.svg");
  background-size: cover;
  background-position: left;
}

.v-responsive__content {
  display: flex;
  width: 100%;
  flex-flow: column;
  justify-content: center;

  header {
    display: flex;
    flex-flow: column;
    justify-content: center;
    text-align: center;
    align-items: center;
    height: 30%;

    h1 {
      font-weight: 800;
      text-align: center;
      font-size: 46px;
      line-height: 52px;
      letter-spacing: 0.03em;

      b {
        color: #57be8e;
        font-size: 50px;
      }
    }

    .logo {
      width: 77.77%;
      max-width: 700px;
    }

    .finger-print {
      position: absolute;
      top: 22vh;
      width: 140px;
      height: 248.89px;
    }
  }

  main {
    display: flex;
    flex-flow: column;
    justify-content: center;
    text-align: center;
    align-items: center;
    flex-grow: 1;
    height: 70%;

    p {
      font-size: 20px;
      width: 77.77%;
      text-align: center;
    }
  }
}

.v-carousel__controls {
  bottom: min(5vh) !important;
  width: 55vw !important;
  position: fixed !important;
  left: calc(50% - (55vw / 2)) !important;
  height: 5vw !important;

  .v-item-group {
    display: flex;
    justify-content: space-between;
    align-items: center;

    button {
      height: 4.5vw !important;
      width: 4.5vw !important;
      background: #1272b8;

      * {
        display: none;
      }

      &.v-btn--active {
        height: 5vw !important;
        width: 5vw !important;
        background: #57be8e;
      }
    }
  }
}

.v-window__next,
.v-window__prev {
  display: none !important;
}

.journey {
  height: 100vh;
  display: flex;
  flex-flow: column;
  justify-content: space-between;
  align-items: center;
  h1 {
    line-height: 33px;
    b {
      color: #57be8e;
    }
    i {
      font-style: normal;
      line-height: 40px;
      color: #1272b8;
    }
  }
  .v-btn {
    width: 230px;
    height: 39px;
    border-radius: 80px;
    background: #57be8e;
  }
  .v-btn--disabled {
  }
  .spacer {
    height: 20vh;
    width: 100%;
  }
}
.v-input--selection-controls__ripple,
.v-icon {
  font-family: "Font Awesome 5 Free" !important;
}
</style>
