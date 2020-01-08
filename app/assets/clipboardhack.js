if (document.getElementById('webview_copy') == null) {
    console.log("Adding clipboard hack");
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
        width: 120px;
        white-space: nowrap;
        font-family: sans-serif;
        box-shadow: 2px 2px 7px 0px rgba(50, 50, 50, 0.5);
    }

    #cbh-custom-menu li {

        padding: 5px 10px;
    }

    #cbh-custom-menu li:hover {
        background-color: #4679BD;
        color: #fff;
        cursor: pointer;
    }
`;

    var cbh_html = `
<ul id='cbh-custom-menu'>
    <li id="webview_copy">Copy</li>
    <li id="webview_paste">Paste</li>
</ul>
`;

    /* inject CSS */
    let cbh_head = document.head || document.getElementsByTagName('head')[0];
    let cbh_style = document.createElement('style');
    cbh_style.type = 'text/css';
    cbh_style.appendChild(document.createTextNode(cbh_css));
    console.log(cbh_style);
    cbh_head.appendChild(cbh_style);
    document.body.innerHTML += cbh_html;

    /* JS code */

    var webview_copy_value = '';
    var webview_selected_item = {};
    window.addEventListener('click', function (e) {
        let cbh_menu = document.getElementById('cbh-custom-menu');
        cbh_menu.style.display = 'none';

    }, true);

    document.addEventListener('contextmenu', function (evt) {
        webview_selected_item = evt.path[0];
        webview_copy_value = window.getSelection().toString();
        let cbh_menu = document.getElementById('cbh-custom-menu');
        cbh_menu.style.top = `${evt.clientY}px`;
        cbh_menu.style.left = `${evt.clientX}px`;
        if (window.innerHeight - 50 < evt.clientY){
            cbh_menu.style.top = `${evt.clientY-50}px`;
        }
        if (window.innerHeight - 50 < evt.clientX){
            cbh_menu.style.left = `${evt.clientX-70}px`;
        }

        cbh_menu.style.display = 'block';
        evt.preventDefault();
    }, false);

    document.getElementById('webview_copy').onclick = function () {
        console.log("copy!!", webview_copy_value);

        window.flutter_inappwebview.callHandler('COPY', webview_copy_value).then(function (result) {

        });
    }
    document.getElementById('webview_paste').onclick = function () {

        window.flutter_inappwebview.callHandler('PASTE', webview_copy_value).then(function (result) {
            webview_selected_item.select();
            document.execCommand("insertHTML", false, result);
        });
    }



}