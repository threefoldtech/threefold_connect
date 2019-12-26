require.config({
  baseUrl: 'src/',
  paths: {
    // Transformers
    'babel': '../magic/transform/babel',
    'component': '../magic/transform/component',
    'view': '../magic/transform/view',
    'css': '../magic/transform/css',

    // Packages
    'babel-standalone': 'https://cdnjs.cloudflare.com/ajax/libs/babel-standalone/6.26.0/babel.min',
    'babel-polyfill': 'https://cdnjs.cloudflare.com/ajax/libs/babel-polyfill/6.26.0/polyfill.min',
    'vue': 'https://cdn.jsdelivr.net/npm/vue/dist/vue',
    'vuetify': 'https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify',
    
    // TODO: Change when releasing
    // 'vue': 'https://cdn.jsdelivr.net/npm/vue',
    'vuex': 'https://cdnjs.cloudflare.com/ajax/libs/vuex/3.0.1/vuex.min',
    'vue-router': 'https://cdnjs.cloudflare.com/ajax/libs/vue-router/3.0.2/vue-router.min',
    'http-vue-loader': '../magic/httpVueLoader'
  }
})
require(['babel!../src/main'])
