import { fetchNui } from "@app/utils/fetchNui";
import {
  IconArrowBarToDown,
  IconArrowRight,
  IconBan,
  IconBolt,
  IconCar,
  IconCarCrash,
  IconHeartPlus,
  IconLocationShare,
  IconGhost2,
  IconMapSearch,
  IconShieldBolt,
  IconSpeakerphone,
  IconTool,
  IconUserCheck,
  IconUserMinus,
  IconUserX,
} from "@tabler/icons-react";
import type { Icon } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Field, Input, Search, Textarea } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Panel } from "@views/components/Panel";
import { Empty, Spinner } from "@views/components/State";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { useState } from "react";
import type { ReactNode } from "react";
import { CommandRow } from "./components/CommandRow";

type CommandCategory = "players" | "vehicles" | "server";

interface Command {
  id: string;
  category: CommandCategory;
  title: string;
  description: string;
  icon: Icon;
  control: ReactNode;
}

const DAY_OPTIONS = [7, 15, 21, 30];

const CATEGORIES: { value: CommandCategory; label: string }[] = [
  { value: "players", label: "Jogadores" },
  { value: "vehicles", label: "Veículos" },
  { value: "server", label: "Servidor" },
];

export function Commands() {
  const [activeCategory, setActiveCategory] = useState("all");
  const [query, setQuery] = useState("");

  const [teleportInput, setTeleportInput] = useState("");
  const [pullInput, setPullInput] = useState("");
  const [banInput, setBanInput] = useState("");
  const [cdsInput, setCdsInput] = useState("");
  const [removeWhitelistInput, setRemoveWhitelistInput] = useState("");
  const [addWhitelistInput, setAddWhitelistInput] = useState("");
  const [kickPlayerInput, setKickPlayerInput] = useState("");
  const [revivePlayerInput, setRevivePlayerInput] = useState("");

  const [modalAnnounceOpen, setModalAnnounceOpen] = useState(false);
  const [modalSetVehicleOpen, setModalSetVehicleOpen] = useState(false);

  const [announcementForm, setAnnouncementForm] = useState({
    title: "",
    message: "",
  });
  const [announcementLoading, setAnnouncementLoading] = useState(false);
  const [announcementResult, setAnnouncementResult] = useState<{
    success: boolean;
    message: string;
  } | null>(null);

  const [selectedDays, setSelectedDays] = useState(15);
  const [vehiclePlayerId, setVehiclePlayerId] = useState("");
  const [vehicleSpawn, setVehicleSpawn] = useState("");
  const [destroyLoading, setDestroyLoading] = useState(false);

  useNuiEvent<{ success: boolean; message: string }>(
    "announcementResult",
    (result) => {
      setAnnouncementResult(result);
      setAnnouncementLoading(false);
      if (result.success) {
        setModalAnnounceOpen(false);
        setAnnouncementForm({ title: "", message: "" });
      }
      setTimeout(() => setAnnouncementResult(null), 3000);
    }
  );

  const submitAction = async (
    event: string,
    value: string,
    payloadKey: string,
    reset: (value: string) => void
  ) => {
    if (!value.trim()) return;
    await fetchNui(event, { [payloadKey]: value.trim() });
    reset("");
  };

  const handleCreateAnnouncement = async () => {
    if (!announcementForm.title.trim() || !announcementForm.message.trim()) {
      setAnnouncementResult({
        success: false,
        message: "Título e mensagem são obrigatórios",
      });
      return;
    }
    setAnnouncementLoading(true);
    await fetchNui("createAnnouncement", announcementForm);
  };

  const handleDestroyVehicles = async () => {
    setDestroyLoading(true);
    await fetchNui("destroyAllVehicles");
    setTimeout(() => setDestroyLoading(false), 2000);
  };

  const submitIcon = (
    <IconArrowRight stroke={2} className="size-[.875rem] text-white" />
  );

  /** Campo de ID + botao de envio -- padrao repetido pelos comandos rapidos. */
  const idControl = (
    value: string,
    setValue: (value: string) => void,
    event: string,
    payloadKey: string,
    placeholder = "ID"
  ) => (
    <>
      <Input
        placeholder={placeholder}
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) =>
          e.key === "Enter" && submitAction(event, value, payloadKey, setValue)
        }
      />
      <Button
        variant="accent"
        icon={submitIcon}
        className="w-[2.25rem] px-0"
        onClick={() => submitAction(event, value, payloadKey, setValue)}
      />
    </>
  );

  const commands: Command[] = [
    {
      id: "remove-whitelist",
      category: "players",
      title: "Remover whitelist",
      description: "Remove a whitelist do jogador.",
      icon: IconUserMinus,
      control: idControl(
        removeWhitelistInput,
        setRemoveWhitelistInput,
        "removeWhitelist",
        "id"
      ),
    },
    {
      id: "add-whitelist",
      category: "players",
      title: "Liberar whitelist",
      description: "Libera a whitelist pelo ID da conta.",
      icon: IconUserCheck,
      control: idControl(
        addWhitelistInput,
        setAddWhitelistInput,
        "addWhitelist",
        "id"
      ),
    },
    {
      id: "kick",
      category: "players",
      title: "Expulsar jogador",
      description: "Expulsa o jogador da cidade.",
      icon: IconUserX,
      control: idControl(
        kickPlayerInput,
        setKickPlayerInput,
        "kickPlayer",
        "id"
      ),
    },
    {
      id: "ban",
      category: "players",
      title: "Banir jogador",
      description: "Bane o jogador da cidade.",
      icon: IconBan,
      control: idControl(banInput, setBanInput, "banPlayer", "playerId"),
    },
    {
      id: "revive",
      category: "players",
      title: "Reviver jogador",
      description: "Revive o jogador caído.",
      icon: IconHeartPlus,
      control: idControl(
        revivePlayerInput,
        setRevivePlayerInput,
        "revivePlayer",
        "id"
      ),
    },
    {
      id: "teleport",
      category: "players",
      title: "Teleportar",
      description: "Leva você até o jogador.",
      icon: IconLocationShare,
      control: idControl(
        teleportInput,
        setTeleportInput,
        "teleportPlayer",
        "playerId"
      ),
    },
    {
      id: "pull",
      category: "players",
      title: "Trazer jogador",
      description: "Traz o jogador até você.",
      icon: IconArrowBarToDown,
      control: idControl(pullInput, setPullInput, "pullPlayer", "playerId"),
    },
    {
      id: "set-vehicle",
      category: "vehicles",
      title: "Setar carro",
      description: "Entrega um veículo para o jogador.",
      icon: IconCar,
      control: (
        <Button
          variant="accent"
          className="w-full"
          onClick={() => setModalSetVehicleOpen(true)}
        >
          Setar
        </Button>
      ),
    },
    {
      id: "fix-tuning",
      category: "vehicles",
      title: "Fix & tunning",
      description: "Repara ou tuna o veículo em que você está.",
      icon: IconTool,
      control: (
        <>
          <Button
            variant="ghost"
            className="flex-1"
            onClick={() => fetchNui("fixVehicle")}
          >
            Fix
          </Button>
          <Button
            variant="accent"
            className="flex-1"
            onClick={() => fetchNui("tuningVehicle")}
          >
            Tunning
          </Button>
        </>
      ),
    },
    {
      id: "destroy-vehicles",
      category: "vehicles",
      title: "Destruir veículos",
      description: "Apaga todos os veículos spawnados.",
      icon: IconCarCrash,
      control: (
        <Button
          variant="danger"
          className="w-full"
          disabled={destroyLoading}
          icon={destroyLoading ? <Spinner className="size-[.75rem]" /> : undefined}
          onClick={handleDestroyVehicles}
        >
          {destroyLoading ? "Destruindo" : "Destruir"}
        </Button>
      ),
    },
    {
      id: "announce",
      category: "server",
      title: "Criar anúncio",
      description: "Envia um anúncio para a cidade toda.",
      icon: IconSpeakerphone,
      control: (
        <Button
          variant="accent"
          className="w-full"
          onClick={() => setModalAnnounceOpen(true)}
        >
          Criar
        </Button>
      ),
    },
    {
      id: "teleport-cds",
      category: "server",
      title: "Teleporte CDS",
      description: "Teleporta para uma coordenada CDS.",
      icon: IconMapSearch,
      control: idControl(cdsInput, setCdsInput, "teleportCDS", "cds", "CDS"),
    },
    {
      id: "noclip",
      category: "server",
      title: "Noclip",
      description: "Liga e desliga o noclip para você.",
      icon: IconGhost2,
      control: (
        <Button
          variant="ghost"
          className="w-full"
          onClick={() => fetchNui("toggleNoclip")}
        >
          Alternar
        </Button>
      ),
    },
    {
      id: "godmode",
      category: "server",
      title: "Modo god",
      description: "Deixa você invencível até desligar.",
      icon: IconShieldBolt,
      control: (
        <Button
          variant="ghost"
          className="w-full"
          onClick={() => fetchNui("toggleGodMode")}
        >
          Alternar
        </Button>
      ),
    },
  ];

  const term = query.trim().toLowerCase();

  const matches = commands.filter(
    (command) =>
      !term ||
      command.title.toLowerCase().includes(term) ||
      command.description.toLowerCase().includes(term)
  );

  const visible = matches.filter((command) =>
    activeCategory === "all" ? true : command.category === activeCategory
  );

  const tabs = [
    { value: "all", label: "Todos", count: matches.length },
    ...CATEGORIES.map((category) => ({
      value: category.value,
      label: category.label,
      count: matches.filter((command) => command.category === category.value)
        .length,
    })),
  ];

  const sections = CATEGORIES.filter(
    (category) => activeCategory === "all" || category.value === activeCategory
  )
    .map((category) => ({
      ...category,
      items: visible.filter((command) => command.category === category.value),
    }))
    .filter((section) => section.items.length > 0);

  /** Com uma categoria só o painel ocupa a largura toda: duas colunas de linhas. */
  const twoColumns = sections.length === 1;

  /**
   * Duas colunas de painéis: a categoria mais longa fica sozinha à esquerda e
   * as demais empilham à direita, cada painel com altura proporcional ao
   * número de comandos -- assim nenhuma coluna sobra vazia.
   */
  const columns =
    sections.length > 1 ? [sections.slice(0, 1), sections.slice(1)] : [sections];

  return (
    <>
      <Page>
        <Toolbar>
          <Search
            value={query}
            placeholder="Buscar comando"
            onChange={(e) => setQuery(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={tabs}
            value={activeCategory}
            onChange={setActiveCategory}
          />
          <ToolbarDivider />
          <ToolbarCount value={visible.length} label="comandos" />
        </Toolbar>

        {visible.length === 0 ? (
          <div className="surface-panel flex flex-1 items-center justify-center rounded-[.3125rem] border border-white/[.04] border-solid">
            <Empty
              icon={IconBolt}
              label="Nenhum comando encontrado"
              hint="Tente outro termo de busca"
            />
          </div>
        ) : (
          <div className="flex flex-1 gap-[.9375rem] overflow-hidden">
            {columns.map((column, index) => (
              <div
                key={index}
                className="flex h-full flex-1 flex-col gap-[.9375rem]"
              >
                {column.map((section) => (
                  <Panel
                    key={section.value}
                    title={section.label}
                    className="min-h-0"
                    style={{ flexGrow: section.items.length, flexBasis: 0 }}
                    bodyClassName="customScrollbar flex flex-col overflow-y-auto"
                    action={
                      <span className="font-black text-[.6875rem] text-white/45">
                        {section.items.length}
                      </span>
                    }
                  >
                    <div
                      className={
                        twoColumns
                          ? "grid h-full auto-rows-fr grid-cols-2 gap-x-[.9375rem]"
                          : "flex h-full flex-col"
                      }
                    >
                      {section.items.map((command) => (
                        <CommandRow
                          key={command.id}
                          title={command.title}
                          description={command.description}
                          icon={command.icon}
                        >
                          {command.control}
                        </CommandRow>
                      ))}
                    </div>
                  </Panel>
                ))}
              </div>
            ))}
          </div>
        )}
      </Page>

      <Modal
        visible={modalAnnounceOpen}
        icon={IconSpeakerphone}
        title="Criar anúncio"
        loading={announcementLoading}
        footerLabels={{ cancel: "Cancelar", confirm: "Enviar" }}
        onClose={() => {
          setModalAnnounceOpen(false);
          setAnnouncementForm({ title: "", message: "" });
          setAnnouncementResult(null);
        }}
        onConfirm={handleCreateAnnouncement}
      >
        {announcementResult && (
          <p
            className={`rounded-[.25rem] border border-solid px-3 py-2 text-center font-black text-[.6875rem] uppercase ${
              announcementResult.success
                ? "border-[#9CF35B]/30 text-[#9CF35B]"
                : "border-[#FF4B4B]/30 text-[#FF4B4B]"
            }`}
          >
            {announcementResult.message}
          </p>
        )}
        <Field label="Título">
          <Input
            placeholder="EX: Evento"
            value={announcementForm.title}
            onChange={(e) =>
              setAnnouncementForm((prev) => ({
                ...prev,
                title: e.target.value,
              }))
            }
          />
        </Field>
        <Field label="Mensagem">
          <Textarea
            rows={4}
            placeholder="EX: Ocorrerá às 19:30 do dia 23/09"
            value={announcementForm.message}
            onChange={(e) =>
              setAnnouncementForm((prev) => ({
                ...prev,
                message: e.target.value,
              }))
            }
          />
        </Field>
      </Modal>

      <Modal
        visible={modalSetVehicleOpen}
        icon={IconCar}
        title="Setar veículo"
        footerLabels={{ cancel: "Cancelar", confirm: "Setar" }}
        onClose={() => setModalSetVehicleOpen(false)}
        onConfirm={() => {
          if (!vehiclePlayerId || !vehicleSpawn) return;
          fetchNui("addVehicleToUser", {
            vehicle: { spawn: vehicleSpawn },
            userId: Number.parseInt(vehiclePlayerId),
            duration: selectedDays,
          });
          setModalSetVehicleOpen(false);
          setVehiclePlayerId("");
          setVehicleSpawn("");
        }}
      >
        <Field label="ID do jogador">
          <Input
            placeholder="EX: 0"
            value={vehiclePlayerId}
            onChange={(e) => setVehiclePlayerId(e.target.value)}
          />
        </Field>
        <Field label="Spawn do veículo">
          <Input
            placeholder="EX: kuruma"
            value={vehicleSpawn}
            onChange={(e) => setVehicleSpawn(e.target.value)}
          />
        </Field>
        <Field label="Duração">
          <div className="flex items-center gap-2">
            {DAY_OPTIONS.map((option) => (
              <Button
                key={option}
                variant="ghost"
                className="flex-1"
                active={selectedDays === option}
                onClick={() => setSelectedDays(option)}
              >
                {option} dias
              </Button>
            ))}
          </div>
        </Field>
      </Modal>
    </>
  );
}
