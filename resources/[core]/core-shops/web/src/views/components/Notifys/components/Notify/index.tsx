import type { INotify, NotifyType } from "@app/stores/Notify";
import { cn } from "@app/utils";
import {
	ErrorIcon,
	InfoIcon,
	SuccessIcon,
	WarnIcon,
} from "@views/assets/icons/Notify";
import { useEffect, useState } from "react";

const variants: Record<
	NotifyType,
	{ styles: React.CSSProperties; icon: JSX.Element }
> = {
	warn: {
		styles: {
			border: ".0625rem solid rgba(255, 166, 0, 1)",
			background:
				"linear-gradient(65.16deg, rgba(255, 166, 0, 0.6) 7.72%, rgba(230, 149, 0, 0.6) 94.7%)",
		},
		icon: <WarnIcon />,
	},
	success: {
		styles: {
			border: ".0625rem solid #52FF97",
			background:
				"linear-gradient(90deg, rgba(54, 207, 127, 0.8) 0%, rgba(41, 156, 95, 0.8) 100%)",
		},
		icon: <SuccessIcon />,
	},
	error: {
		styles: {
			border: ".0625rem solid rgba(199, 30, 36, 1)",
			background:
				"linear-gradient(90deg, rgba(199, 30, 36, 0.8) 0%, rgba(173, 26, 31, 0.8) 100%)",
		},
		icon: <ErrorIcon />,
	},
	info: {
		styles: {
			border: ".0625rem solid rgba(87, 125, 241, 1)",
			background:
				"linear-gradient(90deg, rgba(87, 125, 241, 0.8) 0%, rgba(69, 99, 191, 0.8) 100%)",
		},
		icon: <InfoIcon />,
	},
};

export function Notify({ desc, time, type }: INotify) {
	const [isRendered, setIsRendered] = useState(false);

	useEffect(() => {
		const enterId = setTimeout(() => setIsRendered(true), 50);
		const leaveId = setTimeout(() => setIsRendered(false), time - 500);

		return () => {
			clearTimeout(enterId);
			clearTimeout(leaveId);
		};
	}, [time]);

	return (
		<div
			className={cn(
				"flex h-8 w-fit items-center gap-2.5 rounded-[.1875rem] px-[.9375rem] transition-all duration-500",
				isRendered
					? "translate-y-0 scale-100 opacity-100"
					: "translate-y-full scale-90 opacity-0",
			)}
			style={variants[type].styles}
		>
			{variants[type].icon}
			<span className="relative bottom-[.0625rem] whitespace-nowrap font-semibold text-[.8125rem] text-white">
				{desc}
			</span>
		</div>
	);
}
