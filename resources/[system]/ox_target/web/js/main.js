import { createOptions } from "./createOptions.js";

const target = document.querySelector(".target");
const optionsWrapper = document.getElementById("options-wrapper");
const targetEye = document.getElementById("target-eye");
const root = document.documentElement;

function applyTheme(value) {
  const match = value.trim().match(/^#([\da-f]{3}|[\da-f]{6})$/i);
  if (!match) return;

  const hex = match[1].length === 3
    ? match[1].split("").map((character) => character + character).join("")
    : match[1];
  const color = Number.parseInt(hex, 16);

  root.style.setProperty("--target-active", `#${hex}`);
  root.style.setProperty(
    "--target-active-rgb",
    `${(color >> 16) & 255}, ${(color >> 8) & 255}, ${color & 255}`,
  );
}

window.addEventListener("message", (event) => {
  switch (event.data.event) {
    case "visible": {
      optionsWrapper.innerHTML = "";
      target.style.display = event.data.state ? "flex" : "none";

      if (typeof event.data.theme === "string" && event.data.theme) {
        applyTheme(event.data.theme);
      }

      return targetEye.classList.remove("valid");
    }

    case "leftTarget": {
      optionsWrapper.innerHTML = "";
      target.style.display = "none";
      return targetEye.classList.remove("valid");
    }

    case "setTarget": {
      optionsWrapper.innerHTML = "";
      target.style.display = "flex";
      targetEye.classList.add("valid");

      if (event.data.options) {
        for (const type in event.data.options) {
          event.data.options[type].forEach((data, id) => {
            createOptions(type, data, id + 1);
          });
        }
      }

      if (event.data.zones) {
        for (let i = 0; i < event.data.zones.length; i++) {
          event.data.zones[i].forEach((data, id) => {
            createOptions("zones", data, id + 1, i + 1);
          });
        }
      }
    }
  }
});
