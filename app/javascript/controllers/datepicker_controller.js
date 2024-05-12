import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

// Connects to data-controller="datepicker"
// connect this controller to a from with a date field
export default class extends Controller {
  connect() {
    console.log("datepicker controller connected");
    flatpickr(this.element);
  }
}
