import { useCallsStore } from "@app/stores/Calls";
import { useVisibilityStore } from "@app/stores/Visibility";
import { useShallow } from "zustand/shallow";
import { useClickSound } from "./useClickSound";
import { useNuiMessage } from "./useNuiMessage";

export const useLayout = () => {
	const { fetchHideFrame, setVisible } = useVisibilityStore(
		useShallow((state) => ({
			fetchHideFrame: state.fetchHideFrame,
			setVisible: state.setVisible,
		})),
	);

	const {
		setConfig,
		applyTheme,
		openPrompt,
		openPanel,
		openFeedback,
		openStaffMenu,
		closeSurface,
		setIncoming,
		setTickets,
		setTicketActive,
	} = useCallsStore(
		useShallow((s) => ({
			setConfig: s.setConfig,
			applyTheme: s.applyTheme,
			openPrompt: s.openPrompt,
			openPanel: s.openPanel,
			openFeedback: s.openFeedback,
			openStaffMenu: s.openStaffMenu,
			closeSurface: s.closeSurface,
			setIncoming: s.setIncoming,
			setTickets: s.setTickets,
			setTicketActive: s.setTicketActive,
		})),
	);

	useNuiMessage<boolean>("setVisible", setVisible);
	useNuiMessage("setConfig", (payload: any) => {
		setConfig(payload);
		if (payload?.theme) applyTheme(payload.theme);
	});

	useNuiMessage("openPrompt", openPrompt);
	useNuiMessage("openPanel", (payload: any) => openPanel(payload));
	useNuiMessage("openFeedback", (payload: any) => openFeedback(payload));
	useNuiMessage("openStaffMenu", (payload: any) => openStaffMenu(payload));
	useNuiMessage("closeSurface", closeSurface);

	useNuiMessage("incoming", (payload: any) => setIncoming(payload));
	useNuiMessage("hideIncoming", () => setIncoming(null));
	useNuiMessage("updateTickets", (payload: any) => setTickets(payload || []));
	useNuiMessage("ticketActive", (payload: any) => setTicketActive(payload));
	useNuiMessage("ticketEnded", () => setTicketActive(null));

	const closeWithFetch = () => {
		closeSurface();
		fetchHideFrame();
	};

	useClickSound();

	return { closeWithFetch };
};
