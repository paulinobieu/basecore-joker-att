import { useDashboardRefresh } from "@app/hooks/useAutoRefresh";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { useServerOrganizations } from "@app/hooks/useServerOrganizations";
import { useServerStaff } from "@app/hooks/useServerStaff";
import { fetchNui } from "@app/utils/fetchNui";
import {
  IconBox,
  IconBriefcase,
  IconBuildingCommunity,
  IconCar,
  IconClock,
  IconMessages,
  IconPencil,
  IconPlus,
  IconSend,
  IconShieldHalfFilled,
  IconSpeakerphone,
  IconTrash,
  IconWalk,
} from "@tabler/icons-react";
import { Avatar } from "@views/components/Avatar";
import { Badge } from "@views/components/Badge";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Field, Input, Textarea } from "@views/components/Field";
import { Meter } from "@views/components/Meter";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Panel } from "@views/components/Panel";
import { Empty } from "@views/components/State";
import { useEffect, useRef, useState } from "react";
import { Gauge } from "./components/Gauge";

interface Notification {
  id: number;
  title: string;
  message: string;
  created_at: string;
  updated_at?: string;
}

interface OnlinePlayersData {
  players: number;
  slots: number;
}

interface ServerData {
  peds: number;
  vehicles: number;
  objects: number;
}

interface ChatMessage {
  id: number;
  user_id: number;
  name: string;
  message: string;
  created_at: string;
}

interface PlayerEntry {
  id: number;
  name: string;
  profession: string;
  online: boolean;
  status: "Online" | "Offline";
}

const ENTITY_COLORS = {
  peds: "#3C8EDC",
  vehicles: "#FFB951",
  objects: "#10B981",
};

const GROUP_COLORS: Record<string, string> = {
  Owner: "#FFD700",
  Admin: "#FF4444",
  Moderador: "rgb(var(--primaryColor))",
  Suporte: "#10B981",
};

