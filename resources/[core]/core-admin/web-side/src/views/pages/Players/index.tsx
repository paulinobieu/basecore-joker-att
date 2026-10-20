import { usePlayersRefresh } from "@app/hooks/useAutoRefresh";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { fetchNui } from "@app/utils/fetchNui";
import {
  IconAdjustments,
  IconArrowBarToDown,
  IconArrowLeft,
  IconBan,
  IconBriefcase,
  IconBuildingEstate,
  IconCake,
  IconCar,
  IconCash,
  IconCoin,
  IconDots,
  IconEye,
  IconFlag,
  IconGenderBigender,
  IconId,
  IconLocationShare,
  IconLock,
  IconPackage,
  IconPhone,
  IconShieldBolt,
  IconShieldHalfFilled,
  IconSkull,
  IconTool,
  IconUser,
  IconUserMinus,
  IconUsersGroup,
  IconUserX,
} from "@tabler/icons-react";
import type { Icon } from "@tabler/icons-react";
import { Avatar } from "@views/components/Avatar";
import { Badge, StatusBadge } from "@views/components/Badge";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Field, Input, Search } from "@views/components/Field";
import { KeyValue } from "@views/components/KeyValue";
import { Meter } from "@views/components/Meter";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Panel } from "@views/components/Panel";
import { Empty } from "@views/components/State";
import { Cell, CellStack, Row, Table } from "@views/components/Table";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useEffect, useState } from "react";

interface Player {
  id: number;
  name: string;
  profession: string;
  passport: string;
  vip: string;
  status: "Online" | "Offline";
  professionColor: string;
  vipColor: string;
  online: boolean;
}

interface PlayerVehicle {
  spawn: string;
  name: string;
  image: string;
  plate: string;
  color?: string;
}

interface PlayerItem {
  name: string;
  image: string;
  quantity: number;
  weight?: number;
  type?: string;
}

interface PlayerProperty {
  name: string;
  type?: string;
}

interface PlayerDetails {
  id?: number | string;
  name?: string;
  age?: number;
  gender?: string;
  phone?: string;
  nationality?: string;
  bank?: number;
  arrested?: string;
  stats?: { health: number; hunger: number; thirst: number; armour: number };
  vehicles?: PlayerVehicle[];
  items?: PlayerItem[];
  properties?: PlayerProperty[];
}

interface PlayerAction {
  name: string;
  icon: Icon;
  danger?: boolean;
  onClick: (playerId: number) => void;
}

const FALLBACK_IMAGE =
  "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+Cjx0ZXh0IHg9IjUwIiB5PSI1NSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjQwIiBmaWxsPSIjZmZmZmZmIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4/PC90ZXh0Pgo8L3N2Zz4K";

const STATUS_TABS = [
  { value: "all", label: "Todos" },
  { value: "online", label: "Online" },
  { value: "offline", label: "Offline" },
];

