import { useTotemStore } from "@app/stores/Totem";
import { Admin } from "./Admin";
import { Customer } from "./Customer";

export function Totem() {
	const config = useTotemStore((state) => state.config);

	if (!config) return null;

	return config.isAdmin ? (
		<Admin config={config} />
	) : (
		<Customer config={config} />
	);
}
