import React, { useState, useEffect, useCallback } from "react";
import { GlobalStyle, Container, MessageCard } from "./styles";

export function App() {
  const [blockExpires, setBlockExpires] = useState(0);
  const [prisonExpires, setPrisonExpires] = useState(0);

  const handleMessage = useCallback((event) => {
    if (event.data) {
      if (event.data.blockExpires !== undefined) setBlockExpires(event.data.blockExpires);
      if (event.data.prisonExpires !== undefined) setPrisonExpires(event.data.prisonExpires);
    }
  }, []);

  useEffect(() => {
    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, [handleMessage]);

  return (
    <>
      <GlobalStyle />
      <Container>
        {blockExpires !== 0 && (
          <MessageCard>
            Você está amarrado por conduta inapropriada até:
            <b>{blockExpires}</b>
          </MessageCard>
        )}
        {prisonExpires !== 0 && (
          <MessageCard>
            Você está ilhado por conduta inapropriada até:
            <b>{prisonExpires}</b>
          </MessageCard>
        )}
      </Container>
    </>
  );
}
