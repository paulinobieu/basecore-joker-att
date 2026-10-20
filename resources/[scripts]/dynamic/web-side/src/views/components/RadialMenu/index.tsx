import type React from "react";
import { useEffect, useMemo, useState } from "react";
import { MenuSector } from "./components/MenuSector";
import "./styles/index.css";
import { useRadialMenu } from "@app/hooks/useRadialMenu";
import type { RadialMenuProps } from "@views/@types/menu";
import { MenuCenter } from "./components/MenuCenter";

function resolveLoopIndex(index: number, length: number): number | null {
    if (index < 0) index = length + index;
    if (index >= length) index = index - length;
    return index < length ? index : null;
}

export const RadialMenu: React.FC<RadialMenuProps> = ({
    menuItems,
    isNight = false,
    size = 450,
    onAction,
    onClose,
}) => {
    const {
        currentLevel,
        isNested,
        selectedIndex,
        handleSelect,
        handleClick,
        handleCenterClick,
    } = useRadialMenu(menuItems, onAction, onClose);

    const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);
    const [resolvedSize, setResolvedSize] = useState<number>(
        typeof size === "number" ? size : 450,
    );

    useEffect(() => {
        function toPx(v: number | string): number {
            if (typeof v === "number") return v;
            const raw = v.trim().toLowerCase();
            const n = Number.parseFloat(raw);
            if (!Number.isFinite(n)) return 450;

            if (raw.endsWith("rem")) {
                const root = Number.parseFloat(
                    getComputedStyle(document.documentElement).fontSize || "16",
                );
                return n * (Number.isFinite(root) ? root : 16);
            }

            // px or unitless string -> treat as px
            return n;
        }

        // Snap to even integer so translate(-50%) on the parent lands on a
        // whole pixel. Sub-pixel placement of a transform/transition layer
        // forces CEF's GPU compositor to apply bilinear filtering to the
        // whole rasterized texture — the visible "blur" affecting every
        // element (SVG paths, <text>, foreignObject icons) at once.
        const compute = () =>
            setResolvedSize(Math.round(toPx(size) / 2) * 2);
        compute();
        window.addEventListener("resize", compute);
        return () => window.removeEventListener("resize", compute);
    }, [size]);

    const sectorCount = Math.max(currentLevel.length, 2);
    const angleStep = 360 / sectorCount;
    const angleShift = angleStep / 2 + 270;

    const indexOffset = currentLevel.length <= 3 ? -2 : -1;

    const sectors = useMemo(() => {
        return Array.from({ length: sectorCount }, (_, i) => {
            const startAngle = angleShift + angleStep * i;
            const endAngle = angleShift + angleStep * (i + 1);
            const rawIndex = resolveLoopIndex(
                sectorCount - i + indexOffset,
                sectorCount,
            );
            const itemIndex =
                rawIndex !== null &&
                rawIndex >= 0 &&
                rawIndex < currentLevel.length
                    ? rawIndex
                    : null;
            const item = itemIndex !== null ? currentLevel[itemIndex] : null;

            return { startAngle, endAngle, item, itemIndex };
        });
    }, [sectorCount, angleShift, angleStep, indexOffset, currentLevel]);

    const hoveredItem =
        hoveredIndex !== null ? (currentLevel[hoveredIndex] ?? null) : null;

    const outlineOffsetUnits = (5 * 1000) / resolvedSize;

    return (
        <div
            className="menuHolder"
            style={{ width: resolvedSize, height: resolvedSize }}
        >
            <svg
                className="menu"
                viewBox="-500 -500 1000 1000"
                width={resolvedSize}
                height={resolvedSize}
            >
                <defs>
                    <radialGradient
                        id="radial-sector-hover-gradient"
                        gradientUnits="userSpaceOnUse"
                        cx="0"
                        cy="0"
                        r="450"
                    >
                        <stop
                            offset="0%"
                            stopColor="rgb(var(--primaryColor))"
                            stopOpacity="0.7"
                        />
                        <stop
                            offset="70.47%"
                            stopColor="rgb(var(--primaryColor))"
                            stopOpacity="0.7"
                        />
                        <stop
                            offset="95.31%"
                            stopColor="rgba(var(--primaryColor), 0)"
                            stopOpacity="1"
                        />
                        <stop
                            offset="100%"
                            stopColor="rgba(var(--primaryColor), 0)"
                            stopOpacity="1"
                        />
                    </radialGradient>
                </defs>

                <circle
                    className="radialOutline"
                    cx={0}
                    cy={0}
                    r={450 + outlineOffsetUnits}
                />
                {sectors.map(({ startAngle, endAngle, item, itemIndex }, i) => (
                    <MenuSector
                        // biome-ignore lint/suspicious/noArrayIndexKey: <explanation>
                        key={i}
                        startAngle={startAngle}
                        endAngle={endAngle}
                        item={item}
                        index={itemIndex ?? -1}
                        selected={itemIndex === selectedIndex}
                        hovered={
                            itemIndex !== null && itemIndex === hoveredIndex
                        }
                        isNight={isNight}
                        onMouseDown={handleSelect}
                        onClick={handleClick}
                        onMouseEnter={() =>
                            setHoveredIndex(
                                itemIndex !== null ? itemIndex : null,
                            )
                        }
                        onMouseLeave={() => setHoveredIndex(null)}
                    />
                ))}
                <MenuCenter
                    isNested={isNested}
                    title={hoveredItem?.title}
                    onClick={handleCenterClick}
                />
            </svg>
        </div>
    );
};
