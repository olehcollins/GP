import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="noticetoggle"
export default class extends Controller {
  static targets = ["notice"];
  connect() {
    console.log("connected");
  }

  fire() {
    this.noticeTarget.classList.add("d-none");
    console.log("working");
  }
}
// document.addEventListener("DOMContentLoaded", () => {
//   console.log(document.querySelector(".test"));

//   const noticeBtn = document.querySelector("btn-notice");
//   const noticeBox = document.querySelector("open-notice");

//   //eventhandle
//   const handleEvent = () => {
//     noticeBox.classList.toggle("open-notice");
//   };

//   noticeBtn.addEventListener("click", handleEvent);
// });
