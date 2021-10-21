import threebotService from "../../services/threebotService"

export default {
  name: 'profile',
  components: {},
  props: [],
  data() {
    return {
      user: window.localStorage.getItem('profile') ? JSON.parse(window.localStorage.getItem('profile')) : {},
      seiResponse: null,
      spiResponse: null,
      signedIdentityNameResponse: null,
      signedIdentityDOBResponse: null,
      signedIdentityGenderResponse: null,
      signedIdentityCountryResponse: null,
      signedIdentityDocumentMetaResponse: null,
    }
  },
  computed: {},
  mounted() {
    console.log("SEI: ", this.user.email.sei);
    threebotService.verifySignedEmailIdentifier(this.user.email.sei).then(response => this.seiResponse = response.data);
    threebotService.verifySignedPhoneIdentifier(this.user.phone.spi).then(response => this.spiResponse = response.data);

    // Identity
    threebotService.verifySignedIdentityIdentifier('signedIdentityNameIdentifier', this.user.identityName.signedIdentityNameIdentifier).
    then(response => this.signedIdentityNameResponse = response.data);

    threebotService.verifySignedIdentityIdentifier('signedIdentityDOBIdentifier', this.user.identityDOB.signedIdentityDOBIdentifier).
    then(response => this.signedIdentityDOBResponse = response.data);

    threebotService.verifySignedIdentityIdentifier('signedIdentityGenderIdentifier', this.user.identityGender.signedIdentityGenderIdentifier).
    then(response => this.signedIdentityGenderResponse = response.data);

    threebotService.verifySignedIdentityIdentifier('signedIdentityCountryIdentifier', this.user.identityGender.signedIdentityCountryIdentifier).
    then(response => this.signedIdentityCountryResponse = response.data);

    threebotService.verifySignedIdentityIdentifier('signedIdentityDocumentMetaIdentifier', this.user.identityDocumentMeta.signedIdentityDocumentMetaIdentifier).
    then(response => this.signedIdentityDocumentMetaResponse = response.data);
  },
  methods: {}
}
