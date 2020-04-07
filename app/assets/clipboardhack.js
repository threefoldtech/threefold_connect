function htmlencode(str) {
  var div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;
}

function clamp(num, min, max) {
  return num <= min ? min : num >= max ? max : num;
}

if (document.getElementById('webview_copy') == null) {
  let cbh_css = `
      #cbh-custom-menu {
        user-select: none;
        all: initial;
        display: none;
        z-index: 9999999;
        position: fixed;
        background-color: #fff;
        border: 1px solid #ddd;
        overflow: hidden;
        vertical-align: center;
        white-space: nowrap;
        font-family: sans-serif;
        box-shadow: 2px 2px 7px 0px rgba(50, 50, 50, 0.5);
        user-select: none;
    }

    #cbh-custom-menu li {
        height: 2.2em;
        text-align: center;
        vertical-align: middle;
        line-height: 1.6em;
        border-right: #00000021 solid 1px;
        display: inline-block;
        padding: 0.4em 1em;
    }

    #cbh-custom-menu li:last-child {
        border-right: 0;
    }

    #cbh-custom-menu li:hover {
        background-color: #4679BD;
        color: #fff;
        cursor: pointer;
    }
    `
  var cbh_html = `
    <ul id='cbh-custom-menu'>
      <li id="webview_copy">Copy</li>
      <li id="webview_paste">Paste</li>
    </ul>
    `

  let cbh_head = document.head || document.getElementsByTagName('head')[0]
  let cbh_style = document.createElement('style')

  cbh_style.type = 'text/css'
  cbh_style.appendChild(document.createTextNode(cbh_css))

  cbh_head.appendChild(cbh_style)
  document.getElementsByTagName('div')[0].innerHTML += cbh_html

  var webview_copy_value = '';
  var webview_selected_item = {};

  window.addEventListener('click', function () {
    let cbh_menu = document.getElementById('cbh-custom-menu');
    cbh_menu.style.display = 'none';

  }, true);

  document.addEventListener('contextmenu', function (evt) {
    webview_selected_item = evt.path[0];
    webview_copy_value = window.getSelection().toString();
    let cbh_menu = document.getElementById('cbh-custom-menu');

    const y = clamp(evt.clientY - 60, 0, window.innerHeight)
    const x = clamp(evt.clientX - 75, 0, window.innerWidth - 150)

    cbh_menu.style.top = `${y}px`;
    cbh_menu.style.left = `${x}px`;

    cbh_menu.style.display = 'block';
    evt.preventDefault();
  }, false);

  document.getElementById('webview_copy').onclick = function () {
    window.flutter_inappwebview.callHandler('COPY', webview_copy_value).then(function () {

    });
  }

  document.getElementById('webview_paste').onclick = function () {
    window.flutter_inappwebview.callHandler('PASTE', webview_copy_value).then(function (result) {
      webview_selected_item.select();
      document.execCommand("insertHTML", false, htmlencode(webview_selected_item.value + result));
    });
  }

}
