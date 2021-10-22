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
    if(this.user.email && this.user.email.sei) {
      threebotService.verifySignedEmailIdentifier(this.user.email.sei).then(response => this.seiResponse = response.data);
    }

    if(this.user.phone && this.user.phone.spi) {
      threebotService.verifySignedPhoneIdentifier(this.user.phone.spi).then(response => this.spiResponse = response.data);
    }

    if(this.user.identityName && this.user.identityName.signedIdentityNameIdentifier) {
      threebotService.verifySignedIdentityIdentifier('signedIdentityNameIdentifier', this.user.identityName.signedIdentityNameIdentifier).
      then(response => this.signedIdentityNameResponse = response.data);

    }

    if(this.user.identityDOB && this.user.identityDOB.signedIdentityDOBIdentifier) {
      threebotService.verifySignedIdentityIdentifier('signedIdentityDOBIdentifier', this.user.identityDOB.signedIdentityDOBIdentifier).
      then(response => this.signedIdentityDOBResponse = response.data);

    }


    if(this.user.identityGender && this.user.identityGender.signedIdentityGenderIdentifier) {
      threebotService.verifySignedIdentityIdentifier('signedIdentityGenderIdentifier', this.user.identityGender.signedIdentityGenderIdentifier).
      then(response => this.signedIdentityGenderResponse = response.data);

    }


    if(this.user.identityCountry && this.user.identityCountry.signedIdentityCountryIdentifier) {
      threebotService.verifySignedIdentityIdentifier('signedIdentityCountryIdentifier', this.user.identityCountry.signedIdentityCountryIdentifier).
      then(response => this.signedIdentityCountryResponse = response.data);

    }

    if(this.user.identityDocumentMeta && this.user.identityDocumentMeta.signedIdentityDocumentMetaIdentifier) {
      threebotService.verifySignedIdentityIdentifier('signedIdentityDocumentMetaIdentifier', this.user.identityDocumentMeta.signedIdentityDocumentMetaIdentifier).
      then(response => this.signedIdentityDocumentMetaResponse = response.data);

    }

  },
  methods: {}
}
