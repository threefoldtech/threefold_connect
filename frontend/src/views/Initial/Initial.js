import {
  mapActions,
  mapGetters
} from 'vuex'
const cookies = require('vue-cookies')

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
      rechecked: false,
      didLeavePage: false,
      nameCheckerTimeOut: null
    }
  },
  mounted () {
    window.onblur = this.lostFocus
    window.onfocus = this.gotFocus

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
      this.$store.dispatch('saveState', {
        hash: this.hash ? this.hash : this.$route.query.state,
        redirectUrl: this.$route.query.redirecturl
      })
      this.setAppId(this.$route.query.appid || null)
      this.setAppPublicKey(this.$route.query.publickey || null)
      if (this.$route.query.scope === undefined) {
        this.setScope(JSON.stringify({ doubleName: true, email: false, keys: false }))
      } else {
        this.setScope(this.$route.query.scope || null)
      }
    } else {
      this.$router.push('error')
    }

    // If user is on mobile
    this.promptLoginToMobileUser()
  },
  computed: {
    ...mapGetters([
      'nameCheckStatus',
      'signed',
      'redirectUrl',
      'firstTime',
      'randomImageId',
      'cancelLoginUp',
      'hash',
      'scope',
      'appId',
      'appPublicKey'
    ])
  },
  methods: {
    ...mapActions([
      'setDoubleName',
      'loginUser',
      'loginUserMobile',
      'setScope',
      'setAppId',
      'setAppPublicKey',
      'checkName',
      'clearCheckStatus',
      'setAttemptCanceled',
      'forceRefetchStatus'
    ]),
    registerOrLogin () {
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
    lostFocus () {
      this.didLeavePage = true
    },
    gotFocus () {
      if (this.didLeavePage) {
        this.forceRefetchStatus()
      }
    },
    promptLoginToMobileUser () {
      var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)

      if (isMobile) {
        this.loginUserMobile({
          mobile: isMobile,
          firstTime: false
        })
        var url = `/api/openapp?state=${encodeURIComponent(this.hash)}&mobile=true`
        if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
        if (this.appPublicKey) url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`
        if (this.redirectUrl) url += `&redirecturl=${encodeURIComponent(this.redirectUrl)}`
        console.log(url)
        if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
          window.location.replace(url)
        } else if (/Android|webOS|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
          window.location.href = url
        }
      }
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
      try {
        if (val) {
          window.localStorage.setItem('username', val.doubleName)
          var signedHash = encodeURIComponent(val.signedHash)
          var data

          if (typeof val.data === 'object' && val.data !== null) {
            data = encodeURIComponent(JSON.stringify(val.data))
          } else {
            data = encodeURIComponent(val.data)
          }

          console.log('signedHash: ', signedHash)
          console.log('data', data)

          if (data && signedHash) {
            var union = '?'
            if (this.redirectUrl.indexOf('?') >= 0) {
              union = '&'
            }

            var safeRedirectUri
            // Otherwise evil app could do appid+redirecturl = wallet.com + .evil.com = wallet.com.evil.com
            // Now its wallet.com/.evil.com
            if (this.redirectUrl[0] === '/') {
              safeRedirectUri = this.redirectUrl
            } else {
              safeRedirectUri = '/' + this.redirectUrl
            }

            var url = `//${this.appId}${safeRedirectUri}${union}username=${val.doubleName}&signedhash=${signedHash}&data=${data}`
            if (!this.isRedirecting) {
              this.isRedirecting = true
              console.log('Changing href: ', url)
              window.location.href = url
            }
          } else {
            console.log('Missing data or signedHash')
          }
        } else {
          console.log('Val was null')
        }
      } catch (e) {
        console.log('Something went wrong ... ', e)
      }
    }
  },
  cancelLoginUp (val) {
    console.log(val)
    this.cancelLogin = true

    var safeRedirectUri
    if (this.redirectUrl[0] === '/') {
      safeRedirectUri = this.redirectUrl
    } else {
      safeRedirectUri = '/' + this.redirectUrl
    }

    var url = `//${this.appId}${safeRedirectUri}?error=CancelledByUser`
    window.location.href = url
  }
}
