import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'verify-email',
  components: {},
  props: [],
  data () {
    return {
      url: null,
      isMobile: /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    }
  },
  computed: {
    ...mapGetters([
      'emailVerificationStatus'
    ])
  },
  mounted () {
    this.validateEmail({
      userId: this.$route.query.userId,
      verificationCode: this.$route.query.verificationCode
    })
  },
  methods: {
    ...mapActions([
      'validateEmail',
      'saveState',
      'setDoubleName',
      'setScope',
      'setAppId',
      'setAppPublicKey',
      'loginUser'
    ]),
    openApp () {
      if (this.isMobile) {
        var url = `threebot://login/?state=${encodeURIComponent(this.hash)}&mobile=true`
        if (this.scope) url += `&scope=${encodeURIComponent(this.scope)}`
        if (this.appId) url += `&appId=${encodeURIComponent(this.appId)}`
        if (this.appPublicKey) url += `&appPublicKey=${encodeURIComponent(this.appPublicKey)}`
        window.open(url)
      }
    }
  },
  watch: {
    emailVerificationStatus (val) {
      console.log(`emailVerificationStatus`, val)
      console.log(`this.$route.query`, this.$route.query)
      if (!val.checking && val.checked && val.valid) {
        console.log(`Log in`)
        this.saveState({
          hash: this.$route.query.hash,
          redirectUrl: window.atob(this.$route.query.redirecturl)
        })

        this.setDoubleName(this.$route.query.doublename)

        this.setScope(this.$route.query.scope || null)
        this.setAppId(this.$route.query.appid || null)
        this.setAppPublicKey(this.$route.query.publickey || null)

        var isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
        this.loginUser({ mobile: isMobile, firstTime: false })
        this.$router.push({ name: 'login', params: { again: true } })
      }
    }
  }
}
