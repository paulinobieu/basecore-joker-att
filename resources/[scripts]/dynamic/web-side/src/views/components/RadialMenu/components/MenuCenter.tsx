import type React from "react";
import { INNER_RADIUS } from "./MenuSector";


interface Props {
    isNested: boolean;
    title?: string;
    onClick: () => void;
}

export const MenuCenter: React.FC<Props> = ({ isNested, title, onClick }) => {
    return (
        // biome-ignore lint/a11y/useKeyWithClickEvents: <explanation>
        <g className="center" onClick={onClick} style={{ cursor: "pointer" }}>
            <circle cx={0} cy={0} r={INNER_RADIUS - 5} />
            {title ? (
                <>
                    <text
                        textAnchor="middle"
                        x={0}
                        y={0}
                        fontSize="2.5rem"
                        fontFamily="Outfit"
                        style={{ fontWeight: 500 }}
                        fill="white"
                        className="centerTitle"
                    >
                        {title}
                    </text>

                </>
            ) : (
                <text
                    textAnchor="middle"
                    x={0}
                    y={30}
                    fontSize="5rem"
                    fill="white"
                    className="centerAction"
                >
                    {isNested ? "↩" : "✕"}
                </text>
            )}
        </g>
    );
};
