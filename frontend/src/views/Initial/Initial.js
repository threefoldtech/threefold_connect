import {
  mapActions,
  mapGetters
} from 'vuex'
var cookies = require('vue-cookies')

export default {
  name: 'initial',
  components: {},
  props: [],
  data () {
    return {
      firstvisit: false,
      appid: '',
      doubleName: '',
      valid: false,
      areYouSureDialog: false,
      nameRegex: new RegExp(/^(\w+)$/),
      nameRules: [
        v => !!v || 'Name is required',
        v => this.nameRegex.test(v) || 'Name can only contain alphanumeric characters.',
        v => v.length <= 50 || 'Name must be less than 50 characters.'
      ],
      continueToLogin: false,
      url: '',
      spinner: false,
      nameCheckerTimeOut: null
    }
  },
  mounted () {
    console.log(this.$route)
    this.setAttemptCanceled(false)
    var tempName = localStorage.getItem('username')
    if (tempName) {
      this.doubleName = tempName.split('.')[0]
      this.checkNameAvailability()
    }
    if (this.$route.query.logintoken && this.$route.query.doublename) {
      this.doubleName = this.$route.query.doublename
      this.setDoubleName(this.$route.query.doublename)
      this.url = `${this.$route.query.doublename} && ${this.$route.query.logintoken}`
      this.loginUser({
        mobile: true,
        firstTime: false,
        logintoken: this.$route.query.logintoken
      })
    }
    if (this.$route.query.logintoken) {
      this.spinner = true
    }
    this.firstvisit = !cookies.get('firstvisit')
    if (this.firstvisit) {
      cookies.set('firstvisit', true)
    }
    this.appid = this.$route.query.appid
    if (this.$route.query) {
      console.log(this.$route.query.redirecturl)
      this.$store.dispatch('saveState', {
        hash: this.$route.query.state,
        redirectUrl: this.$route.query.redirecturl
      })
      if (this.$route.query.scope === undefined) this.setScope(JSON.stringify({ doubleName: true, email: false, keys: false }))
      else this.setScope(this.$route.query.scope || null)
      this.setAppId(this.$route.query.appid || null)
      this.setAppPublicKey(this.$route.query.publickey || null)
    } else {
      this.$router.push('error')
    }
  },
  computed: {
    ...mapGetters([
      'nameCheckStatus',
      'hash',
      'scope',
      'appId',
      'appPublicKey',
      'signed',
      'redirectUrl'
    ])
  },
  methods: {
    ...mapActions([
      'setDoubleName',
      'loginUser',
      'setScope',
      'setAppId',
      'setAppPublicKey',
      'checkName',
      'clearCheckStatus',
      'setAttemptCanceled'
    ]),
    registerOrLogin () {
      // @click="isMobile() ? areYouSureDialog = true : register()"
      console.log('This button?')
      // if (this.actionBtnDisabled()) {
      //   this.setDoubleName(this.doubleName)
      //   if (this.nameCheckStatus.checked && this.nameCheckStatus.available) this.register()
      //   else this.login()
      // }
      if (this.actionBtnDisabled()) {
        this.setDoubleName(this.doubleName)

        if (this.nameCheckStatus.checked && this.nameCheckStatus.available) {
          if (this.isMobile()) {
            this.areYouSureDialog = true
          } else {
            this.register()
          }
        } else {
          this.login()
        }
      }
    },
    isMobile () {
      return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    },
    login () {
      var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
      this.loginUser({
        mobile: isMobile,
        firstTime: false
      })
      if (isMobile) {
        var url = `threebot://login/?state=${encodeURIComponent(this.hash)}&mobile=true`
        if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
        if (this.appPublicKey) url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`
        if (this.$route.query.logintoken) url += `&logintoken=${encodeURIComponent(this.$route.query.logintoken)}`
        window.open(url)
      }
      this.$router.push({
        name: 'login'
      })
    },
    openAppToRegister () {
      var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)

      // window.open('https://google.be#' + isMobile)
      if (isMobile) {
        var url = `threebot://registerAccount/?doubleName=${encodeURIComponent(this.doubleName)}`

        if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
          window.location.replace(url)
        } else if (/Android|webOS|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
          window.open(url)
        }
      }
    },
    register () {
      this.$router.push({
        name: 'register'
      })
    },
    checkNameAvailability () {
      this.clearCheckStatus()
      if (this.doubleName) {
        if (this.nameCheckerTimeOut != null) clearTimeout(this.nameCheckerTimeOut)
        this.nameCheckerTimeOut = setTimeout(() => {
          this.checkName(this.doubleName)
        }, 500)
      }
    },
    hasAppid () {
      return this.$route.query.appid !== undefined
    },
    actionBtnDisabled () {
      if (!this.nameCheckStatus.available && !this.hasAppid()) return false // login and appid = btn disabled
      return true // !(this.nameCheckStatus.checked && !this.nameCheckStatus.checking && this.valid)
    }
  },
  watch: {
    signed (val) {
      this.url = 'url'
      console.log(`signed`)
      if (val) {
        console.log(`------`)
        console.log(`------`)
        console.log(`------`)
        console.log(`------`)
        console.log(`------`)
        console.log(`Signed, continue`)
        var signedHash = encodeURIComponent(val.signedHash)
        var data = encodeURIComponent(JSON.stringify(val.data))
        var union = '&'
        if (this.redirectUrl.indexOf('?') >= 0) {
          union = '&'
        } else {
          union = '?'
        }
        var url = `${this.$route.query.redirecturl}${union}username=${this.doubleName}&signedhash=${signedHash}&data=${data}`
        console.log(`Redirecting to ${url}`)
        this.url = url
        window.location.href = url
      }
    }
  }
}
