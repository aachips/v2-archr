import Vue from 'vue';
import IntakeForm from './components/IntakeForm.vue';

Vue.config.productionTip = false;

new Vue({
  render: h => h(IntakeForm),
}).$mount('#app');
