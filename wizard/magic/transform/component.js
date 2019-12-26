define(['babel-standalone', 'http-vue-loader'], function (Babel, httpVueLoader) {
  return {
    load: function (name, req, onload, config) {
      httpVueLoader(`src/components/${name}/index.vue`, name)().then(onload)
    }
  }
})
