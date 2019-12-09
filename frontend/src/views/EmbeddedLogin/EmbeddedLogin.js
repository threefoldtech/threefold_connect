import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'login',
  components: {},
  props: [],
  data () {
    return {
      isMobile: /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent),
      userKnown: false,
      username: null,
      attemptCreated: false
    }
  },
  computed: {
    ...mapGetters([
      'signed',
      'redirectUrl',
      'doubleName',
      'firstTime',
      'randomImageId',
      'hash',
      'scope',
      'appId',
      'appPublicKey'
    ])
  },
  mounted () {
    // This is dirty
    let container = document.getElementsByClassName('container')[0]
    container.style.margin = 0
    container.style.padding = 0
    //
    this.setAppId(this.$route.query.appId)
    window.addEventListener('message', (e) => {
      console.log('Got a message', e.data)
      if (e.data.type === '3botlogin-info') {
        console.log(e.data.data)
        this.createLoginAttempt(e.data.data)
      }
    })
    const username = window.localStorage.getItem('username')
    console.log('username is known')
    if (username) {
      this.userKnown = true
      this.username = username
      window.parent.postMessage({ type: '3botlogin-user-known-alert' }, '*')
    }
  },
  methods: {
    ...mapActions([
      'resendNotification',
      'setHash',
      'setAppId',
      'setScope',
      'setAppPublicKey',
      'loginUser'
    ]),
    // openApp() {
    //   if (this.isMobile) {
    //     var url = `threebot://login/?state=${encodeURIComponent(this.hash)}&mobile=true`
    //     if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`
    //     if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
    //     if (this.appPublicKey) url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`
    //     window.open(url)
    //   }
    // },
    requestLogin () {
      window.parent.postMessage({ type: '3botlogin-request-login-info' }, '*')
    },
    createLoginAttempt (data) {
      if (data.scope && data.publicKey && data.state) {
        this.attemptCreated = true
        this.setHash(data.state)
        this.setScope(data.scope)
        this.setAppPublicKey(data.publicKey)
        this.loginUser({ mobile: false, firstTime: false })
      }
    }
  },
  watch: {
    signed (val) {
      if (val) {
        console.log('ja gedomme!', val)
        val.username = this.doubleName
        val.signedhash = val.signedHash
        window.parent.postMessage({ type: '3botlogin-finished', data: val }, '*')
      }
    }
  }
}
