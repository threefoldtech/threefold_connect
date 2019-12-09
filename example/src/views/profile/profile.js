export default {
  name: 'profile',
  components: {},
  props: [],
  data () {
    return {
      user: window.localStorage.getItem('profile') ? JSON.parse(window.localStorage.getItem('profile')) : {}
    }
  },
  computed: {

  },
  mounted () {

  },
  methods: {

  }
}
