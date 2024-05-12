document.addEventListener("DOMContentLoaded", () => {
  console.log(document.querySelector(".test"));

  const noticeBtn = document.querySelector("btn-notice");
  const noticeBox = document.querySelector("open-notice");

  //eventhandle
  const handleEvent = () => {
    noticeBox.classList.toggle("open-notice");
  };

  noticeBtn.addEventListener("click", handleEvent);
});
