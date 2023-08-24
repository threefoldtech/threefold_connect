import { mapGetters, mapActions } from "vuex";
import config from "../../../public/config";

export default {
  name: "login",
  components: {},
  props: [],
  data() {
    return {
      isMobile:
        /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
          navigator.userAgent
        ),
      cancelLogin: false,
      didLeavePage: false,
      dialog: false,
      loggedIn: false,
      ref: undefined,
    };
  },
  computed: {
    ...mapGetters([
      "signedAttempt",
      "redirectUrl",
      "doubleName",
      "firstTime",
      "randomImageId",
      "cancelLoginUp",
      "_state",
      "scope",
      "appId",
      "appPublicKey",
      "loginTimestamp",
      "loginTimeleft",
      "loginTimeout",
      "loginInterval",
    ]),
  },
  mounted() {
    this.resetTimer();
    this.ref = document.referrer;
  },
  methods: {
    ...mapActions(["resendNotification", "resetTimer"]),
    triggerResendNotification() {
      this.resendNotification();
    },
    openApp() {
      if (this.isMobile) {
        var url = `${config.deeplink}login/?state=${encodeURIComponent(
          this._state
        )}`;
        if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`;
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`;
        if (this.appPublicKey) {
          url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`;
        }
        console.log(url);
        if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
          window.location.replace(url);
        } else if (
          /Android|webOS|BlackBerry|IEMobile|Opera Mini/i.test(
            navigator.userAgent
          )
        ) {
          window.open(url);
        }
      }
    },
  },
  watch: {
    signedAttempt(val) {
      try {
        if (val) {
          console.log("signedAttemptObject: ", val);
          console.log("signedAttemptObject: ", JSON.stringify(val));
          window.localStorage.setItem("username", this.doubleName);

          var data = encodeURIComponent(JSON.stringify(val));
          console.log("data", data);

          if (data) {
            var union = "?";
            if (this.redirectUrl.indexOf("?") >= 0) {
              union = "&";
            }

            var safeRedirectUri;
            // Otherwise evil app could do appid+redirecturl = wallet.com + .evil.com = wallet.com.evil.com
            // Now its wallet.com/.evil.com
            if (this.redirectUrl[0] === "/") {
              safeRedirectUri = this.redirectUrl;
            } else {
              safeRedirectUri = "/" + this.redirectUrl;
            }

            console.log("!!!! this.doubleName: ", this.doubleName);
            var url = `//${this.appId}${safeRedirectUri}${union}signedAttempt=${data}`;

            if (!this.isRedirecting) {
              this.isRedirecting = true;
              console.log("Changing href: ", url);
              window.location.href = url;
            }
          } else {
            console.log("Missing data or signedState");
          }
        } else {
          console.log("Val was null");
        }
      } catch (e) {
        console.log("Something went wrong ... ", e);
      }
    },
    cancelLoginUp(val) {
      console.log(val);
      this.cancelLogin = true;

      var safeRedirectUri;
      if (this.redirectUrl[0] === "/") {
        safeRedirectUri = this.redirectUrl;
      } else {
        safeRedirectUri = "/" + this.redirectUrl;
      }

      var url = `//${this.appId}${safeRedirectUri}?error=CancelledByUser`;
      window.location.href = url;
    },
  },
};
