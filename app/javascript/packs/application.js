require("@rails/ujs").start()
require("@rails/activestorage").start()

var jQuery = require("jquery");
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

import '../../assets/stylesheets/application'
import './Tocca'
import './select2'
import 'bootstrap/dist/js/bootstrap'
import './jquery-ui'
import './flatpickr'
// Подключаем файл русской локализации flatpickr_ru. Он переписан на js, чтобы webpacker понимаал его
import ru from "./flatpickr_ru"
document.addEventListener("DOMContentLoaded", () => {
  const myElem = document.getElementById("datepicker");
  flatpickr(myElem, {
    locale: ru
  });
});

import ApexCharts from 'apexcharts'
window.ApexCharts = ApexCharts

const images = require.context('../images', true)

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
