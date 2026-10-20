import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { EmptyStopwatchIcon } from "@views/assets/icons/EmptyStopwatch";
import { useEffect, useRef, useState } from "react";
import { Hexagon } from "./components/Hexagon";

interface IProgress {
    time: number;
    text: string;
}

export function Progressbar() {
    const [progress, setProgress] = useState<IProgress | null>(null);
    const [lastProgress, setLastProgress] = useState<IProgress | null>(null);
    const [percentage, setPercentage] = useState(0);

    const startTimeRef = useRef<number | null>(null);
    const animationFrameRef = useRef<number | null>(null);

    useNuiMessage("set:progress", (data?: IProgress) => {
        if (!data) return setProgress(null);
        setProgress(data);
    });

    useEffect(() => {
        if (!progress) return;
        setLastProgress(progress);
    }, [progress]);

    useEffect(() => {
        if (!progress) {
            setPercentage(0);
            if (animationFrameRef.current) {
                cancelAnimationFrame(animationFrameRef.current);
            }
            return;
        }

        setPercentage(0);
        startTimeRef.current = performance.now();

        const tick = (now: number) => {
            const elapsed = now - (startTimeRef.current ?? now);
            const pct = Math.min(
                100,
                Math.round((elapsed / progress.time) * 100),
            );
            setPercentage(pct);

            if (pct < 100) {
                animationFrameRef.current = requestAnimationFrame(tick);
            }
        };

        animationFrameRef.current = requestAnimationFrame(tick);

        const timeoutId = setTimeout(() => {
            setProgress(null);
        }, progress.time);

        return () => {
            clearTimeout(timeoutId);
            if (animationFrameRef.current) {
                cancelAnimationFrame(animationFrameRef.current);
            }
        };
    }, [progress]);

    return (
        <div
            className={cn(
                "-translate-x-1/2 absolute bottom-[13.8125rem] left-1/2 flex w-fit translate-y-full scale-[.85] flex-col items-center opacity-0 transition-all duration-300",
                { "translate-y-0 scale-[1] opacity-100": progress },
            )}
        >
            <div className="flex size-[3.75rem] items-center justify-center">
                <EmptyStopwatchIcon />
                <Hexagon time={progress?.time || 0} />
            </div>
            <span className="mt-3 mb-2.5 text-sm text-white/80">
                {progress?.text || lastProgress?.text}
            </span>
            <h1 className="font-bold text-sm text-white/80">{percentage}%</h1>
        </div>
    );
}

debugData([
    {
        action: "set:progress",
        payload: {
            time: 5000,
            text: "Utilizando item",
        },
    },
]);