export function Home() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [players, setPlayers] = useState<PlayerEntry[]>([]);
  const [currentUserId, setCurrentUserId] = useState<number | null>(null);
  const [onlinePlayersData, setOnlinePlayersData] = useState<OnlinePlayersData>({
    players: 0,
    slots: 0,
  });
  const [serverData, setServerData] = useState<ServerData>({
    peds: 0,
    vehicles: 0,
    objects: 0,
  });

  const [now, setNow] = useState(() => new Date());
  const [chatMessage, setChatMessage] = useState("");

  const [modalNotificationOpen, setModalNotificationOpen] = useState(false);
  const [modalEditNotificationOpen, setModalEditNotificationOpen] =
    useState(false);
  const [notificationToDelete, setNotificationToDelete] =
    useState<Notification | null>(null);
  const [editingNotification, setEditingNotification] =
    useState<Notification | null>(null);
  const [notificationForm, setNotificationForm] = useState({
    title: "",
    message: "",
  });
  const [loading, setLoading] = useState(false);
  const [resultMessage, setResultMessage] = useState<{
    success: boolean;
    message: string;
  } | null>(null);

  const chatEndRef = useRef<HTMLDivElement | null>(null);

  const { staffMembers } = useServerStaff();
  const { organizations } = useServerOrganizations();

  useDashboardRefresh();

  useNuiEvent<Notification[]>("receiveNotifications", setNotifications);
  useNuiEvent<OnlinePlayersData>("receiveOnlinePlayers", setOnlinePlayersData);
  useNuiEvent<ServerData>("receiveServerData", setServerData);
  useNuiEvent<ChatMessage[]>("receiveChatMessages", setChatMessages);
  useNuiEvent<PlayerEntry[]>("receivePlayers", setPlayers);
  useNuiEvent<number>("setCurrentUserId", setCurrentUserId);

  useNuiEvent<ChatMessage>("receiveChatMessage", (message) => {
    setChatMessages((prev) => [...prev, message]);
  });

  // O servidor transmite avisos novos/editados/removidos para todos os painéis
  // abertos. A lista é relida para manter o mesmo formato de data da consulta.
  useNuiEvent("newNotification", () => fetchNui("getNotifications"));
  useNuiEvent("notificationUpdated", () => fetchNui("getNotifications"));
  useNuiEvent("notificationDeleted", () => fetchNui("getNotifications"));

  useNuiEvent<{ id: number }>("receiveUserInfo", (info) => {
    if (info?.id) setCurrentUserId(info.id);
  });

  const openEditNotification = (notification: Notification) => {
    setEditingNotification(notification);
    setNotificationForm({
      title: notification.title,
      message: notification.message,
    });
    setModalEditNotificationOpen(true);
  };

  useNuiEvent<{ success: boolean; message: string }>(
    "notificationResult",
    (result) => {
      setResultMessage(result);
      setLoading(false);
      if (result.success) {
        setModalNotificationOpen(false);
        setModalEditNotificationOpen(false);
        setNotificationForm({ title: "", message: "" });
        setEditingNotification(null);
        fetchNui("getNotifications");
      }
      setTimeout(() => setResultMessage(null), 3000);
    }
  );

  useEffect(() => {
    const intervalId = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(intervalId);
  }, []);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ block: "end" });
  }, [chatMessages]);

  const handleCreateNotification = async () => {
    if (!notificationForm.title.trim() || !notificationForm.message.trim()) {
      setResultMessage({
        success: false,
        message: "Título e mensagem são obrigatórios",
      });
      return;
    }
    setLoading(true);
    await fetchNui("createNotification", notificationForm);
  };

  const handleEditNotification = async () => {
    if (
      !editingNotification ||
      !notificationForm.title.trim() ||
      !notificationForm.message.trim()
    ) {
      setResultMessage({ success: false, message: "Dados inválidos" });
      return;
    }
    setLoading(true);
    await fetchNui("editNotification", {
      id: editingNotification.id,
      ...notificationForm,
    });
  };

  const confirmDeleteNotification = async () => {
    if (!notificationToDelete) return;
    setLoading(true);
    await fetchNui("deleteNotification", { id: notificationToDelete.id });
    setNotificationToDelete(null);
    setLoading(false);
    fetchNui("getNotifications");
  };

  const handleSendMessage = async () => {
    if (!chatMessage.trim()) return;
    await fetchNui("sendChatMessage", { message: chatMessage.trim() });
    setChatMessage("");
  };

  const formatDate = (value: string) => {
    const date = new Date(value);
    return {
      date: date.toLocaleDateString("pt-BR"),
      time: date.toLocaleTimeString("pt-BR", {
        hour: "2-digit",
        minute: "2-digit",
      }),
    };
  };

  const formatMessageTime = (value: string) => {
    const date = new Date(value);
    const diffInHours = (Date.now() - date.getTime()) / (1000 * 60 * 60);
    if (diffInHours < 24) {
      return date.toLocaleTimeString("pt-BR", {
        hour: "2-digit",
        minute: "2-digit",
      });
    }
    return `${date.toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
    })} ${date.toLocaleTimeString("pt-BR", {
      hour: "2-digit",
      minute: "2-digit",
    })}`;
  };

  const onlinePlayers = players.filter((player) => player.online);
  const staffOnline = staffMembers.filter((member) => member.online);

  const totalEntities =
    (serverData.peds ?? 0) +
    (serverData.vehicles ?? 0) +
    (serverData.objects ?? 0);

  const entities = [
    { key: "peds", label: "Peds", value: serverData.peds ?? 0, icon: IconWalk },
    {
      key: "vehicles",
      label: "Veículos",
      value: serverData.vehicles ?? 0,
      icon: IconCar,
    },
    {
      key: "objects",
      label: "Objetos",
      value: serverData.objects ?? 0,
      icon: IconBox,
    },
  ] as const;

  const professions = Object.entries(
    onlinePlayers.reduce<Record<string, number>>((acc, player) => {
      const profession = player.profession || "Sem profissão";
      acc[profession] = (acc[profession] || 0) + 1;
      return acc;
    }, {})
  ).sort((a, b) => b[1] - a[1]);

  const activeOrganizations = [...organizations].sort(
    (a, b) =>
      b.onlineMembers - a.onlineMembers || b.totalMembers - a.totalMembers
  );

  return (
    <>
      <Page>
        <div className="flex h-[11rem] flex-shrink-0 gap-[.9375rem]">
          <Panel
            title="Status do servidor"
            className="flex-1"
            bodyClassName="flex items-center gap-[1.25rem] px-[1.25rem]"
            action={
              <div className="flex items-center gap-1.5">
                <IconClock stroke={2} className="size-[.875rem] text-white/30" />
                <span className="font-black text-[.75rem] text-white">
                  {now.toLocaleTimeString("pt-BR")}
                </span>
                <span className="font-semibold text-[.625rem] text-white/30">
                  {now.toLocaleDateString("pt-BR", {
                    day: "2-digit",
                    month: "2-digit",
                    year: "numeric",
                  })}
                </span>
              </div>
            }
          >
            <Gauge
              value={onlinePlayersData.players ?? 0}
              max={onlinePlayersData.slots || 1}
              caption={`de ${(onlinePlayersData.slots ?? 0).toLocaleString()} slots`}
              label="Ocupação"
            />

            <span className="h-[7.25rem] w-px flex-shrink-0 bg-white/[.06]" />

            <div className="grid h-[7.75rem] flex-1 grid-cols-3 gap-[.625rem]">
              {entities.map((entity) => (
                <Card key={entity.key} className="p-[.75rem]">
                  <div className="flex items-center justify-between gap-1">
                    <span className="truncate font-black text-[.625rem] text-white/40 uppercase">
                      {entity.label}
                    </span>
                    <entity.icon
                      stroke={2}
                      className="size-[.9375rem] flex-shrink-0"
                      style={{ color: ENTITY_COLORS[entity.key] }}
                    />
                  </div>

                  <span className="mt-1 font-black text-[1.5rem] text-white leading-none">
                    {entity.value.toLocaleString()}
                  </span>

                  <div className="mt-auto flex flex-col gap-1">
                    <Meter
                      value={entity.value}
                      max={totalEntities || 1}
                      color={ENTITY_COLORS[entity.key]}
                    />
                    <span className="font-semibold text-[.5625rem] text-white/25">
                      {Math.round((entity.value / (totalEntities || 1)) * 100)}%
                      do total
                    </span>
                  </div>
                </Card>
              ))}
            </div>
          </Panel>
        </div>

        <div className="flex flex-1 gap-[.9375rem] overflow-hidden">
          <div className="flex h-full flex-1 flex-col gap-[.9375rem]">
            <div className="flex flex-1 gap-[.9375rem] overflow-hidden">
              <Panel
                title="Jogadores por profissão"
                className="flex-1"
                bodyClassName="customScrollbar overflow-y-auto"
                action={
                  <div className="flex items-center gap-1.5">
                    <IconBriefcase
                      stroke={2}
                      className="size-[.875rem] text-white/30"
                    />
                    <span className="font-black text-[.6875rem] text-white/45 uppercase">
                      {onlinePlayers.length} online
                    </span>
                  </div>
                }
              >
                {professions.length === 0 ? (
                  <Empty
                    icon={IconBriefcase}
                    label="Ninguém online no momento"
                  />
                ) : (
                  <div className="flex h-full flex-col justify-between gap-[.5rem] px-[.875rem] py-[.75rem]">
                    {professions.slice(0, 5).map(([profession, total], index) => (
                      <div
                        key={profession}
                        className="flex items-center gap-[.625rem]"
                      >
                        <span className="w-[1.25rem] flex-shrink-0 font-black text-[.75rem] text-white/20">
                          {String(index + 1).padStart(2, "0")}
                        </span>
                        <div className="flex min-w-0 flex-1 flex-col gap-1">
                          <div className="flex items-center justify-between gap-2">
                            <span className="truncate font-black text-[.75rem] text-white">
                              {profession}
                            </span>
                            <div className="flex flex-shrink-0 items-baseline gap-1.5">
                              <span className="font-black text-[.8125rem] text-white">
                                {total}
                              </span>
                              <span className="font-black text-[.625rem] text-white/30">
                                {Math.round(
                                  (total / (onlinePlayers.length || 1)) * 100
                                )}
                                %
                              </span>
                            </div>
                          </div>
                          <Meter value={total} max={onlinePlayers.length || 1} />
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </Panel>

              <Panel
                title="Organizações"
                className="w-[19rem] flex-shrink-0"
                bodyClassName="customScrollbar overflow-y-auto"
                action={
                  <IconBuildingCommunity
                    stroke={2}
                    className="size-[.875rem] text-white/30"
                  />
                }
              >
                {activeOrganizations.length === 0 ? (
                  <Empty
                    icon={IconBuildingCommunity}
                    label="Nenhuma organização"
                  />
                ) : (
                  <div className="flex h-full flex-col justify-between gap-[.5rem] px-[.875rem] py-[.75rem]">
                    {activeOrganizations.slice(0, 5).map((organization) => (
                      <div
                        key={organization.id}
                        className="flex flex-col gap-1"
                      >
                        <div className="flex items-center justify-between gap-2">
                          <span className="truncate font-black text-[.75rem] text-white">
                            {organization.name}
                          </span>
                          <div className="flex flex-shrink-0 items-baseline gap-1">
                            <span className="font-black text-[.8125rem] text-white">
                              {organization.onlineMembers}
                            </span>
                            <span className="font-black text-[.625rem] text-white/30">
                              / {organization.totalMembers}
                            </span>
                          </div>
                        </div>
                        <Meter
                          value={organization.onlineMembers}
                          max={organization.totalMembers || 1}
                        />
                      </div>
                    ))}
                  </div>
                )}
              </Panel>
            </div>

            <Panel
              title="Quadro de avisos"
              className="flex-1"
              bodyClassName="customScrollbar overflow-y-auto"
              action={
                <button
                  type="button"
                  title="Criar aviso"
                  onClick={() => setModalNotificationOpen(true)}
                  className="flex size-[1.375rem] items-center justify-center rounded-[.25rem] border border-white/[.06] border-solid text-white/50 transition-all duration-300 hover:border-primaryColor hover:text-white"
                >
                  <IconPlus stroke={2.5} className="size-[.75rem]" />
                </button>
              }
            >
              {notifications.length === 0 ? (
                <Empty
                  icon={IconSpeakerphone}
                  label="Nenhum aviso publicado"
                  hint="Clique no + para criar um"
                />
              ) : (
                <div className="grid h-full auto-rows-[minmax(4.75rem,1fr)] grid-cols-2 gap-[.625rem] p-[.75rem]">
                  {notifications.map((notification) => {
                    const { date, time } = formatDate(notification.created_at);
                    return (
                      <Card
                        key={notification.id}
                        className="group relative justify-center p-[.75rem]"
                      >
                        <div className="flex items-center gap-2">
                          <span className="font-extrabold text-[.625rem] text-primaryColor uppercase">
                            {date}
                          </span>
                          <span className="font-semibold text-[.625rem] text-white/30">
                            {time}
                          </span>
                        </div>

                        <h3 className="mt-1 truncate pr-[3.5rem] font-black text-[.875rem] text-white uppercase">
                          {notification.title}
                        </h3>
                        <p className="mt-1 line-clamp-2 font-semibold text-[.6875rem] text-white/55 leading-relaxed">
                          {notification.message}
                        </p>

                        <div className="absolute top-[.75rem] right-[.75rem] z-10 flex gap-1 opacity-0 transition-opacity duration-300 group-hover:opacity-100">
                          <button
                            type="button"
                            title="Editar aviso"
                            onClick={() => openEditNotification(notification)}
                            className="flex size-[1.375rem] items-center justify-center rounded-[.25rem] border border-white/[.06] border-solid bg-black/40 text-white/60 transition-all duration-300 hover:border-primaryColor hover:text-white"
                          >
                            <IconPencil stroke={2} className="size-[.75rem]" />
                          </button>
                          <button
                            type="button"
                            title="Deletar aviso"
                            onClick={() => setNotificationToDelete(notification)}
                            className="flex size-[1.375rem] items-center justify-center rounded-[.25rem] border border-[#FF4B4B]/25 border-solid bg-black/40 text-[#FF4B4B] transition-all duration-300 hover:border-[#FF4B4B] hover:text-white"
                          >
                            <IconTrash stroke={2} className="size-[.75rem]" />
                          </button>
                        </div>
                      </Card>
                    );
                  })}
                </div>
              )}
            </Panel>
          </div>

          <div className="flex h-full w-[24rem] flex-shrink-0 flex-col gap-[.9375rem]">
            <Panel
              title="Staff online"
              className="h-[15rem] flex-shrink-0"
              bodyClassName="customScrollbar overflow-y-auto px-[.875rem]"
              action={
                <div className="flex items-baseline gap-1">
                  <span className="font-black text-[.875rem] text-white">
                    {staffOnline.length}
                  </span>
                  <span className="font-black text-[.6875rem] text-white/30">
                    / {staffMembers.length}
                  </span>
                </div>
              }
            >
              {staffOnline.length === 0 ? (
                <Empty
                  icon={IconShieldHalfFilled}
                  label="Ninguém da equipe online"
                />
              ) : (
                staffOnline.map((member) => (
                  <div
                    key={member.id}
                    className="flex items-center gap-2 border-white/[.04] border-b border-solid py-[.5rem] last:border-0"
                  >
                    <Avatar name={member.name} online />
                    <div className="flex min-w-0 flex-1 flex-col">
                      <span className="truncate font-black text-[.75rem] text-white">
                        {member.name}
                      </span>
                      <span className="truncate font-semibold text-[.625rem] text-white/30">
                        {member.hierarchy}
                      </span>
                    </div>
                    <Badge color={GROUP_COLORS[member.group] || "#C7C7C7"}>
                      {member.group}
                    </Badge>
                  </div>
                ))
              )}
            </Panel>

            <Panel
              title="Chat staff"
              className="flex-1"
              bodyClassName="flex flex-col overflow-hidden"
              action={
                <IconMessages
                  stroke={2}
                  className="size-[.875rem] text-white/30"
                />
              }
            >
              <div className="customScrollbar flex flex-1 flex-col gap-3 overflow-y-auto px-[.875rem] py-[.75rem]">
                {chatMessages.length === 0 ? (
                  <div className="flex h-full items-center justify-center font-black text-[.6875rem] text-white/25 uppercase">
                    Nenhuma mensagem ainda
                  </div>
                ) : (
                  chatMessages.map((message) => {
                    const isOwn =
                      currentUserId !== null &&
                      message.user_id === currentUserId;
                    return (
                      <div
                        key={message.id}
                        className={`flex gap-2 ${
                          isOwn ? "flex-row-reverse" : "flex-row"
                        }`}
                      >
                        <Avatar name={message.name} />
                        <div
                          className={`flex max-w-[75%] flex-col ${
                            isOwn ? "items-end" : "items-start"
                          }`}
                        >
                          <div className="flex items-center gap-2">
                            <span className="font-black text-[.6875rem] text-white uppercase">
                              {message.name}
                            </span>
                            <span className="font-semibold text-[.625rem] text-white/30">
                              {formatMessageTime(message.created_at)}
                            </span>
                          </div>
                          <div
                            className={`mt-1 rounded-[.3125rem] border border-white/[.05] border-solid px-2.5 py-1.5 font-semibold text-[.6875rem] text-white/85 leading-relaxed ${
                              isOwn ? "accent-btn text-white" : "surface-card"
                            }`}
                          >
                            <span className="relative z-10">
                              {message.message}
                            </span>
                          </div>
                        </div>
                      </div>
                    );
                  })
                )}
                <div ref={chatEndRef} />
              </div>

              <div className="flex flex-shrink-0 items-center gap-2 border-white/[.05] border-t border-solid px-[.875rem] py-[.625rem]">
                <Input
                  placeholder="Conversar em #chat-staff"
                  value={chatMessage}
                  onChange={(e) => setChatMessage(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleSendMessage()}
                />
                <Button
                  variant="accent"
                  className="w-[2.25rem] px-0"
                  icon={
                    <IconSend stroke={2} className="size-[.875rem] text-white" />
                  }
                  onClick={handleSendMessage}
                />
              </div>
            </Panel>
          </div>
        </div>
      </Page>

      <Modal
        visible={modalNotificationOpen}
        icon={IconSpeakerphone}
        title="Criar aviso"
        loading={loading}
        footerLabels={{ cancel: "Cancelar", confirm: "Criar" }}
        onClose={() => {
          setModalNotificationOpen(false);
          setNotificationForm({ title: "", message: "" });
          setResultMessage(null);
        }}
        onConfirm={handleCreateNotification}
      >
        {resultMessage && (
          <p
            className={`rounded-[.25rem] border border-solid px-3 py-2 text-center font-black text-[.6875rem] uppercase ${
              resultMessage.success
                ? "border-[#9CF35B]/30 text-[#9CF35B]"
                : "border-[#FF4B4B]/30 text-[#FF4B4B]"
            }`}
          >
            {resultMessage.message}
          </p>
        )}
        <Field label="Título">
          <Input
            placeholder="EX: Reunião da administração"
            value={notificationForm.title}
            onChange={(e) =>
              setNotificationForm((prev) => ({
                ...prev,
                title: e.target.value,
              }))
            }
          />
        </Field>
        <Field label="Mensagem">
          <Textarea
            rows={4}
            placeholder="EX: Todos reunidos hoje às 12:30"
            value={notificationForm.message}
            onChange={(e) =>
              setNotificationForm((prev) => ({
                ...prev,
                message: e.target.value,
              }))
            }
          />
        </Field>
      </Modal>

      <Modal
        visible={modalEditNotificationOpen}
        icon={IconPencil}
        title="Editar aviso"
        loading={loading}
        footerLabels={{ cancel: "Cancelar", confirm: "Salvar" }}
        onClose={() => {
          setModalEditNotificationOpen(false);
          setEditingNotification(null);
          setNotificationForm({ title: "", message: "" });
          setResultMessage(null);
        }}
        onConfirm={handleEditNotification}
      >
        <Field label="Título">
          <Input
            value={notificationForm.title}
            onChange={(e) =>
              setNotificationForm((prev) => ({
                ...prev,
                title: e.target.value,
              }))
            }
          />
        </Field>
        <Field label="Mensagem">
          <Textarea
            rows={4}
            value={notificationForm.message}
            onChange={(e) =>
              setNotificationForm((prev) => ({
                ...prev,
                message: e.target.value,
              }))
            }
          />
        </Field>
      </Modal>

      <Modal
        visible={!!notificationToDelete}
        icon={IconTrash}
        title="Confirmar exclusão"
        description={
          notificationToDelete
            ? `Tem certeza que deseja deletar o aviso "${notificationToDelete.title}"?`
            : undefined
        }
        danger
        loading={loading}
        footerLabels={{ cancel: "Cancelar", confirm: "Deletar" }}
        onClose={() => setNotificationToDelete(null)}
        onConfirm={confirmDeleteNotification}
      />
    </>
  );
}
