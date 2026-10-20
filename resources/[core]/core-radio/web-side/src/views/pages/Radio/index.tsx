import {
	useCallback,
	useEffect,
	useMemo,
	useRef,
	useState,
	type CSSProperties,
	type Dispatch,
	type SetStateAction,
} from "react";
import { getAnimationThumbnailById } from "@app/config/animationThumbs";
import {
	EFFECT_CIRCLE_A,
	EFFECT_CIRCLE_B,
	ICON_CHANNEL_PUBLIC,
	ICON_FREQUENCY,
	ICON_POWER,
	ICON_SPEAKING,
	ICON_TRASH,
	ICON_VOLUME,
	ICON_VOLUME_SLIDER,
	ICON_ACTIVE_WALKIE,
} from "@app/config/icons";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { useClickSound } from "@app/hooks/useClickSound";
import type { AnimationOption, RadioChannel } from "@app/types/radio";
import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import { PrivateLockIcon } from "@views/components/PrivateLockIcon";
import { TalkerToggleIcon } from "@views/components/TalkerToggleIcon";

type UiView = "main" | "animations";
type ScrollbarState = {
	visible: boolean;
	thumbHeight: number;
	thumbOffset: number;
};

const RADIO_MIN = 1;
const RADIO_MAX = 999;

const hexToRgb = (hex: string) => {
	const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
	return result
		? `${parseInt(result[1], 16)}, ${parseInt(result[2], 16)}, ${parseInt(result[3], 16)}`
		: null;
};

