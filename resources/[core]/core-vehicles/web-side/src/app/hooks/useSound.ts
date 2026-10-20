import { useEffect, useRef, useState } from "react";

export const useSound = (src: string, opts: { volume?: number } = {}) => {
  const { volume = 1 } = opts;
  const audioRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    audioRef.current = new Audio(src);
    audioRef.current.volume = volume;
    return () => {
      audioRef.current?.pause();
      audioRef.current = null;
    };
  }, [src, volume]);

  const play = () => {
    if (audioRef.current) {
      audioRef.current.currentTime = 0;
      audioRef.current.play().catch(() => {});
    }
  };

  return { play };
};
