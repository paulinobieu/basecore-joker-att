import { useEffect, useState } from "react";

/**
 * Mantém um elemento montado durante a animação de saída.
 *
 * `shouldRender` só volta a false depois de `duration`, e `isVisible` só vira
 * true no frame seguinte à montagem — sem isso o navegador pinta direto no
 * estado final e a transição de entrada não acontece. `duration` precisa
 * espelhar a duração declarada no CSS do elemento.
 */
export const useMountTransition = (show: boolean, duration: number) => {
  const [shouldRender, setShouldRender] = useState(show);
  const [isVisible, setIsVisible] = useState(show);

  useEffect(() => {
    let animationFrame: number | undefined;
    let unmountTimer: number | undefined;

    if (show) {
      setShouldRender(true);
      // dois frames: o primeiro garante que o estado inicial foi pintado.
      animationFrame = requestAnimationFrame(() => {
        animationFrame = requestAnimationFrame(() => setIsVisible(true));
      });
    } else {
      setIsVisible(false);
      unmountTimer = window.setTimeout(() => setShouldRender(false), duration);
    }

    return () => {
      if (animationFrame !== undefined) cancelAnimationFrame(animationFrame);
      if (unmountTimer !== undefined) window.clearTimeout(unmountTimer);
    };
  }, [show, duration]);

  return { shouldRender, isVisible };
};
