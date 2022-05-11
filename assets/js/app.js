// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import DecoupledEditor from '@ckeditor/ckeditor5-build-decoupled-document';

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let Hooks = {
  Editor: {
    mounted() {
      this.el.style="display: none;";
      this.target = this.el.getAttribute('for');
      DecoupledEditor
      .create( document.querySelector(`#${this.target}`) )
      .then( editor => {
        editor.model.document.on( 'change:data', () => {
          data = editor.getData();
          if ( data != this.el.value ) {
            console.log( 'The data has changed!', data );
            this.el.value = data;
          }
        });
        document.querySelector(`#${this.target}_toolbar`).appendChild( editor.ui.view.toolbar.element );
        this.editor = editor;
        editor.setData(this.el.value);
      })
      .catch( error => {
        console.error( error );
      });
    },
    updated() {
      this.el.style="display: none;";
      console.log('updated', this.el.value)
      this.editor.setData(this.el.value)
    }
  }
};

const socketOptions = {
  hooks: Hooks,
  params: {
    _csrf_token: csrfToken
  }
};

let liveSocket = new LiveSocket("/live", Socket, socketOptions)

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
