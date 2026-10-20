import { useImageValidation } from "@app/hooks/useImageValidation";
import { cn } from "@app/utils";
import FallbackItem from "@views/assets/images/fallback-weapon.webp";
import type { ItemProps } from "../..";

export function Bind({ amount, image, name, slot_id }: ItemProps) {
    const { imageUrl, isImageValid } = useImageValidation(image);

    return (
        <div
            className={cn(
                "relative flex size-[4rem] items-center justify-center rounded-lg border border-white/30 border-solid p-0.5",
                { "border-primaryColor": isImageValid },
            )}
        >
            <div
                className="relative flex size-full items-center justify-center rounded-md border border-white/[.04] border-solid p-[.1875rem] bg-blend-screen"
                style={{
                    background: `linear-gradient(0deg, rgba(21, 21, 21, 0.7), rgba(21, 21, 21, 0.7)),linear-gradient(209.6deg, rgba(1, 67, 187, 0) 23.13%, rgba(1, 67, 187, ${isImageValid ? 0.3 : 0.0}) 97.51%)`,
                }}
            >
                {isImageValid && (
                    <img
                        src={isImageValid ? imageUrl : FallbackItem}
                        alt={name}
                        className="absolute size-10 object-contain"
                    />
                )}
                <span
                    className={cn(
                        "absolute right-[.1875rem] bottom-[.1875rem] flex h-4 items-center justify-center rounded-sm bg-white/10 px-[.3125rem] text-xs",
                        { "bg-primaryColor": isImageValid },
                    )}
                >
                    {slot_id}
                </span>
            </div>
        </div>
    );
}
