import Vue from "vue";
import App from "./App.vue";

// Global styles — base variables/primitives, then the app shell, then the
// case-review sections. All demo CSS lives in src/assets/styles/ from here
// on (older components still carry scoped styles; externalize as touched).
import "./assets/styles/base.css";
import "./assets/styles/app-shell.css";
import "./assets/styles/case-review.css";

// Auth store — mounted on prototype so every component can access via this.$auth
import auth from "./store/auth";
Vue.prototype.$auth = auth;

Vue.config.productionTip = false;

new Vue({
  render: h => h(App)
}).$mount("#app");