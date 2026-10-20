import { fetchNui } from "@app/utils/fetchNui";

export const creatorActions = {
	play: (command: string) => fetchNui({ path: "play", payload: { command } }),
	close: () => fetchNui({ path: "close" }),
	toggleMute: () => fetchNui({ path: "toggleMute" }),
	openCamera: () => fetchNui({ path: "openCamera" }),
	groupInvite: (sid: number) =>
		fetchNui({ path: "groupInvite", payload: { sid } }),
	groupRemove: (sid: number) =>
		fetchNui({ path: "groupRemove", payload: { sid } }),
	groupLeave: () => fetchNui({ path: "groupLeave" }),
	groupToggle: (enabled: boolean) =>
		fetchNui({ path: "groupToggle", payload: { enabled } }),
};
