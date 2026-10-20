import { Component, type ReactNode } from "react";

interface Props {
	children: ReactNode;
}

interface State {
	hasError: boolean;
	error: string | null;
}

export class ErrorBoundary extends Component<Props, State> {
	constructor(props: Props) {
		super(props);
		this.state = { hasError: false, error: null };
	}

	static getDerivedStateFromError(error: Error) {
		return { hasError: true, error: error.message };
	}

	render() {
		if (this.state.hasError) {
			return (
				<div className="flex flex-col items-center gap-2 bg-black border border-white/30 border-solid rounded-md p-6">
					<h1 className="font-bold text-2xl text-white">
						Ocorreu um erro, contate o desenvolvedor
					</h1>
					<textarea
						className="w-1/2 resize-none rounded-md border border-white/10 border-solid bg-white/5 px-4 py-4 font-extralight text-rose-500 text-xs"
						value={JSON.stringify(this.state.error || "{}")}
						readOnly
					/>
				</div>
			);
		}
		return this.props.children;
	}
}
