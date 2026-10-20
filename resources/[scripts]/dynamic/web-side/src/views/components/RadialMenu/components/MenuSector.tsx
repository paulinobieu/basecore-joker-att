import type { MenuItem } from "@views/@types/menu";
import type React from "react";

const RADIUS = 450;
// Larger inner radius => thinner ring (matches Figma reference)
export const INNER_RADIUS = RADIUS * 0.5;

function degToRad(deg: number) {
    return deg * (Math.PI / 180);
}

function getDegreePos(angleDeg: number, length: number) {
    return {
        x: Math.sin(degToRad(angleDeg)) * length,
        y: Math.cos(degToRad(angleDeg)) * length,
    };
}

function pointToString(p: { x: number; y: number }) {
    return `${p.x.toFixed(4)} ${p.y.toFixed(4)}`;
}

function createSectorPath(startDeg: number, endDeg: number): string {
    const init = getDegreePos(startDeg, RADIUS);
    let d = `M${pointToString(init)}`;
    d += `A${RADIUS} ${RADIUS} 0 0 0 ${pointToString(getDegreePos(endDeg, RADIUS))}`;
    d += `L${pointToString(getDegreePos(endDeg, INNER_RADIUS))}`;
    d += `A${INNER_RADIUS} ${INNER_RADIUS} 0 0 1 ${pointToString(getDegreePos(startDeg, INNER_RADIUS))}`;
    d += "Z";
    return d;
}

function getSectorCenter(startDeg: number, endDeg: number) {
    const mid = (startDeg + endDeg) / 2;
    const r = INNER_RADIUS + (RADIUS - INNER_RADIUS) / 2;
    return getDegreePos(mid, r);
}

interface Props {
    startAngle: number;
    endAngle: number;
    item: MenuItem | null;
    index: number;
    selected: boolean;
    hovered: boolean;
    isNight: boolean;
    onMouseDown: (index: number) => void;
    onClick: () => void;
    onMouseEnter: () => void;
    onMouseLeave: () => void;
}

export const MenuSector: React.FC<Props> = ({
    startAngle,
    endAngle,
    item,
    index,
    selected,
    hovered,
    isNight,
    onMouseDown,
    onClick,
    onMouseEnter,
    onMouseLeave,
}) => {
    const center = getSectorCenter(startAngle, endAngle);
    const pathD = createSectorPath(startAngle, endAngle);
    const fill = isNight ? "rgba(150,150,150,0.1)" : "rgba(25,25,25,0.5)";

    // Reduce CEF subpixel jitter (FiveM) when compositor state changes on hover
    const iconX = Number((center.x - 50).toFixed(3));
    const iconY = Number((center.y - 50).toFixed(3));

    const hoverTint = "rgba(var(--primaryColor), 0.1)";

    function createOuterArcPath(startDeg: number, endDeg: number) {
        const init = getDegreePos(startDeg, RADIUS);
        let d = `M${pointToString(init)}`;
        d += `A${RADIUS} ${RADIUS} 0 0 0 ${pointToString(getDegreePos(endDeg, RADIUS))}`;
        return d;
    }

    const outerArcD = createOuterArcPath(startAngle, endAngle);

    if (!item) {
        return (
            <g className="dummy" fill={fill}>
                <path d={pathD} />
            </g>
        );
    }

    return (
        // biome-ignore lint/a11y/useKeyWithClickEvents: <explanation>
        <g
            className={`sector${selected ? " selected" : ""}${hovered ? " hovered" : ""}`}
            data-index={index}
            fill={fill}
            onMouseDown={() => onMouseDown(index)}
            onClick={onClick}
            onMouseEnter={onMouseEnter}
            onMouseLeave={onMouseLeave}
        >
            <path d={pathD} />
            <>
                <g
                    className="sectorHoverBg"
                    style={{
                        transition: "all 300ms ease",
                        opacity: hovered ? 1 : 0,
                    }}
                >
                    <path
                        className="sectorHoverTint"
                        d={pathD}
                        fill={hoverTint}
                    />
                    <path
                        className="sectorHoverGradient"
                        d={pathD}
                        fill="url(#radial-sector-hover-gradient)"
                    />
                </g>
                <path
                    className="sectorTopStroke"
                    d={outerArcD}
                    style={{
                        opacity: hovered ? 1 : 0,
                    }}
                />
            </>

            {item.icon && (
                <foreignObject
                    x={iconX}
                    y={iconY}
                    width={100}
                    height={100}
                    style={{ overflow: "visible" }}
                >
                    <div
                        {...({
                            xmlns: "http://www.w3.org/1999/xhtml",
                        } as unknown as Record<string, string>)}
                        style={{
                            width: "100%",
                            height: "100%",
                            display: "grid",
                            placeItems: "center",
                            pointerEvents: "none",
                            overflow: "visible",
                            transform: "translateZ(0)",
                            WebkitFontSmoothing: "antialiased",
                            backfaceVisibility: "hidden",
                        }}
                    >
                        <i
                            className={item.icon}
                            style={{
                                fontSize: "4.5rem",
                                fontWeight: 400,

                                color: hovered ? "#fff" : "#FFFFFF4D",
                                opacity: 1,
                                transition: "color 150ms ease",
                                transform: "translateZ(0)",
                                WebkitFontSmoothing: "antialiased",
                            }}
                        />
                    </div>
                </foreignObject>
            )}
        </g>
    );
};
