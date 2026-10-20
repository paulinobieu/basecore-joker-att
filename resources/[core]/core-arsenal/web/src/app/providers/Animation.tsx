import { cn } from "@app/utils";
import type { ClassValue } from "clsx";
import type React from "react";
import { useEffect, useState } from "react";

const duration = 400;

const transitionStyle = (state: string) => ({
	opacity: state === "entered" ? 1 : 0,
	transition: `opacity ${duration}ms ease`,
});

interface AnimationProviderProps {
	children: React.ReactNode;
	show?: boolean;
	className?: ClassValue;
	style?: React.CSSProperties;
}

export const AnimationProvider: React.FC<AnimationProviderProps> = ({
	children,
	className,
	style,
	show = false,
}) => {
	const [status, setStatus] = useState("unmounted");

	useEffect(() => {
		if (!show) {
			setStatus("exiting");
			const timeoutId = setTimeout(() => setStatus("exited"), duration);

			return () => clearTimeout(timeoutId);
		}

		setStatus("entering");

		let frame = requestAnimationFrame(() => {
			frame = requestAnimationFrame(() => setStatus("entered"));
		});
		const timeoutId = setTimeout(() => setStatus("entered"), 32);

		return () => {
			cancelAnimationFrame(frame);
			clearTimeout(timeoutId);
		};
	}, [show]);

	useEffect(() => {
		if (status === "exited") setStatus("unmounted");
	}, [status]);

	if (status === "unmounted") return null;

	return (
		<div
			style={{ ...transitionStyle(status), ...style }}
			className={cn("overflow-visible", className)}
		>
			{children}
		</div>
	);
};
