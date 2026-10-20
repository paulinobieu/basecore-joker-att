import { useMenu } from "@app/stores/Menu";
import { MenuLifeIcon } from "@views/assets/icons/MenuHeart";
import { MenuHungryIcon } from "@views/assets/icons/MenuHungry";
import { MenuOxygenIcon } from "@views/assets/icons/MenuOxygen";
import { MenuShieldIcon } from "@views/assets/icons/MenuShield";
import { MenuStaminaIcon } from "@views/assets/icons/MenuStamina";
import { MenuStressIcon } from "@views/assets/icons/MenuStress";
import { MenuThirstIcon } from "@views/assets/icons/MenuThirst";
import LozengeSurvival from "@views/assets/images/lonzege-survival.webp";
import RoundedSurvival from "@views/assets/images/rounded-survival.webp";
import { useShallow } from "zustand/shallow";
import { Option } from "../Option";
import { Select } from "../Select";

export function Adjustments() {
    const { survival, survivalSettings, setSurvival } = useMenu(
        useShallow((state) => ({
            survival: state.survival,
            survivalSettings: state.survivalSettings,
            setSurvival: state.setSurvival,
        })),
    );

    return (
        <div className="flex w-full flex-col gap-1">
            <Option
                active={survivalSettings.life}
                icon={<MenuLifeIcon />}
                keyOption="life"
                title="Vida"
                tooltip="Esconde o seu status de vida"
            />
            <Option
                active={survivalSettings.shield}
                icon={<MenuShieldIcon />}
                keyOption="shield"
                title="Colete"
                tooltip="Esconde o seu status de colete"
            />
            <Option
                active={survivalSettings.hungry}
                icon={<MenuHungryIcon />}
                keyOption="hungry"
                title="Fome"
                tooltip="Esconde o seu status de fome"
            />
            <Option
                active={survivalSettings.thirst}
                icon={<MenuThirstIcon />}
                keyOption="thirst"
                title="Sede"
                tooltip="Esconde o seu status de sede"
            />
            <Option
                active={survivalSettings.stamina}
                icon={<MenuStaminaIcon />}
                keyOption="stamina"
                title="Stamina"
                tooltip="Esconde o seu status de stamina"
            />
            <Option
                active={survivalSettings.stress}
                icon={<MenuStressIcon />}
                keyOption="stress"
                title="Estresse"
                tooltip="Esconde o seu status de estresse"
            />
            <Option
                active={survivalSettings.oxygen}
                icon={<MenuOxygenIcon />}
                keyOption="oxygen"
                title="Oxigênio"
                tooltip="Esconde o seu status de oxigênio"
            />
            <Select
                selected={survival === "lonzege"}
                image={{
                    src: LozengeSurvival,
                    className:
                        "absolute right-[1.9375rem] w-[13.75rem] h-10 object-contain",
                }}
                onClick={() => setSurvival("lonzege")}
                title="Losango"
            />
            <Select
                selected={survival === "rounded"}
                image={{
                    src: RoundedSurvival,
                    className:
                        "absolute right-[1.9375rem] w-[13.75rem] h-10 object-contain",
                }}
                onClick={() => setSurvival("rounded")}
                title="Circular"
            />
        </div>
    );
}
