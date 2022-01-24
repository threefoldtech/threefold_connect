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
  cancelLoginUp (val) {
  }
}
