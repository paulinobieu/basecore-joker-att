import { useCallback, useEffect, useRef } from "react";

export function useSound(src: string, volume = 0.075) {
	const audioRef = useRef<HTMLAudioElement | null>(null);

	useEffect(() => {
		audioRef.current = new Audio(src);
		audioRef.current.volume = volume;

		return () => {
			audioRef.current?.pause();
			audioRef.current = null;
		};
	}, [src, volume]);

	const play = useCallback(() => {
		if (!audioRef.current) return;
		audioRef.current.currentTime = 0;
		void audioRef.current.play();
	}, []);

	return { play };
}
