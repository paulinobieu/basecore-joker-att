interface LonzegeProps {
    pressKey: string;
    color: string;
}

export function Lonzege({ color, pressKey }: LonzegeProps) {
    return (
        <div className="relative flex size-[1.75rem] items-center justify-center">
            <h1 className="absolute z-10 font-medium text-[.5625rem]">
                {pressKey}
            </h1>
            <svg
                width="1.75rem"
                height="1.75rem"
                viewBox="0 0 28 28"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path
                    d="M9.75736 4.24264C12.1005 1.89949 15.8995 1.89949 18.2426 4.24264L23.7574 9.75736C26.1005 12.1005 26.1005 15.8995 23.7574 18.2426L18.2426 23.7574C15.8995 26.1005 12.1005 26.1005 9.75736 23.7574L4.24264 18.2426C1.89949 15.8995 1.89949 12.1005 4.24264 9.75736L9.75736 4.24264Z"
                    fill="#151515"
                    fill-opacity="0.7"
                />
                <path
                    d="M9.75736 4.24264C12.1005 1.89949 15.8995 1.89949 18.2426 4.24264L23.7574 9.75736C26.1005 12.1005 26.1005 15.8995 23.7574 18.2426L18.2426 23.7574C15.8995 26.1005 12.1005 26.1005 9.75736 23.7574L4.24264 18.2426C1.89949 15.8995 1.89949 12.1005 4.24264 9.75736L9.75736 4.24264Z"
                    fill="url(#paint0_linear_168_110)"
                    fill-opacity="0.2"
                />
                <path
                    d="M12.7273 5.75568C13.4303 5.05279 14.5703 5.05275 15.2732 5.75568L22.2439 12.7274C22.9469 13.4303 22.9469 14.5703 22.2439 15.2733L15.2732 22.244C14.5703 22.9469 13.4303 22.9469 12.7273 22.244L5.75566 15.2733C5.05273 14.5703 5.05277 13.4303 5.75566 12.7274L12.7273 5.75568Z"
                    fill="url(#paint1_linear_168_110)"
                    stroke={color}
                    stroke-width="0.4"
                />
                <path
                    d="M11.3842 5.14099C12.8291 3.69606 15.1717 3.69605 16.6166 5.14099L22.8598 11.3842C24.3043 12.8291 24.3046 15.1718 22.8598 16.6166L16.6166 22.8597C15.1718 24.3045 12.8292 24.3043 11.3842 22.8597L5.14102 16.6166C3.69609 15.1716 3.69609 12.8291 5.14102 11.3842L11.3842 5.14099Z"
                    stroke="url(#paint2_linear_168_110)"
                    stroke-opacity="0.7"
                    stroke-width="0.6"
                />

                <defs>
                    <linearGradient
                        id="paint0_linear_168_110"
                        x1="-1.4"
                        y1="1.05"
                        x2="14"
                        y2="28"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop stop-color={color} stop-opacity="0.7" />
                        <stop offset="1" stop-color={color} stop-opacity="0" />
                    </linearGradient>
                    <linearGradient
                        id="paint1_linear_168_110"
                        x1="6.21764"
                        y1="4.20001"
                        x2="17.85"
                        y2="25.55"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop offset="0.238476" stop-color={color} />
                        <stop
                            offset="0.845384"
                            stop-color={color}
                            stop-opacity="0.2"
                        />
                    </linearGradient>
                    <linearGradient
                        id="paint2_linear_168_110"
                        x1="14"
                        y1="2.09998"
                        x2="14"
                        y2="25.9"
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
        </div>
    );
}
