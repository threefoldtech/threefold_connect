define(['babel-standalone', 'http-vue-loader'], function (Babel, httpVueLoader) {
    return {
      load: function (name, req, onload, config) {
        var path = req.toUrl(name)
        var link = document.createElement("link");
        link.type = "text/css";
        link.rel = "stylesheet";
        link.href = path;
        document.getElementsByTagName("head")[0].appendChild(link);
      }
    }
  })
  