export function Speed({ speed }: { speed: number }) {
    return (
        <div className="font-extrabold text-[2.625rem] leading-none">
            {speed <= 9 ? (
                <>
                    <span className=" text-white/60">00</span>
                    <span>{speed}</span>
                </>
            ) : speed >= 10 && speed <= 99 ? (
                <>
                    <span className=" text-white/60">0</span>
                    <span>{speed}</span>
                </>
            ) : (
                speed
            )}
        </div>
    );
}
