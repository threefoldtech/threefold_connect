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
      nameCheckerTimeOut: null
    }
  },
  mounted () {
  },
  computed: {
    ...mapGetters([
      'nameCheckStatus',
      'signedSignAttempt',
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
      'setRandomRoom',
      'signDataUser'
    ]),
    async onSignIn () {
      const query = this.$route.query

      const appId = query.appId
      const dataHash = query.dataHash
      const dataUrl = query.dataUrl
      const isJson = query.isJson
      await this.signDataUser({
        doubleName: this.doubleName,
        appId: appId,
        isJson: isJson,
        dataUrlHash: dataHash,
        dataUrl: dataUrl
      })
      console.log('Done')
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
        }
      }
    else
      {
        console.log('Val was null')
      }
    } catch (e) {
      console.log('Something went wrong ... ', e)
    }
  }
}
,
cancelLoginUp(val)
{
}
}
