import * as React from "react";

interface ErrorBoundaryProps {
	children: React.ReactNode;
	fallback?: React.ReactNode;
}

export class ErrorBoundary extends React.Component<
	ErrorBoundaryProps,
	{ hasError: boolean; error?: string }
> {
	constructor(props: ErrorBoundaryProps) {
		super(props);
		this.state = { hasError: false };
	}

	static getDerivedStateFromError(error: Error) {
		return { hasError: true, error: error.message };
	}

	render() {
		if (this.state.hasError) {
			return (
				<div className="not-found">
					<h1 style={{ fontSize: "1.1rem", marginBottom: "0.5rem" }}>
						Ocorreu um erro ao carregar o painel.
					</h1>
					<p style={{ fontSize: "0.75rem", opacity: 0.65 }}>
						{this.state.error}
					</p>
				</div>
			);
		}
		return this.props.children;
	}
}
