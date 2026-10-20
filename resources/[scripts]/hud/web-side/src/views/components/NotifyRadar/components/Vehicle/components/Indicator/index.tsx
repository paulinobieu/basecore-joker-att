export function Indicator({ direction }: { direction: "D" | "T" }) {
    return (
        <svg
            width="1rem"
            height="4.375rem"
            viewBox="0 0 16 70"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="-left-[.0625rem] absolute"
        >
            <path
                d="M13.6977 6.42081L0 0V70L13.961 62.1469C15.2206 61.4384 16 60.1057 16 58.6606V10.0426C16 8.49102 15.1027 7.07938 13.6977 6.42081Z"
                fill="rgb(var(--primaryColor))"
            />
            <text
                transform="matrix(0 -1 1 0 5 58)"
                fill="white"
                xmlSpace="preserve"
                font-family="Outfit"
                font-size=".5rem"
                font-weight="900"
                letter-spacing="0em"
            >
                <tspan x={direction === "D" ? "-3" : "0"} y="5.696">
                    {direction === "D" ? "DIANTEIRO" : "TRASEIRO"}
                </tspan>
            </text>
        </svg>
    );
}
