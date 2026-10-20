export function Hexagon({ time }: { time: number }) {
    return (
        <svg
            width="3.75rem"
            height="3.75rem"
            viewBox="0 0 60 60"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
        >
            <path
                d="M25.7574 4.24264C28.1005 1.8995 31.8995 1.8995 34.2426 4.24264L55.7574 25.7574C58.1005 28.1005 58.1005 31.8995 55.7574 34.2426L34.2426 55.7574C31.8995 58.1005 28.1005 58.1005 25.7574 55.7574L4.24264 34.2426C1.8995 31.8995 1.8995 28.1005 4.24264 25.7574L25.7574 4.24264Z"
                fill="#151515"
                fill-opacity="0.7"
            />
            <path
                d="M25.7574 4.24264C28.1005 1.8995 31.8995 1.8995 34.2426 4.24264L55.7574 25.7574C58.1005 28.1005 58.1005 31.8995 55.7574 34.2426L34.2426 55.7574C31.8995 58.1005 28.1005 58.1005 25.7574 55.7574L4.24264 34.2426C1.8995 31.8995 1.8995 28.1005 4.24264 25.7574L25.7574 4.24264Z"
                fill="url(#paint0_linear_729_1465)"
                fill-opacity="0.2"
            />
            <mask
                id="mask0_729_1465"
                style={{ maskType: "alpha" }}
                maskUnits="userSpaceOnUse"
                x="9"
                y="9"
                width="42"
                height="42"
            >
                <path
                    d="M28.5858 10.4142C29.3668 9.63316 30.6332 9.63317 31.4142 10.4142L49.5858 28.5858C50.3668 29.3668 50.3668 30.6332 49.5858 31.4142L31.4142 49.5858C30.6332 50.3668 29.3668 50.3668 28.5858 49.5858L10.4142 31.4142C9.63316 30.6332 9.63317 29.3668 10.4142 28.5858L28.5858 10.4142Z"
                    fill="rgb(var(--primaryColor))"
                />
            </mask>
            <g mask="url(#mask0_729_1465)">
                <rect
                    x="10"
                    y="9"
                    width="41"
                    height="42"
                    key={time}
                    style={{
                        animation: `fillProgress ${time}ms linear forwards`,
                    }}
                    className="transition-all duration-300"
                    fill="rgb(var(--primaryColor))"
                />
            </g>
            <path
                d="M27.667 6.32324C28.9556 5.03492 31.0444 5.03492 32.333 6.32324L53.6768 27.667C54.9651 28.9556 54.9651 31.0444 53.6768 32.333L32.333 53.6768C31.0444 54.9651 28.9556 54.9651 27.667 53.6768L6.32324 32.333C5.03492 31.0444 5.03492 28.9556 6.32324 27.667L27.667 6.32324Z"
                stroke="rgb(var(--primaryColor))"
                stroke-width="1.4"
            />
            <defs>
                <linearGradient
                    id="paint0_linear_729_1465"
                    x1="-3"
                    y1="2.25"
                    x2="30"
                    y2="60"
                    gradientUnits="userSpaceOnUse"
                >
                    <stop
                        stop-color="rgb(var(--primaryColor))"
                        stop-opacity="0.7"
                    />
                    <stop
                        offset="1"
                        stop-color="rgb(var(--primaryColor))"
                        stop-opacity="0"
                    />
                </linearGradient>
            </defs>
        </svg>
    );
}
