import VueQr from 'vue-qr'
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'register',
  components: {
    VueQr
  },
  props: [],
  data () {
    return {
      step: 0,
      email: '',
      valid: false,
      alone: false,
      wasEverAlone: false,
      areYouSureDialog: false,
      youWereNeverAloneDialog: false,
      proceedAnyway: false,
      emailRegex: new RegExp(/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}/),
      emailRules: [
        v => !!v || 'Email is required',
        v => this.emailRegex.test(v) || 'Email doesn\'t seems valid',
        v => v.length <= 80 || 'Email must be less than 80 characters'
      ],
      didLeavePage: false,
      rechecked: false,
      scannedFlag: false,
      mailsent: false,
      isMobile: /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    }
  },
  computed: {
    ...mapGetters([
      'keys',
      'doubleName',
      'hash',
      'signed',
      'redirectUrl',
      'scannedFlagUp',
      'scope',
      'appId',
      'appPublicKey',
      'emailVerificationStatus',
      'phrase'
    ]),
    qrText () {
      return JSON.stringify({
        hash: this.hash,
        doubleName: this.doubleName,
        email: this.email,
        scope: this.scope,
        appId: this.appId,
        appPublicKey: this.appPublicKey,
        phrase: this.keys.phrase
      })
    }
  },
  mounted () {
    this.$store.subscribe((mutation) => {
      switch (mutation.type) {
        case 'setScannedFlagUp':
          this.scannedFlag = true
          break
      }
    })
    this.generateKeys()
    window.onblur = this.lostFocus
    window.onfocus = this.gotFocus
  },
  methods: {
    ...mapActions([
      'generateKeys',
      'registerUser',
      'forceRefetchStatus',
      'checkEmailVerification',
      'sendValidationEmail'
    ]),
    lostFocus () {
      console.log(`Lost focus, set flag`)
      this.didLeavePage = true
    },
    gotFocus () {
      console.log(`--- Got focus again, flag is ${this.didLeavePage}`)
      if (this.didLeavePage) {
        if (!this.rechecked) {
          this.forceRefetchStatus()
        }
        this.rechecked = true
      }
    },
    confirmDialog () {
      if (this.wasEverAlone) {
        this.step = 3
        this.areYouSureDialog = false
      } else {
        this.youWereNeverAloneDialog = true
      }
    },
    giveMeAnOtherChance () {
      this.areYouSureDialog = false
      this.youWereNeverAloneDialog = false
      this.proceedAnyway = false
    },
    proceed () {
      this.areYouSureDialog = false
      this.youWereNeverAloneDialog = false
      this.step = 3
    },
    openApp () {
      if (this.isMobile) {
        var url = `threebot://register/?privateKey=${encodeURIComponent(this.keys.privateKey)}&phrase=${encodeURIComponent(this.keys.phrase)}&state=${encodeURIComponent(this.hash)}&mobile=true&doubleName=${encodeURIComponent(this.doubleName)}&email=${encodeURIComponent(this.email)}`
        if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
        if (this.appPublicKey) url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`
        console.log(url)
        if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
          window.location.replace(url)
        } else if (/Android|webOS|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
          window.open(url)
        }
      }
    }
  },
  watch: {
    alone (val) {
      if (val) {
        this.wasEverAlone = true
      }
    },
    step (val) {
      if (val === 2) {
        this.registerUser({
          email: this.email
        })
      } else if (val === 3) {
        this.openApp()
      }
    },
    signed (val) {
      console.log('its signed register', val)
      if (val && val.signedHash) {
        this.step = 4
        if (!this.mailsent) {
          this.sendValidationEmail({
            email: this.email
          })
          this.mailsent = true
        }
      }
    }
  }
}
