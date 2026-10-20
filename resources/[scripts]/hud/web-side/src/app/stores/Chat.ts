import { fetchNui } from "@app/utils/fetchNui";
import { isEnvBrowser } from "@app/utils/misc";
import type { ClassValue } from "clsx";
import type { CSSProperties } from "react";
import { create } from "zustand";

interface MessageProps {
	context: string;
	author?: string;
	typeIcon?: { src: string; className?: ClassValue };
	content?: string;
	header?: {
		title: string;
		subtitle?: string;
		icon: { src: string; className?: ClassValue };
		textDirection: "row" | "column";
		className?: ClassValue;
	};
	inlineMessage?: boolean;
	footer?: {
		title: string;
		subtitle?: string;
		icon: { src: string; className?: ClassValue };
		textDirection: "row" | "column";
		className?: ClassValue;
	};
	typeStyles?: CSSProperties;
	containerStyles?: CSSProperties;
}

interface HistoryProps {
	messages: string[];
	currentIndex: number;
}

interface ChatState {
	text: string;
	messages: MessageProps[];
	selectedCategory: string | null;
	chatTimeout: number;
	isChatVisible: boolean;
	isInputVisible: boolean;
	history: HistoryProps;
	categories: string[];
	hideChat: boolean;
	setText: (text: string) => void;
	setMessages: (messages: MessageProps[]) => void;
	addMessage: (message: MessageProps) => void;
	setSelectedCategory: (context: ChatState["selectedCategory"]) => void;
	getCategories(): Promise<void>;
	setChatTimeout: (timeout: number) => void;
	setIsChatVisible: (visible: boolean) => void;
	setIsInputVisible: (visible: boolean) => void;
	resetChatTimeout: () => void;
	handleSendMessage: () => void;
	addToHistory: (message: string) => void;
	navigateHistory: (direction: "up" | "down") => void;
	resetHistory: () => void;
	handleInputFocus: (payload: boolean | { open: boolean; categories: string[] }) => void;
	handleEscape: () => void;
	setHideChat(hideChat: ChatState["hideChat"]): void;
}

export const useChatStore = create<ChatState>((set, get) => ({
	text: "",
	messages: [],
	selectedCategory: null,
	chatTimeout: 5,
	isChatVisible: isEnvBrowser(),
	isInputVisible: isEnvBrowser(),
	history: {
		currentIndex: 0,
		messages: [],
	},
	hideChat: false,

	async getCategories() {
		const response = await fetchNui<string[]>({
			path: "getChatCategories",
			mockData: ["global", "OCC", "staff"],
		});

		if (!response) return;

		set((prevstate) => ({
			categories: response || [],
			selectedCategory: prevstate.selectedCategory
				? prevstate.selectedCategory
				: response[0],
		}));
	},

	setText: (text) => set({ text }),

	setMessages: (messages) => set({ messages }),

	addMessage: (message) => {
		set((state) => ({
			messages: [...state.messages, message],
			isChatVisible: true,
			chatTimeout: 5,
		}));
	},

	setSelectedCategory: (context) => set({ selectedCategory: context }),

	setChatTimeout: (timeout) => set({ chatTimeout: timeout }),

	setIsChatVisible: (visible) => set({ isChatVisible: visible }),

	setIsInputVisible: (visible) => set({ isInputVisible: visible }),

	resetChatTimeout: () => set({ chatTimeout: 5 }),
	categories: [],

	handleSendMessage: () => {
		const { text, selectedCategory: context, isInputVisible } = get();
		const inputElement = document.getElementById(
			"chat-input",
		) as HTMLInputElement;
		if (!isInputVisible) return;

		inputElement?.blur();

		if (text === "") {
			set({
				chatTimeout: 5,
				isInputVisible: false,
			});
			return fetchNui({ path: "setChatFocus", payload: false });
		}

		fetchNui({
			path: "sendChatMessage",
			payload: { message: text, context },
		});

		set({
			text: "",
			isInputVisible: false,
		});

		fetchNui({ path: "setChatFocus", payload: false });
	},

	addToHistory: (message) => {
		set((state) => ({
			history: {
				currentIndex: state.history.currentIndex + 1,
				messages: [...state.history.messages, message],
			},
		}));
	},

	navigateHistory: (direction) => {
		const { history } = get();

		if (history.messages.length === 0) return;

		if (direction === "up") {
			if (history.currentIndex === 0) return;

			set((state) => ({
				text: state.history.messages[state.history.currentIndex - 1],
				history: {
					...state.history,
					currentIndex: state.history.currentIndex - 1,
				},
			}));
		} else if (direction === "down") {
			if (history.currentIndex === history.messages.length) return;

			set((state) => ({
				text: state.history.messages[state.history.currentIndex + 1],
				history: {
					...state.history,
					currentIndex: state.history.currentIndex + 1,
				},
			}));
		}
	},

	resetHistory: () => {
		set((state) => ({
			history: {
				currentIndex: 0,
				messages: state.history.messages,
			},
		}));
	},

	handleInputFocus: (payload) => {
		const focused = typeof payload === "boolean" ? payload : payload?.open;
		const cats    = typeof payload === "object" && payload?.categories ? payload.categories : null;
		const { isInputVisible } = get();
		const inputElement = document.getElementById(
			"chat-input",
		) as HTMLInputElement;

		if (isInputVisible) return;

		const update: Partial<ChatState> = {
			isInputVisible: focused,
			isChatVisible: focused,
		};

		if (cats) {
			update.categories = cats;
			update.selectedCategory = cats[0] ?? null;
		}

		set(update);

		setTimeout(() => {
			inputElement?.focus();
		}, 0);
	},

	handleEscape: () => {
		set({
			isInputVisible: false,
			chatTimeout: 5,
			text: "",
		});

		get().resetHistory();

		const inputElement = document.getElementById(
			"chat-input",
		) as HTMLInputElement;
		inputElement?.blur();

		fetchNui({ path: "setChatFocus", payload: false });
	},

	setHideChat(hideChat) {
		set({ hideChat });
	},
}));