export function Players() {
  const [players, setPlayers] = useState<Player[]>([]);
  const [playerDetails, setPlayerDetails] = useState<PlayerDetails | null>(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [selectedPlayer, setSelectedPlayer] = useState<number | null>(null);
  const [actionsFor, setActionsFor] = useState<Player | null>(null);
  const [detailTab, setDetailTab] = useState("items");

  const [modalSetVehicleOpen, setModalSetVehicleOpen] = useState(false);
  const [modalSendItemOpen, setModalSendItemOpen] = useState(false);
  const [modalGiveMoneyOpen, setModalGiveMoneyOpen] = useState(false);

  const [selectedDays, setSelectedDays] = useState(15);
  const [vehiclePlayerId, setVehiclePlayerId] = useState("");
  const [vehicleSpawn, setVehicleSpawn] = useState("");
  const [itemPlayerId, setItemPlayerId] = useState("");
  const [itemSpawn, setItemSpawn] = useState("");
  const [itemQuantity, setItemQuantity] = useState("1");
  const [moneyPlayerId, setMoneyPlayerId] = useState("");
  const [moneyAmount, setMoneyAmount] = useState("");

  usePlayersRefresh();

  useNuiEvent<Player[]>("receivePlayers", setPlayers);
  useNuiEvent<PlayerDetails>("receivePlayerDetails", setPlayerDetails);

  useEffect(() => {
    const timeoutId = setTimeout(() => {
      fetchNui("getPlayers", searchTerm.trim());
    }, 500);
    return () => clearTimeout(timeoutId);
  }, [searchTerm]);

  const openDetails = (playerId: number) => {
    setActionsFor(null);
    setDetailTab("items");
    setSelectedPlayer(playerId);
    fetchNui("getPlayerDetails", playerId);
  };

  const closeDetails = () => {
    setSelectedPlayer(null);
    setPlayerDetails(null);
  };

  const actionGroups: { title: string; actions: PlayerAction[] }[] = [
    {
      title: "Movimentação",
      actions: [
        {
          name: "Espectar",
          icon: IconEye,
          onClick: (playerId) => fetchNui("spectatePlayer", { playerId }),
        },
        {
          name: "Teleportar",
          icon: IconLocationShare,
          onClick: (playerId) => fetchNui("teleportPlayer", { playerId }),
        },
        {
          name: "Puxar",
          icon: IconArrowBarToDown,
          onClick: (playerId) => fetchNui("pullPlayer", { playerId }),
        },
      ],
    },
    {
      title: "Estado",
      actions: [
        {
          name: "God",
          icon: IconShieldBolt,
          onClick: (playerId) => fetchNui("godPlayer", { playerId }),
        },
        {
          name: "Colete",
          icon: IconShieldHalfFilled,
          onClick: (playerId) => fetchNui("armorPlayer", { playerId }),
        },
        {
          name: "Matar",
          icon: IconSkull,
          danger: true,
          onClick: (playerId) => fetchNui("killPlayer", { playerId }),
        },
      ],
    },
    {
      title: "Recursos",
      actions: [
        {
          name: "Enviar item",
          icon: IconBriefcase,
          onClick: (playerId) => {
            setItemPlayerId(String(playerId));
            setModalSendItemOpen(true);
          },
        },
        {
          name: "Dinheiro",
          icon: IconCoin,
          onClick: (playerId) => {
            setMoneyPlayerId(String(playerId));
            setModalGiveMoneyOpen(true);
          },
        },
        {
          name: "Setar veículo",
          icon: IconCar,
          onClick: (playerId) => {
            setVehiclePlayerId(String(playerId));
            setModalSetVehicleOpen(true);
          },
        },
        {
          name: "Fix",
          icon: IconTool,
          onClick: (playerId) => fetchNui("fixPlayerVehicle", { playerId }),
        },
        {
          name: "Tunning",
          icon: IconAdjustments,
          onClick: (playerId) => fetchNui("tunePlayerVehicle", { playerId }),
        },
        {
          name: "Ver inventário",
          icon: IconPackage,
          onClick: openDetails,
        },
      ],
    },
    {
      title: "Moderação",
      actions: [
        {
          name: "Remover WL",
          icon: IconUserMinus,
          danger: true,
          onClick: (playerId) => fetchNui("removePlayerWhitelist", { playerId }),
        },
        {
          name: "Expulsar",
          icon: IconUserX,
          danger: true,
          onClick: (playerId) => fetchNui("kickPlayer", { playerId }),
        },
        {
          name: "Banir",
          icon: IconBan,
          danger: true,
          onClick: (playerId) => fetchNui("banPlayer", { playerId }),
        },
      ],
    },
  ];

  const player = players.find((item) => item.id === selectedPlayer) || null;
  const vehicles = playerDetails?.vehicles || [];
  const items = playerDetails?.items || [];
  const properties = playerDetails?.properties || [];

  const filteredPlayers = players.filter((item) =>
    statusFilter === "all"
      ? true
      : statusFilter === "online"
      ? item.status === "Online"
      : item.status !== "Online"
  );

  const statusTabs = STATUS_TABS.map((tab) => ({
    ...tab,
    count:
      tab.value === "all"
        ? players.length
        : players.filter((item) =>
            tab.value === "online"
              ? item.status === "Online"
              : item.status !== "Online"
          ).length,
  }));

  const detailTabs = [
    { value: "items", label: "Inventário", count: items.length },
    { value: "vehicles", label: "Veículos", count: vehicles.length },
    { value: "properties", label: "Propriedades", count: properties.length },
  ];

  const modals = (
    <>
      <Modal
        visible={!!actionsFor}
        icon={IconDots}
        width="32rem"
        hideFooter
        title={`Ações · ${actionsFor?.name || ""}`}
        onClose={() => setActionsFor(null)}
      >
        <div className="flex flex-col gap-3">
          {actionGroups.map((group) => (
            <div key={group.title}>
              <span className="mb-1.5 block font-black text-[.625rem] text-white/35 uppercase">
                {group.title}
              </span>
              <div className="grid grid-cols-3 gap-1.5">
                {group.actions.map((action) => (
                  <Button
                    key={action.name}
                    size="sm"
                    variant={action.danger ? "danger" : "ghost"}
                    className="justify-start"
                    icon={
                      <action.icon
                        stroke={2}
                        className="size-[.8125rem] text-white"
                      />
                    }
                    onClick={() => {
                      if (!actionsFor) return;
                      action.onClick(actionsFor.id);
                      setActionsFor(null);
                    }}
                  >
                    {action.name}
                  </Button>
                ))}
              </div>
            </div>
          ))}
        </div>
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
            {[7, 15, 21, 30].map((option) => (
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

      <Modal
        visible={modalGiveMoneyOpen}
        icon={IconCoin}
        title="Dar dinheiro"
        footerLabels={{ cancel: "Cancelar", confirm: "Enviar" }}
        onClose={() => setModalGiveMoneyOpen(false)}
        onConfirm={() => {
          if (!moneyPlayerId || !moneyAmount) return;
          fetchNui("giveMoneyToPlayer", {
            playerId: Number.parseInt(moneyPlayerId),
            amount: Number.parseInt(moneyAmount),
          });
          setModalGiveMoneyOpen(false);
          setMoneyPlayerId("");
          setMoneyAmount("");
        }}
      >
        <Field label="ID do jogador">
          <Input
            placeholder="EX: 0"
            value={moneyPlayerId}
            onChange={(e) => setMoneyPlayerId(e.target.value)}
          />
        </Field>
        <Field label="Quantia">
          <Input
            type="number"
            min={1}
            placeholder="EX: 50000"
            value={moneyAmount}
            onChange={(e) => setMoneyAmount(e.target.value)}
          />
        </Field>
      </Modal>

      <Modal
        visible={modalSendItemOpen}
        icon={IconBriefcase}
        title="Enviar item"
        footerLabels={{ cancel: "Cancelar", confirm: "Enviar" }}
        onClose={() => setModalSendItemOpen(false)}
        onConfirm={() => {
          if (!itemPlayerId || !itemSpawn) return;
          fetchNui("sendItemToPlayer", {
            playerId: Number.parseInt(itemPlayerId),
            item: itemSpawn,
            quantity: Number.parseInt(itemQuantity) || 1,
          });
          setModalSendItemOpen(false);
          setItemPlayerId("");
          setItemSpawn("");
          setItemQuantity("1");
        }}
      >
        <Field label="ID do jogador">
          <Input
            placeholder="EX: 0"
            value={itemPlayerId}
            onChange={(e) => setItemPlayerId(e.target.value)}
          />
        </Field>
        <Field label="Spawn do item">
          <Input
            placeholder="EX: weapon_assaultrifle_mk2"
            value={itemSpawn}
            onChange={(e) => setItemSpawn(e.target.value)}
          />
        </Field>
        <Field label="Quantidade">
          <Input
            type="number"
            min={1}
            value={itemQuantity}
            onChange={(e) => setItemQuantity(e.target.value)}
          />
        </Field>
      </Modal>
    </>
  );

  if (selectedPlayer) {
    const displayName = playerDetails?.name || player?.name || "---";
    const stats = playerDetails?.stats;

    return (
      <>
        <Page>
          <Toolbar className="h-[2.75rem]">
            <Button
              variant="ghost"
              className="w-[9rem] justify-start"
              icon={
                <IconArrowLeft stroke={2} className="size-[.875rem] text-white" />
              }
              onClick={closeDetails}
            >
              Voltar
            </Button>

            <ToolbarDivider />

            <Avatar name={displayName} online={player?.online} />
            <div className="flex min-w-0 flex-col">
              <span className="truncate font-black text-[.875rem] text-white uppercase">
                {displayName}
              </span>
              <span className="font-semibold text-[.625rem] text-white/30">
                Passaporte #{playerDetails?.id ?? player?.passport ?? "---"}
              </span>
            </div>

            <div className="ml-2 flex items-center gap-1.5">
              {player && (
                <Badge color={player.professionColor || "#C7C7C7"}>
                  {player.profession}
                </Badge>
              )}
              {player && (
                <Badge color={player.vipColor || "#C7C7C7"}>{player.vip}</Badge>
              )}
            </div>

            <div className="ml-auto flex items-center gap-[.625rem]">
              {player && <StatusBadge online={player.status === "Online"} />}
              <Button
                variant="accent"
                className="w-[9rem]"
                icon={<IconDots stroke={2} className="size-[.875rem] text-white" />}
                onClick={() => player && setActionsFor(player)}
              >
                Ações
              </Button>
            </div>
          </Toolbar>

          <div className="flex flex-1 gap-[.9375rem] overflow-hidden">
            <div className="flex h-full w-[21rem] flex-shrink-0 flex-col gap-[.9375rem]">
              <Panel
                title="Ficha do jogador"
                className="flex-1"
                bodyClassName="customScrollbar overflow-y-auto px-[.875rem] py-[.5rem]"
              >
                <KeyValue label="Nome" icon={IconUser}>
                  {displayName.split(" ")[0]}
                </KeyValue>
                <KeyValue label="Idade" icon={IconCake}>
                  {playerDetails?.age ?? 25} anos
                </KeyValue>
                <KeyValue label="Gênero" icon={IconGenderBigender}>
                  {playerDetails?.gender || "Masculino"}
                </KeyValue>
                <KeyValue label="Telefone" icon={IconPhone}>
                  {playerDetails?.phone || "---"}
                </KeyValue>
                <KeyValue label="Nacionalidade" icon={IconFlag}>
                  {playerDetails?.nationality || "Brasil"}
                </KeyValue>
                <KeyValue label="Passaporte" icon={IconId}>
                  {playerDetails?.id ?? player?.passport ?? "---"}
                </KeyValue>
                <KeyValue label="Banco" icon={IconCash}>
                  ${(playerDetails?.bank ?? 0).toLocaleString()}
                </KeyValue>
                <KeyValue label="Situação" icon={IconLock}>
                  {playerDetails?.arrested || "Livre"}
                </KeyValue>
              </Panel>

              <Panel
                title="Condição"
                className="h-[9.5rem] flex-shrink-0"
                bodyClassName="flex flex-col justify-center gap-[.625rem] px-[.875rem]"
              >
                <Meter
                  label="Saúde"
                  color="#FF4B4B"
                  value={stats?.health ?? 0}
                  suffix={`${stats?.health ?? 0}%`}
                />
                <Meter
                  label="Colete"
                  color="#8B5CF6"
                  value={stats?.armour ?? 0}
                  suffix={`${stats?.armour ?? 0}%`}
                />
                <Meter
                  label="Fome"
                  color="#FFB951"
                  value={stats?.hunger ?? 0}
                  suffix={`${stats?.hunger ?? 0}%`}
                />
                <Meter
                  label="Sede"
                  color="#3C8EDC"
                  value={stats?.thirst ?? 0}
                  suffix={`${stats?.thirst ?? 0}%`}
                />
              </Panel>
            </div>

            <Panel
              className="flex-1"
              bodyClassName="customScrollbar overflow-y-auto p-[.75rem]"
              title={
                <Tabs
                  fill={false}
                  items={detailTabs}
                  value={detailTab}
                  onChange={setDetailTab}
                />
              }
            >
              {detailTab === "items" &&
                (items.length > 0 ? (
                  <div className="grid grid-cols-6 gap-[.625rem]">
                    {items.map((item, index) => (
                      <Card
                        key={`${item.name}-${index}`}
                        className="items-center p-[.625rem]"
                      >
                        <div className="flex w-full items-center justify-between">
                          <span className="font-black text-[.6875rem] text-white">
                            {item.quantity}x
                          </span>
                          <span className="font-semibold text-[.625rem] text-white/35">
                            {item.weight || 0}kg
                          </span>
                        </div>
                        <img
                          src={item.image}
                          alt={item.name}
                          loading="lazy"
                          className="mx-auto my-1.5 size-[3.25rem] object-contain"
                          onError={(e) => {
                            e.currentTarget.src = FALLBACK_IMAGE;
                          }}
                        />
                        <span className="w-full truncate text-center font-black text-[.625rem] text-white uppercase">
                          {item.name}
                        </span>
                      </Card>
                    ))}
                  </div>
                ) : (
                  <Empty icon={IconPackage} label="Inventário vazio" />
                ))}

              {detailTab === "vehicles" &&
                (vehicles.length > 0 ? (
                  <div className="grid grid-cols-3 gap-[.625rem]">
                    {vehicles.map((vehicle, index) => (
                      <Card
                        key={`${vehicle.plate}-${index}`}
                        className="p-[.75rem]"
                      >
                        <img
                          src={vehicle.image}
                          alt={vehicle.name}
                          loading="lazy"
                          className="h-[4.5rem] w-full object-contain"
                          onError={(e) => {
                            e.currentTarget.src = FALLBACK_IMAGE;
                          }}
                        />
                        <span className="mt-1 w-full truncate text-center font-black text-[.75rem] text-white uppercase">
                          {vehicle.name}
                        </span>
                        <div className="mt-2 flex items-center justify-center gap-1.5">
                          <Badge color="#EDEAE5">{vehicle.plate}</Badge>
                          <Badge color="#EDEAE5">
                            {vehicle.color || "Sem cor"}
                          </Badge>
                        </div>
                      </Card>
                    ))}
                  </div>
                ) : (
                  <Empty icon={IconCar} label="Nenhum veículo registrado" />
                ))}

              {detailTab === "properties" &&
                (properties.length > 0 ? (
                  <div className="grid grid-cols-4 gap-[.625rem]">
                    {properties.map((property, index) => (
                      <Card
                        key={`${property.name}-${index}`}
                        className="items-center justify-center p-[.75rem]"
                      >
                        <IconBuildingEstate
                          stroke={1.5}
                          className="size-[2rem] text-primaryColor"
                        />
                        <span className="mt-2 w-full truncate text-center font-black text-[.6875rem] text-white uppercase">
                          {property.name}
                        </span>
                        <span className="w-full truncate text-center font-semibold text-[.625rem] text-white/35">
                          {property.type || "Propriedade"}
                        </span>
                      </Card>
                    ))}
                  </div>
                ) : (
                  <Empty
                    icon={IconBuildingEstate}
                    label="Nenhuma propriedade registrada"
                  />
                ))}
            </Panel>
          </div>
        </Page>

        {modals}
      </>
    );
  }

  return (
    <>
      <Page>
        <Toolbar>
          <Search
            value={searchTerm}
            placeholder="Buscar por nome ou passaporte"
            onChange={(e) => setSearchTerm(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={statusTabs}
            value={statusFilter}
            onChange={setStatusFilter}
          />
          <ToolbarDivider />
          <ToolbarCount value={filteredPlayers.length} label="jogadores" />
        </Toolbar>

        <Table
          className="flex-1"
          columns={[
            { label: "Jogador", className: "flex-[1.6]" },
            "Profissão",
            "VIP",
            { label: "Status", className: "max-w-[7rem]" },
            { label: "Ações", className: "max-w-[13rem] text-right" },
          ]}
        >
          {filteredPlayers.length === 0 ? (
            <Empty icon={IconUsersGroup} label="Nenhum jogador encontrado" />
          ) : (
            filteredPlayers.map((item) => (
              <Row key={item.id} onClick={() => openDetails(item.id)}>
                <Cell className="flex-[1.6]">
                  <Avatar name={item.name} online={item.online} />
                  <CellStack
                    title={item.name}
                    subtitle={`Passaporte #${item.passport}`}
                  />
                </Cell>
                <Cell>
                  <Badge color={item.professionColor || "#C7C7C7"}>
                    {item.profession}
                  </Badge>
                </Cell>
                <Cell>
                  <Badge color={item.vipColor || "#C7C7C7"}>{item.vip}</Badge>
                </Cell>
                <Cell className="max-w-[7rem]">
                  <StatusBadge online={item.status === "Online"} />
                </Cell>
                <Cell className="max-w-[13rem] justify-end">
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Espectar"
                    icon={
                      <IconEye stroke={2} className="size-[.875rem] text-white" />
                    }
                    onClick={(event) => {
                      event.stopPropagation();
                      fetchNui("spectatePlayer", { playerId: item.id });
                    }}
                  />
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Teleportar até"
                    icon={
                      <IconLocationShare
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={(event) => {
                      event.stopPropagation();
                      fetchNui("teleportPlayer", { playerId: item.id });
                    }}
                  />
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Puxar"
                    icon={
                      <IconArrowBarToDown
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={(event) => {
                      event.stopPropagation();
                      fetchNui("pullPlayer", { playerId: item.id });
                    }}
                  />
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Todas as ações"
                    icon={
                      <IconDots
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={(event) => {
                      event.stopPropagation();
                      setActionsFor(item);
                    }}
                  />
                </Cell>
              </Row>
            ))
          )}
        </Table>
      </Page>

      {modals}
    </>
  );
}
