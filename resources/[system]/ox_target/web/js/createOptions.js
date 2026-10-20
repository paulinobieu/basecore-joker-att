import { fetchNui } from "./fetchNui.js";

const target = document.querySelector(".target");
const optionsWrapper = document.getElementById("options-wrapper");

function onClick() {
  fetchNui("select", [this.targetType, this.targetId, this.zoneId]);
  optionsWrapper.innerHTML = "";
  target.style.display = "none";
}

export function createOptions(type, data, id, zoneId) {
  if (data.hide) return;

  const option = document.createElement("div");

  option.className = "target-text";
  option.textContent = data.label;
  option.targetType = type;
  option.targetId = id;
  option.zoneId = zoneId;

  option.addEventListener("mousedown", onClick);
  optionsWrapper.appendChild(option);
}
