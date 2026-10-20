function withOpacity(variableName) {
  return ({ opacityValue }) => {
    if (opacityValue !== undefined) {
      return `rgba(var(${variableName}), ${opacityValue})`;
    }
    return `rgb(var(${variableName}))`;
  };
}

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        primary: withOpacity("--main-color"),
      },
      fontFamily: {
        sans: ["Inter", "sans-serif"],
        inter: ["Inter", "sans-serif"],
      },
      backgroundImage: {
        "slot-normal":
          "linear-gradient(144deg, rgba(255, 255, 255, 0.00) 51.62%, rgba(255, 255, 255, 0.09) 120.89%), linear-gradient(rgba(255, 255, 255, 0.02), rgba(255, 255, 255, 0.02))",
        "slot-locked":
          "linear-gradient(rgba(255, 255, 255, 0.01), rgba(255, 255, 255, 0.01))",
        "slot-hotbar-empty":
          "linear-gradient(rgba(255, 255, 255, 0.01), rgba(255, 255, 255, 0.01))",
      },
    },
  },
  plugins: [
    function ({ addUtilities }) {
      const newUtilities = {
        ".border": {
          borderWidth: "0.063rem",
          borderStyle: "solid",
        },
      };

      addUtilities(newUtilities, {
        variants: ["responsive"],
      });
    },
  ],
};
