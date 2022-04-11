import {
  mapActions,
  mapGetters
} from 'vuex'

export default {
  name: 'initial',
  components: {},
  props: [],
  data () {
    return {
      appid: '',
      doubleName: '',
      valid: false,
      nameRegex: new RegExp(/^(\w+)$/),
      nameRules: [
        v => !!v || 'Name is required',
        v => this.nameRegex.test(v) || 'Name can only contain alphanumeric characters.',
        v => v.length <= 50 || 'Name must be less than 50 characters.'
      ],
      url: '',
      nameCheckerTimeOut: null,
      isSignAttemptOnGoing: false,
      isMobile: /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    }
  },
  mounted () {
    window.onfocus = this.gotFocus

    const query = this.$route.query

    const appId = query.appId
    const dataHash = query.dataHash
    const dataUrl = query.dataUrl
    const isJson = query.isJson
    const redirectUrl = query.redirectUrl
    const friendlyName = query.friendlyName
    const state = query.state

    if (this.isMobile) {
      this.randomRoom = window.localStorage.getItem('randomRoom')
      if (!this.randomRoom) {
        this.randomRoom = generateUUID()
        window.localStorage.setItem('randomRoom', this.randomRoom)
      }
      this.setRandomRoom(this.randomRoom)
    }

    if (!appId || !dataHash || !dataUrl || !isJson || !redirectUrl || !state || !friendlyName) {
      this.$router.push({ name: 'error' })
    }
  },
  computed: {
    ...mapGetters([
      'nameCheckStatus',
      'signedSignAttempt',
      'redirectUrl',
      'firstTime',
      'randomImageId',
      'cancelSignUp',
      '_state',
      'scope',
      'appId',
      'appPublicKey',
      'signAttemptOnGoing',
      'dataUrl',
      'dataUrlHash',
      'isJson',
      'friendlyName',
      '_state'
    ])
  },
  methods: {
    ...mapActions([
      'setDoubleName',
      'loginUser',
      'signUserMobile',
      'setScope',
      'setAppId',
      'setAppPublicKey',
      'checkName',
      'clearCheckStatus',
      'setSignAttemptCanceled',
      'setRandomRoom',
      'signDataUser',
      'resendSignNotification'
    ]),
    gotFocus () {
      this.randomRoom = window.localStorage.getItem('randomRoom')
      this.setRandomRoom(this.randomRoom)
    },
    async triggerResendSignSocket () {
      await this.resendSignNotification()
    },
    async promptToSignMobile () {
      const query = this.$route.query

      const state = query.state
      const appId = query.appId
      const dataHash = query.dataHash
      const dataUrl = query.dataUrl
      const isJson = query.isJson
      const redirectUrl = query.redirectUrl
      const friendlyName = query.friendlyName

      this.setRandomRoom(this.randomRoom)

      this.signUserMobile({
        state: state,
        appId: appId,
        dataUrlHash: dataHash,
        dataUrl: dataUrl,
        isJson: isJson,
        redirectUrl: redirectUrl,
        friendlyName: friendlyName
      })

      if (this.isMobile) {
        var url = `threebot://sign/?state=${encodeURIComponent(this._state)}&randomRoom=${this.randomRoom}`
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
        if (dataHash) url += `&dataHash=${encodeURIComponent(this.dataUrlHash)}`
        if (dataUrl) url += `&dataUrl=${encodeURIComponent(this.dataUrl)}`
        if (isJson) url += `&isJson=${encodeURIComponent(this.isJson)}`
        if (redirectUrl) url += `&redirectUrl=${encodeURIComponent(this.redirectUrl)}`
        if (friendlyName) url += `&friendlyName=${encodeURIComponent(this.friendlyName)}`
      }

      if (/iPhone|iPad|iPod/i.test(navigator.userAgent)) {
        window.location.replace(url)
      } else if (/Android|webOS|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
        window.location.href = url
      }
    },
    async onSignIn () {
      const query = this.$route.query

      const state = query.state
      const appId = query.appId
      const dataHash = query.dataHash
      const dataUrl = query.dataUrl
      const isJson = query.isJson
      const redirectUrl = query.redirectUrl
      const friendlyName = query.friendlyName
      await this.signDataUser({
        doubleName: this.doubleName,
        appId: appId,
        isJson: isJson,
        dataUrlHash: dataHash,
        dataUrl: dataUrl,
        friendlyName: friendlyName,
        redirectUrl: redirectUrl,
        state: state
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
    }
  },
  watch: {
    signedSignAttempt (val) {
      if (!val) {
        console.log('Missing data')
        return
      }

      try {
        console.log('signedAttemptObject: ', val)
        console.log('signedAttemptObject: ', JSON.stringify(val))
        window.localStorage.setItem('username', this.doubleName)

        var data = encodeURIComponent(JSON.stringify(val))
        console.log('data', data)

        if (data) {
          var union = '?'
          console.log('redirect url: ')
          console.log(this.redirectUrl)
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

          console.log('!!!! this.doubleName: ', this.doubleName)
          var url = `//${this.appId}${safeRedirectUri}${union}signedAttempt=${data}`

          if (!this.isRedirecting) {
            this.isRedirecting = true
            console.log('Changing href: ', url)
            window.location.href = url
          }
        } else {
          console.log('Val was null')
        }
      } catch (e) {
        console.log('Something went wrong ... ', e)
      }
    },
    cancelSignUp (val) {
      console.log('CANCELED')
      console.log(val)
      var safeRedirectUri
      if (this.redirectUrl[0] === '/') {
        safeRedirectUri = this.redirectUrl
      } else {
        safeRedirectUri = '/' + this.redirectUrl
      }

      var url = `//${this.appId}${safeRedirectUri}?error=CancelledByUser`
      window.location.href = url
    },
    signAttemptOnGoing (val) {
      this.isSignAttemptOnGoing = val
    }
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
