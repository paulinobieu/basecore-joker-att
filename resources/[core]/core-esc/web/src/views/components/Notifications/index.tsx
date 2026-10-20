import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { cn } from "@app/utils";
import { debugData } from "@app/utils/debugData";
import { type CSSProperties, type ReactNode, useEffect, useState } from "react";
import { v4 as uuidv4 } from "uuid";

type NotificationType = "warn" | "success" | "error" | "info";

interface NotificationData {
	desc: string;
	time: number;
	type: NotificationType;
}

interface Notification extends NotificationData {
	id: string;
}

const ErrorIcon = () => (
	<svg
		width="1.1875rem"
		height="1.1875rem"
		viewBox="0 0 19 19"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M5.54199 5.54163L13.4587 13.4583M5.54199 13.4583L13.4587 5.54163"
			stroke="white"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
	</svg>
);

const InfoIcon = () => (
	<svg
		width="1.1875rem"
		height="1.1875rem"
		viewBox="0 0 19 19"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M9.50342 13.1113V8.77816M9.4699 6.38205H9.47674M9.5 16C11.2239 16 12.8772 15.3152 14.0962 14.0962C15.3152 12.8772 16 11.2239 16 9.5C16 7.77609 15.3152 6.12279 14.0962 4.90381C12.8772 3.68482 11.2239 3 9.5 3C7.77609 3 6.12279 3.68482 4.90381 4.90381C3.68482 6.12279 3 7.77609 3 9.5C3 11.2239 3.68482 12.8772 4.90381 14.0962C6.12279 15.3152 7.77609 16 9.5 16Z"
			stroke="white"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
	</svg>
);

const SuccessIcon = () => (
	<svg
		width="1.1875rem"
		height="1.1875rem"
		viewBox="0 0 19 19"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M15.5351 5.29526C15.447 5.2052 15.3268 5.1538 15.2008 5.15237C15.0749 5.15095 14.9535 5.19961 14.8634 5.28766L7.44772 12.7043L4.13507 9.39261C4.04548 9.30609 3.92549 9.25821 3.80095 9.25929C3.67641 9.26037 3.55727 9.31033 3.4692 9.3984C3.38113 9.48646 3.33118 9.6056 3.3301 9.73014C3.32901 9.85469 3.37689 9.97467 3.46342 10.0643L7.11142 13.7123C7.20049 13.8013 7.32129 13.8513 7.44724 13.8513C7.57319 13.8513 7.69399 13.8013 7.78307 13.7123L15.5351 5.96026C15.6221 5.87147 15.6708 5.75209 15.6708 5.62776C15.6708 5.50343 15.6221 5.38405 15.5351 5.29526Z"
			fill="white"
		/>
	</svg>
);

