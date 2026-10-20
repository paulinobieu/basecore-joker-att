import BackgroundImage from "@views/assets/images/background.png";
import { cn } from "@app/utils";

export function Background() {
	return (
		<>
			<img
				src={BackgroundImage}
				className={cn(
					"fixed top-0 left-0 z-10 h-screen w-screen object-cover transition-all duration-500",
				)}
				alt="background"
			/>
			<div
				className="pointer-events-none fixed top-0 left-0 z-10 h-screen w-screen transition-all duration-500"
				style={{
					background:
						"radial-gradient(60% 45% at 50% 0%, rgba(var(--primaryColor), 0.22) 0%, rgba(var(--primaryColor), 0) 70%)," +
						"linear-gradient(0deg, rgba(var(--secondaryColor), 0.4) 0%, rgba(var(--secondaryColor), 0.12) 45%, rgba(var(--secondaryColor), 0) 100%)," +
						"linear-gradient(180deg, rgba(3, 8, 20, 0.55) 0%, rgba(3, 8, 20, 0.78) 100%)",
				}}
			/>
		</>
	);
}
