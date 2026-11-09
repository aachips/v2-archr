import Vue from 'vue';
import VolunteerIntakeForm from './components/VolunteerIntakeForm.vue';

Vue.config.productionTip = false;

new Vue({
  render: h => h(VolunteerIntakeForm),
}).$mount('#app');
