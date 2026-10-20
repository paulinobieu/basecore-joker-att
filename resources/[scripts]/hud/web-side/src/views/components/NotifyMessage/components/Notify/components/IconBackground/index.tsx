export function IconBackground({ color, timeout }: { color: string; timeout: number }) {
    return (
        <svg
            width="2.875rem"
            height="2.875rem"
            viewBox="0 0 46 46"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
        >
            <path
                d="M18.7574 4.24264C21.1005 1.8995 24.8995 1.89949 27.2426 4.24264L41.7574 18.7574C44.1005 21.1005 44.1005 24.8995 41.7574 27.2426L27.2426 41.7574C24.8995 44.1005 21.1005 44.1005 18.7574 41.7574L4.24264 27.2426C1.8995 24.8995 1.89949 21.1005 4.24264 18.7574L18.7574 4.24264Z"
                fill={`url(#paint0_linear_729_1473-${color})`}
                fillOpacity="0.3"
            />
            <path
                d="M21.7275 8.45557C22.4305 7.75262 23.5705 7.75262 24.2734 8.45557L37.5449 21.7271C38.2478 22.43 38.2478 23.57 37.5449 24.2729L24.2734 37.5444C23.5705 38.2474 22.4305 38.2473 21.7275 37.5444L8.45605 24.2729C7.75311 23.57 7.75311 22.43 8.45605 21.7271L21.7275 8.45557Z"
                fill={`url(#paint1_linear_729_1473-${color})`}
                stroke={color}
                strokeWidth="0.4"
            />
            <path
                d="M20.5254 6.63184C21.8921 5.26534 24.1078 5.26547 25.4746 6.63184L39.3682 20.5254C40.7349 21.8922 40.7348 24.1078 39.3682 25.4746L25.4746 39.3682C24.1078 40.7348 21.8922 40.7349 20.5254 39.3682L6.63184 25.4746C5.26547 24.1078 5.26534 21.8921 6.63184 20.5254L20.5254 6.63184Z"
                stroke={`url(#paint2_linear_729_1473-${color})`}
                strokeOpacity="0.7"
            />
            <path
                d="M20.5254 6.63184C21.8921 5.26534 24.1078 5.26547 25.4746 6.63184L39.3682 20.5254C40.7349 21.8922 40.7348 24.1078 39.3682 25.4746L25.4746 39.3682C24.1078 40.7348 21.8922 40.7349 20.5254 39.3682L6.63184 25.4746C5.26547 24.1078 5.26534 21.8921 6.63184 20.5254L20.5254 6.63184Z"
                fill="none"
                stroke={color}
                strokeWidth="2"
                strokeLinecap="round"
                strokeDasharray="120"
                style={{
                    strokeDashoffset: 120,
                    animation: `timerStroke ${timeout}ms linear forwards`,
                }}
            />
            <defs>
                <linearGradient
                    id={`paint0_linear_729_1473-${color}`}
                    x1="-2.3"
                    y1="1.725"
                    x2="30.5"
                    y2="52.5"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop offset="0.208399" stopColor={color} stopOpacity="0.7" />
                    <stop offset="0.919052" stopColor={color} stopOpacity="0" />
                </linearGradient>
                <linearGradient
                    id={`paint1_linear_729_1473-${color}`}
                    x1="10.2151"
                    y1="6.8999"
                    x2="29.3254"
                    y2="41.9749"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop offset="0.238476" stopColor={color} />
                    <stop offset="0.845384" stopColor={color} stopOpacity="0.2" />
                </linearGradient>
                <linearGradient
                    id={`paint2_linear_729_1473-${color}`}
                    x1="23.0002"
                    y1="3.4502"
                    x2="23.0002"
                    y2="42.5502"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop offset="0.0721073" stopColor={color} stopOpacity="0" />
                    <stop offset="0.5" stopColor={color} />
                    <stop offset="0.937911" stopColor={color} stopOpacity="0" />
                </linearGradient>
            </defs>
        </svg>
    );
}
