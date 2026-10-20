import { fetchNui } from "./fetchNui.js";
const optionsWrapper = document.getElementById("options-wrapper");
const progressElement = document.getElementById("interact-progress");

let currentIndex = 0;
let isHolding = false;
let holdStartTime = null;
let holdTimeout = null;
let defaultColor = null;
let defaultRgb = null;
let defaultStrong = null;

export function setDefaultColor(color, rgb, strong) {
  defaultColor = color;
  if (rgb) defaultRgb = rgb;
  if (strong) defaultStrong = strong;
  return defaultColor;
}

export function setCurrentIndex(newIndex) {
  currentIndex = newIndex;
  return currentIndex;
}

export function onSelect() {
  const options = optionsWrapper.querySelectorAll(".option-container");
  const option = options[currentIndex];

  if (!option) return;
  
  if (option.holdTime) {
    startHold(option);
  } else {
    fetchNui("select", [option.targetType, option.targetId]);
  }
}

function completeHold(option) {
  if (!isHolding) return;
  
  const options = optionsWrapper.querySelectorAll(".option-container");
  const currentOption = options[currentIndex];

  if (!currentOption) return;
  
  if (currentOption === option) {
    fetchNui("select", [option.targetType, option.targetId]);
  }
  resetHold();
}

export function resetHold() {
  isHolding = false;
  holdStartTime = null;
  clearTimeout(holdTimeout);
  progressElement.style.transition = "none";
  progressElement.style.height = "0";
}

function startHold(option) {
  if (isHolding) return;

  isHolding = true;
  holdStartTime = Date.now();
  progressElement.style.transition = `height ${option.holdTime}ms linear`;
  progressElement.style.height = "100%";

  holdTimeout = setTimeout(() => {
    completeHold(option);
  }, option.holdTime);
}

export function updateHighlight() {
  const options = optionsWrapper.querySelectorAll(".option-container");
  if (options.length > 0) {
    options.forEach(option => option.classList.remove("highlighted"));
    options[currentIndex].classList.add("highlighted");

    if (options[currentIndex].color) {
      const c = options[currentIndex].color
      const rgb = `${c[0]}, ${c[1]}, ${c[2]}`
      const color = `rgba(${rgb}, ${c[3] / 255})`
      const strong = `rgb(${rgb})`
      document.body.style.setProperty('--theme-color', color)
      document.body.style.setProperty('--theme-color-rgb', rgb)
      document.body.style.setProperty('--theme-color-strong', strong)
    } else {
      if (defaultColor)  document.body.style.setProperty('--theme-color', defaultColor)
      if (defaultRgb)    document.body.style.setProperty('--theme-color-rgb', defaultRgb)
      if (defaultStrong) document.body.style.setProperty('--theme-color-strong', defaultStrong)
    }
  }
}

window.addEventListener("wheel", (event) => {
  if (isHolding) return;
  
  const options = optionsWrapper.querySelectorAll(".option-container");
  if (options.length === 0) return;

  if (event.deltaY > 0) {
    currentIndex = setCurrentIndex((currentIndex + 1) % options.length);
  } else {
    currentIndex = setCurrentIndex((currentIndex - 1 + options.length) % options.length);
  }

  updateHighlight();

  fetchNui("currentOption", [currentIndex + 1]);
});

updateHighlight();