const WarnIcon = () => (
	<svg
		width="1.0625rem"
		height="1.0625rem"
		viewBox="0 0 17 17"
		fill="none"
		xmlns="http://www.w3.org/2000/svg"
	>
		<path
			d="M2.84161 14.8169H14.1592C14.343 14.8169 14.5237 14.7691 14.6836 14.6784C14.8434 14.5877 14.977 14.457 15.0712 14.2992C15.1655 14.1414 15.2172 13.9618 15.2213 13.778C15.2254 13.5942 15.1817 13.4126 15.0946 13.2507L9.43608 2.74191C9.03465 1.99684 7.96618 1.99684 7.56475 2.74191L1.90628 13.2507C1.81913 13.4126 1.77547 13.5942 1.77956 13.778C1.78365 13.9618 1.83534 14.1414 1.92959 14.2992C2.02383 14.457 2.15741 14.5877 2.31727 14.6784C2.47713 14.7691 2.65779 14.8169 2.84161 14.8169Z"
			stroke="white"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
		<path
			d="M8.3097 6.48761L8.50028 10.5384L8.69054 6.48927C8.69171 6.46338 8.6876 6.43753 8.67844 6.41329C8.66929 6.38905 8.65529 6.36693 8.63729 6.34828C8.6193 6.32964 8.59769 6.31485 8.57379 6.30484C8.54989 6.29483 8.5242 6.2898 8.49829 6.29005C8.47283 6.2903 8.44768 6.29564 8.42433 6.30577C8.40097 6.3159 8.37988 6.33061 8.3623 6.34902C8.34472 6.36744 8.33101 6.38919 8.32197 6.41299C8.31294 6.43679 8.30877 6.46216 8.3097 6.48761Z"
			stroke="white"
			strokeLinecap="round"
			strokeLinejoin="round"
		/>
		<path
			d="M8.5 13.1899C8.36866 13.1899 8.24027 13.151 8.13107 13.078C8.02186 13.0051 7.93675 12.9013 7.88649 12.78C7.83623 12.6587 7.82307 12.5251 7.8487 12.3963C7.87432 12.2675 7.93757 12.1492 8.03044 12.0563C8.12331 11.9634 8.24163 11.9002 8.37045 11.8746C8.49926 11.849 8.63278 11.8621 8.75413 11.9124C8.87547 11.9626 8.97918 12.0477 9.05215 12.1569C9.12512 12.2661 9.16406 12.3945 9.16406 12.5259C9.16406 12.702 9.0941 12.8709 8.96956 12.9954C8.84503 13.12 8.67612 13.1899 8.5 13.1899Z"
			fill="white"
		/>
	</svg>
);

const NOTIFICATION_VARIANTS: Record<
	NotificationType,
	{ styles: CSSProperties; icon: ReactNode }
> = {
	warn: {
		styles: {
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

function NotificationItem({ desc, time, type }: Notification) {
	const [show, setShow] = useState(false);
	const [removed, setRemoved] = useState(false);

	useEffect(() => {
		const showTimer = setTimeout(() => {
			setShow(true);
		}, 50);
		const hideTimer = setTimeout(() => {
			setShow(false);
		}, time - 500);
		const removeTimer = setTimeout(() => {
			setRemoved(true);
		}, time);

		return () => {
			clearTimeout(showTimer);
			clearTimeout(hideTimer);
			clearTimeout(removeTimer);
		};
	}, [time]);

	return (
		<div
			className={cn(
				"flex h-[1.8125rem] w-fit translate-x-full items-center gap-2.5 rounded-[.1875rem] px-[.9375rem] opacity-0 transition-all duration-500",
				show ? "translate-x-0 opacity-100" : "translate-x-full",
				removed && "absolute",
			)}
			style={NOTIFICATION_VARIANTS[type].styles}
		>
			{NOTIFICATION_VARIANTS[type].icon}
			<span className="relative bottom-[.0625rem] whitespace-nowrap text-nowrap text-[.8125rem] uppercase">
				{desc}
			</span>
		</div>
	);
}

export function Notifications() {
	const [notifications, setNotifications] = useState<Notification[]>([]);

	useNuiMessage<NotificationData>("sendNotify", (payload) => {
		const id = uuidv4();
		setNotifications((current) => [...current, { ...payload, id }]);
	});

	useEffect(() => {
		const timers: Record<string, ReturnType<typeof setTimeout>> = {};

		notifications.forEach((notification) => {
			if (!timers[notification.id]) {
				timers[notification.id] = setTimeout(() => {
					setNotifications((current) =>
						current.filter((item) => item.id !== notification.id),
					);
					delete timers[notification.id];
				}, notification.time || 15000);
			}
		});

		return () => {
			Object.values(timers).forEach(clearTimeout);
		};
	}, [notifications]);

	useEffect(() => {
		debugData<NotificationData>([
			{
				action: "sendNotify",
				payload: {
					desc: "Bem-vindo ao servidor",
					time: 5000,
					type: "success",
				},
			},
		]);
	}, []);

	return (
		<div className="fixed right-10 bottom-10 z-[999] flex flex-col items-end gap-2">
			{notifications?.length > 0 &&
				notifications.map((notification) => (
					<NotificationItem key={notification.id} {...notification} />
				))}
		</div>
	);
}
