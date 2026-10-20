import { useCreatorStore } from "@app/stores/CreatorStore";
import { cn } from "@app/utils";

const ASPECTS = ["1:1", "4:3", "3:4", "16:9", "9:16"];

interface KeyItemProps {
	id: string;
	label: string;
	small?: string;
	main?: boolean;
	active?: boolean;
}

function KeyItem({ label, small, main, active }: KeyItemProps) {
	return (
		<div className={cn("camKeyItem", main && "main", active && "active")}>
			<b>{label}</b>
			<small>{small}</small>
		</div>
	);
}

export function CameraOverlay() {
	const camera = useCreatorStore((state) => state.camera);

	const {
		open,
		aspect,
		mode,
		zoom,
		light,
		dof,
		grid,
		faceTrack,
		cleanCapture,
		keys,
	} = camera;

	const keyActive = (key: string) => {
		if (key === "flash") return light;
		if (key === "dof") return dof;
		if (key === "grid") return grid;
		if (key === "faceTrack") return faceTrack;
		if (key === "enter") return cleanCapture || keys?.enter === true;
		return keys?.[key] === true;
	};

	return (
		<div
			className={cn(
				"cameraOverlay",
				!open && "hidden",
				light && "isLightOn",
				dof && "isDofOn",
				!grid && "isGridOff",
				faceTrack && "isFaceTrackOn",
				cleanCapture && "isCleanCapture",
				mode === "selfie" && "isSelfie",
			)}
			data-aspect={aspect}
			data-mode={mode}
		>
			<div className="camFormatMask">
				<div className="camShade camShadeTop" />
				<div className="camShade camShadeBottom" />
				<div className="camShade camShadeLeft" />
				<div className="camShade camShadeRight" />
			</div>

			<div className="camSafeFrame" />
			<div className="camGridLine camGridV v1" />
			<div className="camGridLine camGridV v2" />
			<div className="camGridLine camGridH h1" />
			<div className="camGridLine camGridH h2" />

			<div className="camTopHud">
				<div className="camPill camBrand">
					<span className="camDot" />
					<span>{mode === "selfie" ? "SELFIE" : "TRASEIRA"}</span>
				</div>

				<div className="camAspectList">
					{ASPECTS.map((a) => (
						<span key={a} className={cn(a === aspect && "active")}>
							{a}
						</span>
					))}
				</div>

				<div className="camPill camZoom">{zoom}</div>
			</div>

			<div className="camFocusMark">
				<span />
				<span />
				<span />
				<span />
			</div>

			<div className="camCreatorControls">
				<KeyItem id="flash" label="F" small="flash" active={keyActive("flash")} />
				<KeyItem id="dof" label="H" small="DOF" active={keyActive("dof")} />
				<KeyItem
					id="rotate"
					label="Q/E"
					small="rotacionar"
					active={keyActive("rotate")}
				/>
				<KeyItem id="enter" label="ENTER" main active={keyActive("enter")} />
				<KeyItem
					id="aspect"
					label="C"
					small="formato"
					active={keyActive("aspect")}
				/>
				<KeyItem id="tab" label="TAB" small="câmera" active={keyActive("tab")} />
				<KeyItem id="grid" label="V" small="grid" active={keyActive("grid")} />
			</div>

			<div className="camCreatorSubControls">
				<div className={cn("camSubKey", keyActive("zoom") && "active")}>
					<b>SCROLL</b>
					<small>zoom</small>
				</div>
				<div className={cn("camSubKey", keyActive("faceTrack") && "active")}>
					<b>M</b>
					<small>face tracking</small>
				</div>
				<div className={cn("camSubKey", keyActive("exit") && "active")}>
					<b>K</b>
					<small>sair</small>
				</div>
			</div>
		</div>
	);
}
