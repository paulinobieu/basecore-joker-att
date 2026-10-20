interface RoundedProps {
    color: string;
    percentage: number;
}

export function Rounded({ percentage, color }: RoundedProps) {
    return (
        <>
            <svg
                width="2.25rem"
                height="2.25rem"
                viewBox="0 0 36 36"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                className="absolute z-10"
            >
                <g clip-path="url(#clip0_754_1465)">
                    <path
                        d="M35.9971 17.6891C35.9314 13.8885 34.6642 10.2062 32.3771 7.16992L27.7764 10.6356C29.3316 12.7002 30.1933 15.2042 30.238 17.7886L35.9971 17.6891Z"
                        fill={color}
                        fillOpacity={percentage >= 3 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M31.9865 29.3301C34.3792 26.3764 35.7754 22.7411 35.975 18.9451L30.2229 18.6426C30.0872 21.2239 29.1378 23.6959 27.5107 25.7044L31.9865 29.3301Z"
                        fill={color}
                        fillOpacity={percentage >= 4 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M21.4311 35.6698C25.1626 34.9451 28.5689 33.0578 31.1618 30.2782L26.9499 26.3491C25.1867 28.2392 22.8704 29.5227 20.333 30.0154L21.4311 35.6698Z"
                        fill={color}
                        fillOpacity={percentage >= 5 ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M9.27051 33.7414C12.5948 35.5849 16.4174 36.3286 20.1903 35.866L19.4894 30.1488C16.9237 30.4634 14.3244 29.9577 12.0639 28.7041L9.27051 33.7414Z"
                        fill={color}
                        fillOpacity={percentage >= 6 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M1.19434 24.4476C2.55595 27.9966 5.00616 31.0234 8.19377 33.0943L11.3317 28.2641C9.16416 26.8559 7.49802 24.7976 6.57212 22.3843L1.19434 24.4476Z"
                        fill={color}
                        fillOpacity={percentage >= 7 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M0.98169 12.1367C-0.256495 15.7306 -0.32514 19.6243 0.785595 23.2596L6.2942 21.5765C5.5389 19.1045 5.58558 16.4568 6.42755 14.0129L0.98169 12.1367Z"
                        fill={color}
                        fillOpacity={percentage >= 8 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M8.73249 2.56934C5.47386 4.52655 2.91849 7.46512 1.43262 10.9639L6.73434 13.2155C7.74473 10.8363 9.48238 8.83804 11.6983 7.50714L8.73249 2.56934Z"
                        fill={color}
                        fillOpacity={percentage >= 9 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M20.819 0.222121C17.0647 -0.373178 13.2183 0.235346 9.83105 1.96048L12.4452 7.09313C14.7485 5.92004 17.364 5.50625 19.917 5.91105L20.819 0.222121Z"
                        fill={color}
                        fillOpacity={percentage >= 1 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                    <path
                        d="M31.5872 6.19318C29.0939 3.32391 25.7562 1.31764 22.0526 0.461914L20.7559 6.07406C23.2744 6.65596 25.544 8.02022 27.2394 9.97132L31.5872 6.19318Z"
                        fill={color}
                        fillOpacity={percentage >= 2 * (100 / 9) ? 1 : 0.3}
                        className="transition-all duration-300"
                    />
                </g>
                <defs>
                    <clipPath id="clip0_754_1465">
                        <rect width="36" height="36" fill="white" />
                    </clipPath>
                </defs>
            </svg>

            <svg
                width="2.5rem"
                height="2.5rem"
                viewBox="0 0 40 40"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
                className="absolute z-[-1]"
            >
                <circle
                    cx="20"
                    cy="20"
                    r="20"
                    fill="#151515"
                    fill-opacity="0.7"
                />
                <circle
                    cx="20"
                    cy="20"
                    r="20"
                    fill={`url(#paint0_linear_94_2258-${color})`}
                    fill-opacity="0.2"
                />
                <circle
                    cx="20"
                    cy="20"
                    r="19.6"
                    stroke={`url(#paint1_linear_94_2258-${color})`}
                    stroke-opacity="0.7"
                    stroke-width="0.8"
                />

                <defs>
                    <linearGradient
                        id={`paint0_linear_94_2258-${color}`}
                        x1="-2"
                        y1="1.5"
                        x2="20"
                        y2="40"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop stop-color={color} stop-opacity="0.7" />
                        <stop offset="1" stop-color={color} stop-opacity="0" />
                    </linearGradient>
                    <linearGradient
                        id={`paint1_linear_94_2258-${color}`}
                        x1="20"
                        y1="0"
                        x2="20"
                        y2="40"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop
                            offset="0.0721073"
                            stop-color={color}
                            stop-opacity="0"
                        />
                        <stop offset="0.5" stop-color={color} />
                        <stop
                            offset="0.937911"
                            stop-color={color}
                            stop-opacity="0"
                        />
                    </linearGradient>
                </defs>
            </svg>
        </>
    );
}
