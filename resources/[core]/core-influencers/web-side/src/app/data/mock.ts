import type { CreatorData } from "@app/stores/CreatorStore";

export const MOCK_DATA: CreatorData = {
	order: ["Danças", "Poses", "Selfies", "Casais", "Props"],
	groups: {
		Danças: [
			{ label: "APT (Rosé)", command: "apt", music: true },
			{ label: "Blackpink Jump", command: "bpjump", music: true },
			{ label: "Mamushi", command: "mamushi", music: true },
			{ label: "Squid Dance", command: "squiddance", music: true },
			{ label: "Crazy Frog", command: "crazyfrog", music: true },
		],
		Poses: [
			{ label: "Pose Modelo 1", command: "model1" },
			{ label: "Pose Modelo 2", command: "model2" },
			{ label: "Braços Cruzados", command: "crossarms" },
			{ label: "Sentado Cute", command: "sitcute" },
		],
		Selfies: [
			{ label: "Selfie Espelho", command: "mirror", sync: true },
			{ label: "Selfie Chão", command: "floorselfie" },
			{ label: "Selfie Peace", command: "peace" },
		],
		Casais: [
			{ label: "Casal 01", command: "couple1", sync: true },
			{ label: "Casal Abraço", command: "couplehug", sync: true },
			{ label: "Casal Beijo", command: "couplekiss", sync: true, music: true },
		],
		Props: [
			{ label: "Segurar Buquê", command: "flowers" },
			{ label: "Skate", command: "skate" },
			{ label: "Guitarra", command: "guitar", music: true },
		],
	},
	group: {
		owner: null,
		members: [],
		enabled: false,
		isOwner: false,
	},
	muted: false,
};
