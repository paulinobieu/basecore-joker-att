import styled, { createGlobalStyle, keyframes } from "styled-components";

export const theme = {
  colors: {
    dark: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
    shape: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
    primary: (opacity = 1) => `rgba(3, 187, 232, ${opacity})`,
    error: (opacity = 1) => `rgba(255, 51, 0, ${opacity})`,
  },
  fonts: {
    family: { primary: "'Poppins', sans-serif" },
  },
};

export const GlobalStyle = createGlobalStyle`
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    user-select: none;
    font-synthesis: none;
    text-rendering: optimizeLegibility;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    -webkit-text-size-adjust: 100%;
  }

  html {
    width: 100%;
  }

  body {
    width: 100%;
    height: 100vh;
    margin: 0;
    padding: 0;
    position: relative;
  }

  body, h1, h2, h3, h4, h5, h6, input, button, textarea {
    font-family: ${theme.fonts.family.primary};
  }

  ::-webkit-scrollbar {
    width: 2px;
  }

  ::-webkit-scrollbar-track {
    background: ${theme.colors.dark()};
  }

  ::-webkit-scrollbar-thumb {
    background: ${theme.colors.primary()};
  }

  ::-webkit-scrollbar-thumb:hover {
    background: ${theme.colors.primary()};
  }
`;

export const Container = styled.div`
  display: flex;
  justify-content: flex-start;
  align-items: flex-end;
  width: 100vw;
  height: 100vh;
`;

const pulseAnimation = keyframes`
  0% {
    opacity: 0.7;
    transform: scale(0.95);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
`;

export const MessageCard = styled.div`
  color: white;
  width: 250px;
  font-family: 'Poppins', sans-serif;
  font-weight: 900;
  text-align: center;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  letter-spacing: 1px;
  animation: ${pulseAnimation} alternate infinite 0.5s;
  text-transform: uppercase;
  text-shadow: 2px 2px 10px #000;
  font-size: 0.8rem;
  margin: 0 0 20vw 12vh;

  & > b {
    font-family: 'Poppins', sans-serif;
    font-weight: 900;
    font-size: 1rem;
  }
`;