export function Radio() {
	useClickSound();
	const closeAnimationTimeoutRef = useRef<number | null>(null);
	const connectAnimationTimeoutRef = useRef<number | null>(null);
	const disconnectAnimationTimeoutsRef = useRef<Record<string, number>>({});
	const channelsListRef = useRef<HTMLDivElement | null>(null);
	const animationsGridRef = useRef<HTMLDivElement | null>(null);
	const [visible, setVisible] = useState<boolean>(false);
	const [isPanelRendered, setIsPanelRendered] = useState<boolean>(false);
	const [isClosingPanel, setIsClosingPanel] = useState<boolean>(false);
	const [view, setView] = useState<UiView>("main");
	const [inputFrequency, setInputFrequency] = useState<string>("");
	const [publicChannels, setPublicChannels] = useState<RadioChannel[]>([]);
	const [activeRadioId, setActiveRadioId] = useState<string | null>(null);
	const [volume, setVolume] = useState<number>(100);
	const [showVolumeSlider, setShowVolumeSlider] = useState<boolean>(false);
	const [activeSpeakers, setActiveSpeakers] = useState<
		{ id: string; name: string }[]
	>([]);
	const [showRadioTalkers, setShowRadioTalkers] = useState<boolean>(false);
	const [animations] = useState<AnimationOption[]>(
		Array.from({ length: 18 }, (_, i) => ({
			id: `anim-${i + 1}`,
			label: `Animação ${i + 1}`,
			thumbnail: getAnimationThumbnailById(`anim-${i + 1}`),
		})),
	);
	const [selectedAnimationId, setSelectedAnimationId] =
		useState<string>("anim-1");
	const [connectingChannelId, setConnectingChannelId] = useState<
		string | null
	>(null);
	const [disconnectingChannelIds, setDisconnectingChannelIds] = useState<
		string[]
	>([]);
	const [channelsScrollbar, setChannelsScrollbar] = useState<ScrollbarState>({
		visible: false,
		thumbHeight: 0,
		thumbOffset: 0,
	});
	const [animationsScrollbar, setAnimationsScrollbar] =
		useState<ScrollbarState>({
			visible: false,
			thumbHeight: 0,
			thumbOffset: 0,
		});
	const [themeColor, setThemeColor] = useState<string>("#DC153A");
	const [themeRgb, setThemeRgb] = useState<string>("220, 21, 58");
	const [radioAlign, setRadioAlign] = useState<"left" | "right">("left");
	const [speakingAlign, setSpeakingAlign] = useState<"left" | "right">(
		"right",
	);

	const selectedAnimation = useMemo(
		() =>
			animations.find(
				(animation) => animation.id === selectedAnimationId,
			),
		[animations, selectedAnimationId],
	);

	const updateFakeScrollbar = useCallback(
		(
			element: HTMLDivElement | null,
			setState: Dispatch<SetStateAction<ScrollbarState>>,
			options?: { showWhenNoOverflow?: boolean; hasContent?: boolean },
		) => {
			if (!element) {
				return;
			}

			const { clientHeight, scrollHeight, scrollTop } = element;
			const canScroll = scrollHeight - clientHeight > 1;
			const shouldKeepVisible = Boolean(
				options?.showWhenNoOverflow &&
					options?.hasContent &&
					clientHeight > 0,
			);
			if (!canScroll) {
				if (shouldKeepVisible) {
					setState({
						visible: true,
						thumbHeight: clientHeight,
						thumbOffset: 0,
					});
					return;
				}
				setState({ visible: false, thumbHeight: 0, thumbOffset: 0 });
				return;
			}

			const minThumbHeight = 24;
			const thumbHeight = Math.max(
				minThumbHeight,
				(clientHeight / scrollHeight) * clientHeight,
			);
			const maxThumbOffset = Math.max(0, clientHeight - thumbHeight);
			const maxScrollTop = Math.max(1, scrollHeight - clientHeight);
			const thumbOffset = (scrollTop / maxScrollTop) * maxThumbOffset;

			setState({ visible: true, thumbHeight, thumbOffset });
		},
		[],
	);

	const startConnectAnimation = useCallback((channelId: string) => {
		if (connectAnimationTimeoutRef.current !== null) {
			window.clearTimeout(connectAnimationTimeoutRef.current);
			connectAnimationTimeoutRef.current = null;
		}

		setConnectingChannelId(channelId);
		connectAnimationTimeoutRef.current = window.setTimeout(() => {
			setConnectingChannelId((current) =>
				current === channelId ? null : current,
			);
			connectAnimationTimeoutRef.current = null;

			if (isEnvBrowser()) {
				const fakeFrequency = parseInt(
					channelId.split("-")[1] || "1",
					10,
				);

				setPublicChannels((current) => {
					if (current.some((c) => c.frequency === fakeFrequency))
						return current;
					const newChannel: RadioChannel = {
						id: channelId,
						label: `Canal ${fakeFrequency}`,
						frequency: fakeFrequency,
						connected: true,
						type:
							fakeFrequency === 1 || fakeFrequency > 500
								? "private"
								: "public",
					};
					return [...current, newChannel].sort(
						(a, b) => a.frequency - b.frequency,
					);
				});
				setActiveRadioId(channelId);
			}
		}, 220);
	}, []);

	const closeInterface = useCallback(() => {
		setVisible(false);
		setShowVolumeSlider(false);
		setView("main");
		void fetchNui("radio:ui:close");
	}, []);

	const connectFrequency = useCallback(
		(frequency: number) => {
			startConnectAnimation(`radio-${frequency}`);
			void fetchNui("radio:connect", { frequency });
		},
		[startConnectAnimation],
	);

	const handleFrequencySubmit = useCallback(() => {
		const parsedFrequency = Number(inputFrequency.trim());
		if (
			!Number.isInteger(parsedFrequency) ||
			parsedFrequency < RADIO_MIN ||
			parsedFrequency > RADIO_MAX
		) {
			return;
		}

		connectFrequency(parsedFrequency);
		setInputFrequency("");
	}, [connectFrequency, inputFrequency]);

	const handleDisconnectFrequency = useCallback(
		(frequency: number) => {
			const channelToRemove = publicChannels.find(
				(channel) => channel.frequency === frequency,
			);
			if (!channelToRemove) {
				return;
			}

			if (
				disconnectAnimationTimeoutsRef.current[channelToRemove.id]
			) {
				return;
			}

			setDisconnectingChannelIds((current) =>
				current.includes(channelToRemove.id)
					? current
					: [...current, channelToRemove.id],
			);

			disconnectAnimationTimeoutsRef.current[channelToRemove.id] =
				window.setTimeout(() => {
					setPublicChannels((current) => {
						const removeIndex = current.findIndex(
							(channel) => channel.id === channelToRemove.id,
						);
						if (removeIndex < 0) {
							return current;
						}

						const removeId = current[removeIndex].id;
						const next = current.filter(
							(channel) => channel.id !== removeId,
						);

						if (removeId === activeRadioId) {
							const previous =
								next[removeIndex - 1] ?? next[0] ?? null;
							setActiveRadioId(previous ? previous.id : null);
						}

						return next;
					});

					setDisconnectingChannelIds((current) =>
						current.filter((id) => id !== channelToRemove.id),
					);
					delete disconnectAnimationTimeoutsRef.current[
						channelToRemove.id
					];
				}, 180);

			void fetchNui("radio:disconnect", { frequency });
		},
		[activeRadioId, publicChannels],
	);

	const selectActiveByOffset = useCallback(
		(offset: number) => {
			if (publicChannels.length === 0) {
				return;
			}

			const currentIndex = publicChannels.findIndex(
				(channel) => channel.id === activeRadioId,
			);
			const safeCurrentIndex = currentIndex >= 0 ? currentIndex : 0;
			const nextIndex = Math.min(
				Math.max(safeCurrentIndex + offset, 0),
				publicChannels.length - 1,
			);
			setActiveRadioId(publicChannels[nextIndex].id);
		},
		[activeRadioId, publicChannels],
	);

	const handleVolumeChange = useCallback(async (newVolume: number) => {
		setVolume(newVolume);
	}, []);

	const handleVolumeCommit = useCallback(async (newVolume: number) => {
		await fetchNui("radio:volume:set", { volume: newVolume });
	}, []);

	const handleAnimationConfirm = useCallback(() => {
		if (!selectedAnimation) {
			return;
		}

		setView("main");
		void fetchNui("radio:animation:set", {
			animationId: selectedAnimation.id,
		});
	}, [selectedAnimation]);

	const handleToggleTalkerIndicator = useCallback(() => {
		setShowRadioTalkers((current) => !current);
	}, []);

	/* ───── NUI Events (integração com Lua) ───── */

	useNuiEvent<{
		themeColor?: string;
		radioAlign?: "left" | "right";
		speakingAlign?: "left" | "right";
	}>("radio:ui:config", (config) => {
		if (config.themeColor) {
			setThemeColor(config.themeColor);
			const rgb = hexToRgb(config.themeColor);
			if (rgb) setThemeRgb(rgb);
		}
		if (config.radioAlign) setRadioAlign(config.radioAlign);
		if (config.speakingAlign) setSpeakingAlign(config.speakingAlign);
	});

	useNuiEvent<{ visible: boolean }>(
		"radio:ui:visible",
		({ visible: nextVisible }) => setVisible(nextVisible),
	);
	useNuiEvent<{ frequency: number }>(
		"radio:ui:connected",
		({ frequency }) => {
			setActiveRadioId(`radio-${frequency}`);
		},
	);
	useNuiEvent<{ volume: number }>(
		"radio:ui:volume",
		({ volume: nextVolume }) => setVolume(nextVolume),
	);
	useNuiEvent<{
		playerName: string;
		playerId?: string;
		talking: boolean;
	}>("radio:ui:speaking", ({ playerName, playerId, talking }) => {
		const speakerId = playerId || playerName;
		if (talking) {
			setActiveSpeakers((current) => {
				if (current.some((s) => s.id === speakerId)) return current;
				return [
					...current,
					{
						id: speakerId,
						name: `${playerName} #${playerId || "?"}`,
					},
				];
			});
		} else {
			setActiveSpeakers((current) =>
				current.filter((s) => s.id !== speakerId),
			);
		}
	});
	useNuiEvent<{
		publicChannels: RadioChannel[];
		restrictedFrequencies: number[];
	}>(
		"radio:ui:channels",
		({
			publicChannels: nextPublicChannels,
			restrictedFrequencies: nextRestrictedFrequencies,
		}) => {
			const restrictedSet = new Set(nextRestrictedFrequencies);
			const normalizedChannels: RadioChannel[] = nextPublicChannels.map(
				(channel) => ({
					...channel,
					type: restrictedSet.has(channel.frequency)
						? ("private" as const)
						: ("public" as const),
				}),
			);
			setPublicChannels(normalizedChannels);
			setActiveRadioId((current) => {
				if (
					current &&
					normalizedChannels.some(
						(channel) => channel.id === current,
					)
				)
					return current;
				const last =
					normalizedChannels[normalizedChannels.length - 1];
				return last ? last.id : null;
			});
		},
	);
	useNuiEvent<{ selectedAnimationId: string }>(
		"radio:ui:animations",
		({ selectedAnimationId: nextSelectedAnimationId }) => {
			setSelectedAnimationId(nextSelectedAnimationId);
		},
	);

	/* ───── Effects ───── */

	useEffect(() => {
		if (closeAnimationTimeoutRef.current !== null) {
			window.clearTimeout(closeAnimationTimeoutRef.current);
			closeAnimationTimeoutRef.current = null;
		}

		if (visible) {
			setIsPanelRendered(true);
			setIsClosingPanel(false);
			return;
		}

		if (!isPanelRendered) {
			return;
		}

		setIsClosingPanel(true);
		closeAnimationTimeoutRef.current = window.setTimeout(() => {
			setIsPanelRendered(false);
			setIsClosingPanel(false);
			closeAnimationTimeoutRef.current = null;
		}, 180);
	}, [isPanelRendered, visible]);

	useEffect(() => {
		return () => {
			if (closeAnimationTimeoutRef.current !== null) {
				window.clearTimeout(closeAnimationTimeoutRef.current);
			}
			if (connectAnimationTimeoutRef.current !== null) {
				window.clearTimeout(connectAnimationTimeoutRef.current);
			}
			Object.values(disconnectAnimationTimeoutsRef.current).forEach(
				(timeoutId) => {
					window.clearTimeout(timeoutId);
				},
			);
		};
	}, []);

	useEffect(() => {
		const onKeyDown = (event: KeyboardEvent) => {
			if (event.key === "Escape" && visible) {
				closeInterface();
			}

			if (event.key === "Insert" && isEnvBrowser()) {
				setVisible((prev) => !prev);
			}
		};

		window.addEventListener("keydown", onKeyDown);
		return () => window.removeEventListener("keydown", onKeyDown);
	}, [closeInterface, visible]);

	const syncChannelsScrollbar = useCallback(() => {
		updateFakeScrollbar(channelsListRef.current, setChannelsScrollbar, {
			showWhenNoOverflow: true,
			hasContent: publicChannels.length > 0,
		});
	}, [publicChannels.length, updateFakeScrollbar]);

	const syncAnimationsScrollbar = useCallback(() => {
		updateFakeScrollbar(
			animationsGridRef.current,
			setAnimationsScrollbar,
		);
	}, [updateFakeScrollbar]);

	useEffect(() => {
		const raf = window.requestAnimationFrame(() => {
			syncChannelsScrollbar();
		});
		return () => window.cancelAnimationFrame(raf);
	}, [
		publicChannels.length,
		showVolumeSlider,
		syncChannelsScrollbar,
		view,
		isPanelRendered,
	]);

	useEffect(() => {
		const raf = window.requestAnimationFrame(() => {
			syncAnimationsScrollbar();
		});
		return () => window.cancelAnimationFrame(raf);
	}, [
		animations.length,
		selectedAnimationId,
		syncAnimationsScrollbar,
		view,
		isPanelRendered,
	]);

	useEffect(() => {
		if (!isEnvBrowser()) return;

		setVisible(true);
		setPublicChannels([]);
		setActiveRadioId(null);
	}, []);

	/* ───── Render ───── */

	const bgImage = isEnvBrowser() ? "/background.png" : "";
	const rootStyle = {
		...(bgImage ? { backgroundImage: `url(${bgImage})` } : {}),
		"--theme-color": themeColor,
		"--theme-color-rgb": themeRgb,
	} as CSSProperties;

	return (
		<main
			className={`radio-root radio-root--${radioAlign}`}
			style={rootStyle}
		>
			{isPanelRendered && (
				<section
					className={`radio-shell radio-shell--${radioAlign} ${view === "animations" ? "radio-shell--animations" : ""} ${isClosingPanel ? "radio-shell--closing" : "radio-shell--opening"}`}
				>
					<div className="radio-frame">
						<div className="radio-inner">
							<img
								alt=""
								className="effect-circle effect-circle--a"
								src={EFFECT_CIRCLE_A}
							/>
							<img
								alt=""
								className="effect-circle effect-circle--b"
								src={EFFECT_CIRCLE_B}
							/>
							<img
								alt=""
								className="effect-circle effect-circle--c"
								src={EFFECT_CIRCLE_A}
							/>

							<div className="radio-title">
								<div className="title-icon">
									{view === "main" ? (
										<svg
											width="20"
											height="26"
											viewBox="0 0 20 26"
											fill="none"
											xmlns="http://www.w3.org/2000/svg"
										>
										<path
											d="M13.2295 10.0718C13.6544 9.6663 13.9802 9.19949 14.2068 8.67138C14.4334 8.14327 14.5515 7.58215 14.5609 6.98803C14.5609 6.39391 14.4476 5.83279 14.221 5.30468C13.9943 4.77657 13.6638 4.30976 13.2295 3.90424L14.4901 2.60283C15.0944 3.18752 15.5571 3.85238 15.8782 4.59739C16.1992 5.3424 16.3645 6.13928 16.3739 6.98803C16.3739 7.82735 16.2134 8.61951 15.8924 9.36453C15.5713 10.1095 15.1039 10.7791 14.4901 11.3732L13.2295 10.0718ZM17.0113 0C17.4835 0.452666 17.9037 0.947769 18.272 1.48531C18.6402 2.02285 18.9566 2.58868 19.221 3.18281C19.4854 3.77693 19.6789 4.39463 19.8017 5.03591C19.9245 5.67719 19.9906 6.32789 20 6.98803C20 7.64817 19.9339 8.29888 19.8017 8.94015C19.6695 9.58143 19.4759 10.1991 19.221 10.7933C18.966 11.3874 18.6544 11.9532 18.2861 12.4908C17.9178 13.0283 17.4929 13.5234 17.0113 13.9761L15.7507 12.6746C16.5345 11.9202 17.1341 11.0573 17.5496 10.086C17.9651 9.11462 18.1775 8.08197 18.187 6.98803C18.187 5.90352 17.9792 4.87559 17.5637 3.90424C17.1483 2.9329 16.5439 2.06529 15.7507 1.30141L17.0113 0ZM5.50992 11.3732C4.90557 10.7885 4.44287 10.1237 4.12181 9.37867C3.80076 8.63366 3.63551 7.83678 3.62606 6.98803C3.62606 6.14871 3.78659 5.35655 4.10765 4.61153C4.42871 3.86652 4.89613 3.19695 5.50992 2.60283L6.77054 3.90424C6.34561 4.30976 6.01983 4.77657 5.7932 5.30468C5.56657 5.83279 5.44854 6.39391 5.43909 6.98803C5.43909 7.58215 5.55241 8.14327 5.77904 8.67138C6.00567 9.19949 6.33617 9.6663 6.77054 10.0718L5.50992 11.3732ZM2.98867 13.9761C2.51653 13.5234 2.09632 13.0283 1.72805 12.4908C1.35977 11.9532 1.04344 11.3874 0.779037 10.7933C0.514636 10.1991 0.321058 9.58143 0.1983 8.94015C0.075543 8.29888 0.00944287 7.64817 0 6.98803C0 6.32789 0.0661001 5.67719 0.1983 5.03591C0.3305 4.39463 0.524079 3.77693 0.779037 3.18281C1.03399 2.58868 1.34561 2.02285 1.71388 1.48531C2.08215 0.947769 2.50708 0.452666 2.98867 0L4.24929 1.30141C3.46553 2.05586 2.86591 2.91875 2.45042 3.8901C2.03494 4.86144 1.82247 5.89409 1.81303 6.98803C1.81303 8.07254 2.02077 9.10047 2.43626 10.0718C2.85175 11.0432 3.45609 11.9108 4.24929 12.6746L2.98867 13.9761ZM12.7195 6.98803C12.7195 7.41241 12.6298 7.80849 12.4504 8.17628C12.271 8.54407 12.0113 8.85999 11.6714 9.12405L17.2946 26H15.3966L14.1785 22.3787H5.82153L4.6034 26H2.70538L8.32861 9.12405C7.99811 8.86942 7.74315 8.55822 7.56374 8.19042C7.38433 7.82263 7.2899 7.42184 7.28045 6.98803C7.28045 6.61081 7.35127 6.25716 7.49292 5.92709C7.63456 5.59703 7.82814 5.30939 8.07365 5.0642C8.31917 4.81901 8.60718 4.62568 8.93768 4.48422C9.26818 4.34276 9.62229 4.27204 10 4.27204C10.3777 4.27204 10.7318 4.34276 11.0623 4.48422C11.3928 4.62568 11.6808 4.81901 11.9263 5.0642C12.1719 5.30939 12.3654 5.59703 12.5071 5.92709C12.6487 6.25716 12.7195 6.61081 12.7195 6.98803ZM10 6.0827C9.75449 6.0827 9.54202 6.17229 9.36261 6.35147C9.18319 6.53065 9.09348 6.74284 9.09348 6.98803C9.09348 7.23322 9.18319 7.44541 9.36261 7.62459C9.54202 7.80377 9.75449 7.89336 10 7.89336C10.2455 7.89336 10.458 7.80377 10.6374 7.62459C10.8168 7.44541 10.9065 7.23322 10.9065 6.98803C10.9065 6.74284 10.8168 6.53065 10.6374 6.35147C10.458 6.17229 10.2455 6.0827 10 6.0827ZM10 9.84548L8.22946 15.136H11.7705L10 9.84548ZM13.5836 20.568L12.3654 16.9467H7.63456L6.41643 20.568H13.5836Z"
											fill="var(--theme-color)"
										/>
									</svg>
								) : (
									<svg
										width="24"
										height="28"
										viewBox="0 0 32 36"
										fill="none"
										xmlns="http://www.w3.org/2000/svg"
									>
										<path
											d="M14.5959 0V1.63636L13.3388 0.589091L7.67347 7.36364L12.9633 10.6364V6.80727L12.6041 6.54545L14.5959 4.18909V36H17.8612V20.0291L21.0122 16.8709C25.2082 17.5255 29.502 15.3164 32 12.8127L29.6816 10.4891C27.8204 12.3709 23.902 14.0891 21.1265 13.5164L17.8612 10.2109V0M22.7592 4.90909C21.8932 4.90909 21.0626 5.25389 20.4503 5.86765C19.8379 6.48141 19.4939 7.31384 19.4939 8.18182C19.4939 9.0498 19.8379 9.88223 20.4503 10.496C21.0626 11.1097 21.8932 11.4545 22.7592 11.4545C23.6252 11.4545 24.4557 11.1097 25.0681 10.496C25.6805 9.88223 26.0245 9.0498 26.0245 8.18182C26.0245 7.31384 25.6805 6.48141 25.0681 5.86765C24.4557 5.25389 23.6252 4.90909 22.7592 4.90909ZM12.9633 11.0618L6.59592 17.4436C3.57551 20.4545 2.04082 22.6636 0 28.08L3.06939 29.2255C4.70204 24.8727 5.87755 23.1382 7.85306 21.0109L10.0571 23.22L1.97551 31.32L4.29388 33.6436L12.9633 24.9382V11.0618Z"
											fill="var(--theme-color)"
										/>
									</svg>
								)}
								</div>
								<div>
									<h1>
										{view === "main"
											? "Rádio"
											: "Animações"}
									</h1>
									<p>
										{view === "main"
											? "Conecte-se abaixo a uma frequência"
											: "Selecione sua animação preferida"}
									</p>
								</div>
							</div>

							{view === "main" ? (
								<>
									<div className="input-row">
										<img
											alt=""
											className="signal-icon"
											src={ICON_FREQUENCY}
										/>
										<input
											aria-label="Digite uma frequência"
											className="frequency-input"
											inputMode="numeric"
											maxLength={3}
											placeholder="Insira a sua frequência"
											value={inputFrequency}
											onChange={(event) =>
												setInputFrequency(
													event.target.value.replace(
														/\D/g,
														"",
													),
												)
											}
											onKeyDown={(event) => {
												if (event.key === "Enter") {
													void handleFrequencySubmit();
												}
											}}
										/>
										<button
											className="icon-button"
											type="button"
											onClick={handleFrequencySubmit}
											title="Conectar"
										>
											<img
												alt=""
												className="power-icon"
												src={ICON_POWER}
											/>
										</button>
										<button
											className="chip-button"
											type="button"
											onClick={() =>
												setView("animations")
											}
										>
											Animação
										</button>
									</div>

									<div className="channels-list-wrap fake-scroll-host">
										<div
											className="channels-list list-with-fake-scroll"
											ref={channelsListRef}
											onScroll={syncChannelsScrollbar}
										>
											{publicChannels.map((channel) => (
												<article
													className={`channel-row ${channel.id === activeRadioId && channel.connected ? "channel-row--active" : ""} ${connectingChannelId === channel.id ? "channel-row--connecting" : ""} ${disconnectingChannelIds.includes(channel.id) ? "channel-row--disconnecting" : ""}`}
													key={channel.id}
													onClick={() => {
														if (
															channel.id !==
															activeRadioId
														) {
															setConnectingChannelId(
																channel.id,
															);
															if (
																connectAnimationTimeoutRef.current
															)
																window.clearTimeout(
																	connectAnimationTimeoutRef.current,
																);
															connectAnimationTimeoutRef.current =
																window.setTimeout(
																	() =>
																		setConnectingChannelId(
																			null,
																		),
																	220,
																);
														}
														setActiveRadioId(
															channel.id,
														);
														void fetchNui(
															"radio:select",
															{
																frequency:
																	channel.frequency,
															},
														);
													}}
												>
													{channel.type ===
													"public" ? (
														<img
															alt=""
															className="channel-type-icon channel-type-icon--public"
															src={
																ICON_CHANNEL_PUBLIC
															}
														/>
													) : (
														<PrivateLockIcon
															className="channel-type-icon channel-type-icon--private"
															color="var(--theme-color)"
														/>
													)}
													<strong>
														{channel.label}
													</strong>
													<span
														className={`radio-tag radio-tag--${channel.type}`}
													>
														{channel.type ===
														"public"
															? "Publica"
															: "Privado"}
													</span>
													<div className="row-actions">
														<button
															className="icon-button"
															type="button"
															title="Volume"
															onClick={() =>
																setShowVolumeSlider(
																	(current) =>
																		!current,
																)
															}
														>
															<img
																alt=""
																className="row-action-icon"
																src={
																	ICON_VOLUME
																}
															/>
														</button>

														<button
															className="icon-button icon-button--danger"
															disabled={disconnectingChannelIds.includes(
																channel.id,
															)}
															type="button"
															title="Remover"
															onClick={(
																event,
															) => {
																event.stopPropagation();
																handleDisconnectFrequency(
																	channel.frequency,
																);
															}}
														>
															<img
																alt=""
																className="row-action-icon row-action-icon--trash"
																src={
																	ICON_TRASH
																}
															/>
														</button>
													</div>
												</article>
											))}
										</div>
										{channelsScrollbar.visible && (
											<div
												aria-hidden="true"
												className="fake-scrollbar"
											>
												<span
													style={{
														height: `${channelsScrollbar.thumbHeight}px`,
														transform: `translateY(${channelsScrollbar.thumbOffset}px)`,
													}}
												/>
											</div>
										)}
									</div>

									<div className="active-frequency-section">
										<div className="active-frequency-header">
											<div className="section-line" />
											<p>Frequência Ativa</p>
											<div className="section-line section-line--right" />
										</div>

										{activeRadioId ? (
											<article
												className="active-frequency-card active-frequency-card--appear"
												key="active-connected"
											>
												<div className="active-frequency-icon-wrap">
													<img
														alt=""
														className="active-frequency-icon"
														src={
															ICON_ACTIVE_WALKIE
														}
													/>
												</div>
												<strong>
													{publicChannels.find(
														(c) =>
															c.id ===
															activeRadioId,
													)?.label || "Nenhuma"}
												</strong>
												<div
													className="row-actions"
													style={{
														marginLeft: "auto",
													}}
												>
													<button
														className={`icon-button ${showRadioTalkers ? "icon-button--toggle-active" : ""}`}
														title={
															showRadioTalkers
																? "Ocultar quem fala na rádio"
																: "Mostrar quem fala na rádio"
														}
														type="button"
														onClick={
															handleToggleTalkerIndicator
														}
													>
														<TalkerToggleIcon className="row-action-icon row-action-icon--talker" />
													</button>
												</div>
											</article>
										) : (
											<article
												className="active-frequency-card active-frequency-card--empty active-frequency-card--appear"
												key="active-empty"
											>
												<div className="active-frequency-icon-wrap">
													<img
														alt=""
														className="active-frequency-icon"
														style={{
															filter: "grayscale(1) opacity(0.3)",
														}}
														src={
															ICON_ACTIVE_WALKIE
														}
													/>
												</div>
												<strong>
													Nenhuma frequência
												</strong>
											</article>
										)}
									</div>
								</>
							) : (
								<section className="animations-panel">
									<div className="animations-grid-wrap fake-scroll-host">
										<div
											className="animations-grid list-with-fake-scroll"
											ref={animationsGridRef}
											onScroll={syncAnimationsScrollbar}
										>
											{animations.map((animation) => (
												<button
													className={`animation-card ${animation.id === selectedAnimationId ? "animation-card--selected" : ""}`}
													key={animation.id}
													type="button"
													onClick={() =>
														setSelectedAnimationId(
															animation.id,
														)
													}
												>
													<div className="animation-thumb">
														<img
															alt={
																animation.label
															}
															src={
																animation.thumbnail
															}
														/>
													</div>
												</button>
											))}
										</div>
										{animationsScrollbar.visible && (
											<div
												aria-hidden="true"
												className="fake-scrollbar"
											>
												<span
													style={{
														height: `${animationsScrollbar.thumbHeight}px`,
														transform: `translateY(${animationsScrollbar.thumbOffset}px)`,
													}}
												/>
											</div>
										)}
									</div>

									<button
										className="confirm-button"
										type="button"
										onClick={() =>
											void handleAnimationConfirm()
										}
									>
										Confirmar alteração
									</button>
								</section>
							)}
						</div>
						{view === "main" && (
							<div className="radio-bottom-slot">
								<div
									className={`bottom-control-layer ${showVolumeSlider ? "bottom-control-layer--hidden" : "bottom-control-layer--visible"}`}
								>
									<footer className="radio-footer radio-footer--outside">
										<span>
											<kbd
												onClick={() =>
													selectActiveByOffset(-1)
												}
											>
												Page Up
											</kbd>{" "}
											Subir frequência
										</span>
										<span>
											<kbd
												onClick={() =>
													selectActiveByOffset(1)
												}
											>
												Page Down
											</kbd>{" "}
											Descer frequência
										</span>
									</footer>
								</div>
								<div
									className={`bottom-control-layer ${showVolumeSlider ? "bottom-control-layer--visible" : "bottom-control-layer--hidden"}`}
								>
									<div
										className="volume-row volume-row--outside"
										style={
											{
												"--volume-progress": `${volume}%`,
											} as CSSProperties
										}
									>
										<img
											alt=""
											className="volume-slider-icon"
											src={ICON_VOLUME_SLIDER}
										/>
										<input
											aria-label="Controle de volume"
											max={100}
											min={0}
											type="range"
											value={volume}
											onChange={(event) =>
												handleVolumeChange(
													Number(
														event.target.value,
													),
												)
											}
											onMouseUp={(event) =>
												void handleVolumeCommit(
													Number(
														(
															event.target as HTMLInputElement
														).value,
													),
												)
											}
										/>
										<strong>{volume}%</strong>
									</div>
								</div>
							</div>
						)}
					</div>
				</section>
			)}

			{showRadioTalkers &&
				(activeSpeakers.length > 0 || isEnvBrowser()) && (
					<div
						className={`speaking-indicators speaking-indicators--${speakingAlign}`}
					>
						{activeSpeakers.length > 0 ? (
							activeSpeakers.map((speaker) => (
								<aside
									key={speaker.id}
									className="speaking-indicator"
								>
									<img
										alt=""
										className="speaking-icon"
										src={ICON_SPEAKING}
									/>{" "}
									{speaker.name}
								</aside>
							))
						) : (
							isEnvBrowser() && (
								<aside
									key="mock"
									className="speaking-indicator"
								>
									<img
										alt=""
										className="speaking-icon"
										src={ICON_SPEAKING}
									/>{" "}
									Bieuzadas Dev #123
								</aside>
							)
						)}
					</div>
				)}
		</main>
	);
}
