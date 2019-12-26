define(['babel-standalone', 'babel-polyfill', 'http-vue-loader'], function (Babel, _, httpVueLoader) {
  return {
    load: function (name, req, onload, config) {
      // Dirty hack to prevent something like src/src/
      if (name.startsWith('./')){
        name.substr(2)
      }
      var path = req.toUrl(name)
      httpVueLoader.httpRequest(path + '.js').then(function (script) {
        onload.fromText(Babel.transform(script, {
          presets: [
            'es2015',
            'stage-3'
          ],
          plugins: [
            'transform-es2015-modules-amd'
          ]
        }).code)
      })
    }
  }
})
