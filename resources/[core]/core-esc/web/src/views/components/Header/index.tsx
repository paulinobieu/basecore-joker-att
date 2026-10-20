import { BuyButton } from "./BuyButton";
import { CloseButton } from "./CloseButton";
import { Divider } from "./Divider";
import { Logo } from "./Logo";
import { PlayerInfo } from "./PlayerInfo";
import { PlayersStatus } from "./PlayersStatus";
import { SettingsButton } from "./SettingsButton";
import { SocialLinks } from "./SocialLinks";

export function Header() {
	return (
		<header
			className="flex min-h-[5rem] w-screen items-center justify-center border border-white/10 border-solid px-[1.875rem] bg-blend-screen"
			style={{
				background:
					"linear-gradient(0deg, rgba(24, 25, 28, 0.9), rgba(24, 25, 28, 0.9)),linear-gradient(72.04deg, rgba(255, 255, 255, 0) 65.25%, rgba(255, 255, 255, 0.12) 164.9%)",
			}}
		>
			<div className="flex h-full w-full max-w-[120rem] items-center">
				<Logo />
				<Divider />
				<PlayersStatus />
				<SocialLinks />
				<Divider />
				<PlayerInfo />
				<BuyButton />
				<SettingsButton />
				<CloseButton />
			</div>
		</header>
	);
}
