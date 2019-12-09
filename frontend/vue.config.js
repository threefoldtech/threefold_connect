// var fs = require('fs')

module.exports = {
  devServer: {
    // https: {
    //   key: process.env.NODE_ENV !== 'production' ? fs.readFileSync(process.env.VUE_APP_CERTS_LOCATION_KEY || '/certificates/key.pem') : '', // eslint-disable-line
    //   cert: process.env.NODE_ENV !== 'production' ? fs.readFileSync(process.env.VUE_APP_CERTS_LOCATION_CERT || '/certificates/cert.pem') : '' // eslint-disable-line
    // },
    port: 8080,
    disableHostCheck: true
  }
}
