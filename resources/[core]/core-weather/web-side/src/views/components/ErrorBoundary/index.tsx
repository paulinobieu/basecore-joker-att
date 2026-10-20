import * as React from "react";

interface ErrorBoundaryProps {
	children: React.ReactNode;
	fallback?: React.ReactNode;
}

export class ErrorBoundary extends React.Component<
	ErrorBoundaryProps,
	{ hasError: boolean; error?: Error }
> {
	constructor(props: ErrorBoundaryProps) {
		super(props);
		this.state = { hasError: false };
	}

	static getDerivedStateFromError(_error: Error) {
		return { hasError: true, error: _error.message };
	}

	render() {
		if (this.state.hasError) {
			return (
				<div className="error-boundary">
					<h1>Ocorreu um erro, contate o desenvolvedor</h1>
					<textarea
						value={JSON.stringify(this.state.error || "{}")}
						readOnly
					/>
				</div>
			);
		}

		return this.props.children;
	}
}
