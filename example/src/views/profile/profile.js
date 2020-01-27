import threebotService from "../../services/threebotService"

export default {
  name: 'profile',
  components: {},
  props: [],
  data() {
    return {
      user: window.localStorage.getItem('profile') ? JSON.parse(window.localStorage.getItem('profile')) : {},
      seiResponse: null
    }
  },
  computed: {

  },
  mounted() {
    console.log("SEI: ", this.user.email.sei);
    threebotService.verifySignedEmailIdentifier(this.user.email.sei).then(response => this.seiResponse = response.data);
  },
  methods: {

  }
}
