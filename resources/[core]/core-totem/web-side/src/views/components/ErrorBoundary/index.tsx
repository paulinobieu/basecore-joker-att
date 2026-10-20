import { Component, type ErrorInfo, type ReactNode } from "react";

interface Props {
	children: ReactNode;
}

interface State {
	hasError: boolean;
}

export class ErrorBoundary extends Component<Props, State> {
	state: State = { hasError: false };

	static getDerivedStateFromError(): State {
		return { hasError: true };
	}

	componentDidCatch(error: Error, info: ErrorInfo) {
		console.error("[core-totem] Interface render failed", error, info);
	}

	render() {
		if (this.state.hasError) {
			return (
				<div className="fixed left-8 top-1/2 w-[27.5rem] -translate-y-1/2 rounded-lg border border-white/10 bg-[#111114] p-6 text-white">
					<p className="font-black uppercase">Não foi possível abrir o totem</p>
					<p className="mt-2 text-sm text-white/50">
						Feche a interface e tente novamente.
					</p>
				</div>
			);
		}

		return this.props.children;
	}
}
