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
      url: '',
      spinner: false,
      rechecked: false,
      didLeavePage: false,
      nameCheckerTimeOut: null,
      isMobile: /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),
      randomRoom: ''
    }
  },
  mounted () {
    if (document.referrer) {
      if (new URL(document.referrer).host !== new URL(window.location.href).host) {
        console.log('SET URL, ', document.referrer)
        window.localStorage.setItem('returnUrl', document.referrer)
      }
    } else {
      console.log('URL cleared')
      window.localStorage.setItem('returnUrl', '')
    }

    if (this.isMobile) {
      this.randomRoom = window.localStorage.getItem('randomRoom')
      if (!this.randomRoom) {
        this.randomRoom = generateUUID()
        window.localStorage.setItem('randomRoom', this.randomRoom)
      }
      this.setrandomRoom(this.randomRoom)
    }
    window.onblur = this.lostFocus
    window.onfocus = this.gotFocus
    this.appid = this.$route.query.appid
    console.log(`this.$route.query.appid`, this.$route.query.appid)
    if (!this.appid) {
      this.redirectOrError()
    }
    console.log(this.$route)
    this.setAttemptCanceled(false)
    var tempName = localStorage.getItem('username')
    if (tempName) {
      console.log(`Got tempName`, tempName)
      this.doubleName = tempName.split('.')[0]
      this.checkNameAvailability()
    }
    this.firstvisit = !cookies.get('firstvisit')
    if (this.firstvisit) {
      cookies.set('firstvisit', true)
    }
    if (this.$route.query) {
      this.$store.dispatch('saveState', {
        _state: this._state ? this._state : this.$route.query.state,
        redirectUrl: this.$route.query.redirecturl
      })
      this.setAppId(this.$route.query.appid || null)
      this.setAppPublicKey(this.$route.query.publickey || null)
      if (this.$route.query.scope === undefined) {
        this.setScope(null)
      } else {
        this.setScope(this.$route.query.scope || null)
      }
    } else {
      this.redirectOrError()
    }
  },
  computed: {
    ...mapGetters([
      'nameCheckStatus',
      'signedAttempt',
      'redirectUrl',
      'firstTime',
      'randomImageId',
      'cancelLoginUp',
      '_state',
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
      'setrandomRoom'
    ]),
    lostFocus () {
      this.didLeavePage = true
    },
    promptLoginToMobileUser () {
      this.loginUserMobile({
        mobile: this.isMobile,
        firstTime: false
      })
      this.setrandomRoom(this.randomRoom)

      var url = `threebot://login?state=${encodeURIComponent(this._state)}&randomRoom=${this.randomRoom}`
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
    },
    login () {
      this.loginUser({
        doubleName: this.doubleName,
        mobile: this.isMobile,
        firstTime: false
      })
      if (this.isMobile) {
        var url = `threebot://login/?state=${encodeURIComponent(this._state)}`
        if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
        if (this.appPublicKey) url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`
        if (this.redirectUrl) url += `&redirecturl=${encodeURIComponent(this.redirectUrl)}`

        window.open(url)
      }
      this.$router.push({
        name: 'login'
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
    redirectOrError () {
      let returnUrl = window.localStorage.getItem('returnUrl')

      if (returnUrl) {
        if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
          window.location.replace(returnUrl)
        } else {
          window.location.href = returnUrl
        }
      } else {
        this.$router.push({ name: 'error' })
      }
    }
  },
  watch: {
    signedAttempt (val) {
      console.log(`signed`, val)
      if (!this.isMobile) return

      try {
        if (val) {
          window.localStorage.setItem('username', val.doubleName)
          var signedState = encodeURIComponent(val.signedState)
          var data

          if (typeof val.data === 'object' && val.data !== null) {
            data = encodeURIComponent(JSON.stringify(val.data))
          } else {
            data = encodeURIComponent(val.data)
          }

          console.log('signedState: ', signedState)
          console.log('!!!!data', data)

          if (data && signedState) {
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

            var url = `//${this.appId}${safeRedirectUri}${union}username=${val.doubleName}&signedState=${signedState}&data=${data}`
            if (!this.isRedirecting) {
              this.isRedirecting = true
              console.log('Changing href: ', url)
              window.location.href = url
            }
          } else {
            console.log('Missing data or signedState')
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

function generateUUID () {
  var d = new Date().getTime()
  var d2 = (performance && performance.now && (performance.now() * 1000)) || 0

  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = Math.random() * 16
    if (d > 0) {
      r = (d + r) % 16 | 0
      d = Math.floor(d / 16)
    } else {
      r = (d2 + r) % 16 | 0
      d2 = Math.floor(d2 / 16)
    }
    return (c === 'x' ? r : (r & 0x3 | 0x8)).toString(16)
  })
}
