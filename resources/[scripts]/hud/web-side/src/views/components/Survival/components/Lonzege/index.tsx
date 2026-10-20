import { useId } from "react";

interface LozengeProps {
    color: string;
    percentage: number;
}

export function Lonzege({ percentage, color }: LozengeProps) {
    const uniqueId = useId();

    const innerTop = 9;
    const innerBottom = 41;
    const innerHeight = innerBottom - innerTop;
    const fillHeight = (percentage / 100) * innerHeight;
    const maskRectY = innerBottom - fillHeight;

    return (
        <svg
            width="3.125rem"
            height="3.125rem"
            viewBox="0 0 50 50"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="absolute z-[-1]"
        >
            <defs>
                <mask id={`maskPercentage-${uniqueId}`}>
                    <rect
                        x="0"
                        y={maskRectY}
                        width="50"
                        height={fillHeight + (innerBottom - maskRectY)}
                        fill="white"
                        className="transition-all duration-300"
                    />
                </mask>

                <linearGradient
                    id={`paint0_linear_738_1474-${uniqueId}`}
                    x1="-2.5"
                    y1="1.875"
                    x2="25"
                    y2="50"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop stopColor={color} stopOpacity="0.7" />
                    <stop offset="1" stopColor={color} stopOpacity="0" />
                </linearGradient>
                <linearGradient
                    id={`paint1_linear_738_1474-${uniqueId}`}
                    x1="25"
                    y1="10"
                    x2="25"
                    y2="43"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop offset="0.238476" stopColor={color} />
                    <stop
                        offset="0.776699"
                        stopColor={color}
                        stopOpacity="0.4"
                    />
                </linearGradient>
                <linearGradient
                    id={`paint2_linear_738_1474-${uniqueId}`}
                    x1="25"
                    y1="3.75"
                    x2="25"
                    y2="46.25"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop
                        offset="0.0721073"
                        stopColor={color}
                        stopOpacity="0"
                    />
                    <stop offset="0.5" stopColor={color} />
                    <stop offset="0.937911" stopColor={color} stopOpacity="0" />
                </linearGradient>
            </defs>

            <path
                d="M20.7574 4.24264C23.1005 1.8995 26.8995 1.89949 29.2426 4.24264L45.7574 20.7574C48.1005 23.1005 48.1005 26.8995 45.7574 29.2426L29.2426 45.7574C26.8995 48.1005 23.1005 48.1005 20.7574 45.7574L4.24264 29.2426C1.8995 26.8995 1.89949 23.1005 4.24264 20.7574L20.7574 4.24264Z"
                fill="#151515"
                fillOpacity="0.7"
            />

            <path
                d="M20.7574 4.24264C23.1005 1.8995 26.8995 1.89949 29.2426 4.24264L45.7574 20.7574C48.1005 23.1005 48.1005 26.8995 45.7574 29.2426L29.2426 45.7574C26.8995 48.1005 23.1005 48.1005 20.7574 45.7574L4.24264 29.2426C1.8995 26.8995 1.89949 23.1005 4.24264 20.7574L20.7574 4.24264Z"
                fill={`url(#paint0_linear_738_1474-${uniqueId})`}
                fillOpacity="0.2"
            />

            <path
                d="M23.7275 9.05566C24.4304 8.35292 25.5696 8.35292 26.2725 9.05566L40.9443 23.7275C41.6471 24.4304 41.6471 25.5696 40.9443 26.2725L26.2725 40.9443C25.5696 41.6471 24.4304 41.6471 23.7275 40.9443L9.05566 26.2725C8.35292 25.5696 8.35292 24.4304 9.05566 23.7275L23.7275 9.05566Z"
                fill={`url(#paint1_linear_738_1474-${uniqueId})`}
                stroke={color}
                strokeWidth="0.4"
                mask={`url(#maskPercentage-${uniqueId})`}
            />

            <path
                d="M22.4541 6.86133C23.86 5.45544 26.14 5.45544 27.5459 6.86133L43.1387 22.4541C44.5446 23.86 44.5446 26.14 43.1387 27.5459L27.5459 43.1387C26.14 44.5446 23.86 44.5446 22.4541 43.1387L6.86133 27.5459C5.45544 26.14 5.45544 23.86 6.86133 22.4541L22.4541 6.86133Z"
                stroke={`url(#paint2_linear_738_1474-${uniqueId})`}
                strokeOpacity="0.7"
                strokeWidth="0.8"
            />
        </svg>
    );
}
