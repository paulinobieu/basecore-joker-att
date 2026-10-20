import type { DoorColumn, DoorFormState } from "@app/stores/DoorStore";

export const convertData = (data: DoorColumn): DoorFormState => {
	let newGroupsData: { name: string; grade: number }[] = [];
	if (data.groups) {
		const doorGroupsData = Object.entries(data.groups);
		for (let i = 0; i < doorGroupsData.length; i++) {
			const groupObj = doorGroupsData[i];
			newGroupsData[i] = { name: groupObj[0], grade: groupObj[1] };
		}
	}
	return {
		...data,
		characters: data.characters || [""],
		groups:
			newGroupsData.length > 0
				? [...newGroupsData]
				: [{ name: "", grade: undefined }],
		items: data.items || [{ name: "", metadata: "", remove: false }],
		lockpickDifficulty: data.lockpickDifficulty || [""],
	} as DoorFormState;
};
