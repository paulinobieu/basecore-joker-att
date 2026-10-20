interface GaugeProps {
  value: number;
  max: number;
  caption: string;
  label: string;
}

/**
 * Anel de ocupacao. O preenchimento usa as cores do tema e a "rosca" e feita
 * com mascara radial, entao o fundo do painel continua aparecendo por dentro.
 */
export function Gauge({ value, max, caption, label }: GaugeProps) {
  const percent = max > 0 ? Math.max(0, Math.min(1, value / max)) : 0;
  const degrees = percent * 360;
  const hole =
    "radial-gradient(farthest-side, rgba(0, 0, 0, 0) calc(100% - .4375rem), rgba(0, 0, 0, 1) calc(100% - .4375rem))";

  return (
    <div className="flex flex-shrink-0 flex-col items-center gap-[.5rem]">
      <div className="relative flex size-[6.25rem] items-center justify-center">
        <div
          className="gauge-card absolute inset-0 rounded-full"
          style={{
            background: `conic-gradient(rgba(var(--secondaryColor), .95) 0deg, rgba(var(--primaryColor), .95) ${degrees}deg, rgba(255, 255, 255, .07) ${degrees}deg 360deg)`,
            WebkitMask: hole,
            mask: hole,
          }}
        />

        <div className="relative z-10 flex flex-col items-center">
          <span className="font-black text-[1.5rem] text-white leading-none">
            {value.toLocaleString()}
          </span>
          <span className="mt-1 font-semibold text-[.5625rem] text-white/35">
            {caption}
          </span>
        </div>
      </div>

      <div className="flex items-center gap-1.5">
        <span className="font-black text-[.6875rem] text-white/45 uppercase">
          {label}
        </span>
        <span className="font-black text-[.6875rem] text-primaryColor">
          {Math.round(percent * 100)}%
        </span>
      </div>
    </div>
  );
}
