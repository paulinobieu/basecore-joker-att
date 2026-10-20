import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { usePagination } from "@app/hooks/usePagination";
import { cn } from "@app/utils";
import { fetchNui } from "@app/utils/fetchNui";
import {
  IconAlertTriangle,
  IconArchive,
  IconArrowLeft,
  IconCheck,
  IconChevronLeft,
  IconChevronRight,
  IconCrosshair,
  IconMapPin,
  IconPencil,
  IconPlus,
  IconTrash,
} from "@tabler/icons-react";
import { Badge } from "@views/components/Badge";
import { Button } from "@views/components/Button";
import { Field, Input, Search, Select } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Pagination } from "@views/components/Pagination";
import { Panel } from "@views/components/Panel";
import { Empty } from "@views/components/State";
import { Cell, CellStack, Row, Table } from "@views/components/Table";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useEffect, useState } from "react";
import type { ReactNode } from "react";

interface ChestProps {
  id: number;
  name: string;
  coords: { x: number; y: number; z: number };
  mode: string;
  permission: string;
  weight: number;
  slots: number;
  distance: number;
}

interface FormState {
  id: number | null;
  name: string;
  mode: string;
  permission: string;
  weight: string;
  slots: string;
  distance: string;
  coords: { x: number; y: number; z: number } | null;
}

interface ModeOption {
  value: string;
  label: string;
  /** Rotulo curto do filtro. */
  tab: string;
  short: string;
  description: string;
  helper: string;
  requiresNameEqualsRole: boolean;
}

const MODE_OPTIONS: ModeOption[] = [
  {
    value: "1",
    label: "Baú de Cargo / Organização",
    tab: "Cargo",
    short: "Cargo (Polícia, Paramédico…)",
    description:
      "Cria 3 opções no baú: Compartimento Geral (do cargo), Compartimento Pessoal (de cada jogador) e Colete Balístico (somente Polícia).",
    helper:
      "Importante: o NOME do baú precisa ser exatamente o nome do cargo (ex: Policia, Paramedico). O jogador precisa estar EM SERVIÇO do cargo para abrir.",
    requiresNameEqualsRole: true,
  },
  {
    value: "2",
    label: "Baú Simples",
    tab: "Simples",
    short: "Apenas abrir",
    description:
      "Apenas uma opção: Abrir. Funciona como um armazém comum, com peso e slots definidos.",
    helper:
      "O jogador precisa estar EM SERVIÇO do cargo informado abaixo para conseguir abrir.",
    requiresNameEqualsRole: false,
  },
  {
    value: "3",
    label: "Reciclagem",
    tab: "Reciclagem",
    short: "Recicla itens",
    description:
      "Compartimento de reciclagem: itens depositados são automaticamente convertidos em recursos.",
    helper:
      "Útil para sucatas/recicladoras. Acesso liberado conforme o cargo informado.",
    requiresNameEqualsRole: false,
  },
  {
    value: "4",
    label: "Baú de Organização (Líder + Membro)",
    tab: "Organização",
    short: "Org: Líder + Membro",
    description:
      "Quando o jogador mira, aparecem DUAS opções no mesmo baú: 'Compartimento do Líder' (só o Chefe / rank 1 abre) e 'Compartimento de Membro' (qualquer rank da org abre). Cada compartimento tem sua própria storage.",
    helper:
      "NÃO precisa estar em serviço. Use o nome do grupo (ex: Ballas, Vagos, Families) no campo Cargo. O Líder = rank 1 da hierarquia (Chefe).",
    requiresNameEqualsRole: false,
  },
];

const STEPS = [
  { title: "Tipo & Identificação", hint: "O que o baú faz e quem abre" },
  { title: "Capacidade", hint: "Peso, slots e alcance" },
  { title: "Posição", hint: "Onde ele fica no mapa" },
];

const TOTAL_STEPS = STEPS.length;
const PAGE_SIZE = 12;

const getMode = (value: string) =>
  MODE_OPTIONS.find((mode) => mode.value === value) || MODE_OPTIONS[1];

const emptyForm = (): FormState => ({
  id: null,
  name: "",
  mode: "2",
  permission: "",
  weight: "50",
  slots: "25",
  distance: "1.25",
  coords: null,
});

export function Chests({ switcher }: { switcher?: ReactNode }) {
  const [chests, setChests] = useState<ChestProps[]>([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [modeFilter, setModeFilter] = useState("all");

  const [view, setView] = useState<"list" | "form">("list");
  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState<FormState>(emptyForm());
  const [step, setStep] = useState(1);
  const [chestToRemove, setChestToRemove] = useState<ChestProps | null>(null);

  useNuiEvent<ChestProps[]>("receiveChests", (data) => setChests(data || []));
  useNuiEvent<{ x: number; y: number; z: number } | null>(
    "chestPositionSelected",
    (data) => {
      if (data) setForm((prev) => ({ ...prev, coords: data }));
    }
  );

  useEffect(() => {
    fetchNui("getChests");
  }, []);

  const searched = chests.filter((chest) =>
    chest.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const filtered = searched.filter((chest) =>
    modeFilter === "all" ? true : chest.mode === modeFilter
  );

  const modeTabs = [
    { value: "all", label: "Todos", count: searched.length },
    ...MODE_OPTIONS.map((mode) => ({
      value: mode.value,
      label: mode.tab,
      count: searched.filter((chest) => chest.mode === mode.value).length,
    })).filter((tab) => tab.count > 0),
  ];

  const { currentPage, totalPages, startIndex, endIndex, setPage } =
    usePagination({
      totalItems: filtered.length,
      itemsPerPage: PAGE_SIZE,
      resetKey: `${searchTerm}-${modeFilter}`,
    });

  const paginated = filtered.slice(startIndex, endIndex);

  const openCreate = () => {
    setEditing(false);
    setForm(emptyForm());
    setStep(1);
    setView("form");
  };

  const openEdit = (chest: ChestProps) => {
    setEditing(true);
    setForm({
      id: chest.id,
      name: chest.name,
      mode: chest.mode,
      permission: chest.permission || "",
      weight: String(chest.weight ?? 50),
      slots: String(chest.slots ?? 25),
      distance: String(chest.distance ?? 1.25),
      coords: chest.coords,
    });
    setStep(1);
    setView("form");
  };

  const backToList = () => {
    setView("list");
    setEditing(false);
    setStep(1);
  };

  const stepValid = (target: number): boolean => {
    if (target === 1) {
      if (!form.name.trim()) return false;
      if (getMode(form.mode).requiresNameEqualsRole && !form.permission.trim())
        return false;
      return true;
    }
    if (target === 2) {
      const weight = Number.parseInt(form.weight);
      const slots = Number.parseInt(form.slots);
      const distance = Number.parseFloat(form.distance);
      return weight >= 1 && slots >= 1 && distance >= 0.5 && distance <= 10;
    }
    if (target === 3) return !!form.coords;
    return false;
  };

  const submit = async () => {
    if (!form.name.trim() || !form.coords) return;

    await fetchNui(editing ? "updateChest" : "createChest", {
      id: form.id,
      name: form.name.trim(),
      mode: form.mode,
      permission: form.permission.trim(),
      weight: Number.parseInt(form.weight) || 50,
      slots: Number.parseInt(form.slots) || 25,
      distance: Number.parseFloat(form.distance) || 1.25,
      coords: form.coords,
    });

    backToList();
    setTimeout(() => fetchNui("getChests"), 250);
  };

  const useCurrentCoords = async () => {
    const coords = await fetchNui<{ x: number; y: number; z: number }>(
      "getCurrentCoords"
    );
    if (coords) setForm((prev) => ({ ...prev, coords }));
  };

  const fmt = (value?: number) =>
    typeof value === "number" ? value.toFixed(2) : "?";

  if (view === "form") {
    const mode = getMode(form.mode);
    const canReach = (target: number) =>
      target === 1 || Array.from({ length: target - 1 }, (_, index) => index + 1).every(stepValid);

    return (
      <Page>
        <Toolbar className="h-[2.75rem]">
          <Button
            variant="ghost"
            className="w-[9rem] justify-start"
            icon={
              <IconArrowLeft stroke={2} className="size-[.875rem] text-white" />
            }
            onClick={backToList}
          >
            Voltar
          </Button>

          <ToolbarDivider />

          <div className="flex min-w-0 flex-col">
            <span className="truncate font-black text-[.875rem] text-white uppercase">
              {editing ? `Editar ${form.name || "baú"}` : "Criar novo baú"}
            </span>
            <span className="truncate font-semibold text-[.625rem] text-white/30">
              {mode.label}
            </span>
          </div>

          <div className="ml-auto flex items-center gap-[.625rem]">
            {step > 1 && (
              <Button
                variant="ghost"
                className="w-[8rem]"
                icon={
                  <IconChevronLeft
                    stroke={2}
                    className="size-[.875rem] text-white"
                  />
                }
                onClick={() => setStep((value) => Math.max(1, value - 1))}
              >
                Anterior
              </Button>
            )}
            {step < TOTAL_STEPS ? (
              <Button
                variant="accent"
                className="w-[8rem]"
                disabled={!stepValid(step)}
                icon={
                  <IconChevronRight
                    stroke={2}
                    className="size-[.875rem] text-white"
                  />
                }
                onClick={() => {
                  if (!stepValid(step)) return;
                  setStep((value) => Math.min(TOTAL_STEPS, value + 1));
                }}
              >
                Próximo
              </Button>
            ) : (
              <Button
                variant="accent"
                className="w-[8rem]"
                disabled={!stepValid(1) || !stepValid(2) || !stepValid(3)}
                icon={
                  <IconCheck stroke={2} className="size-[.875rem] text-white" />
                }
                onClick={submit}
              >
                {editing ? "Salvar" : "Criar"}
              </Button>
            )}
          </div>
        </Toolbar>

        <div className="flex flex-1 gap-[.9375rem] overflow-hidden">
          <div className="flex h-full w-[17rem] flex-shrink-0 flex-col gap-[.9375rem]">
            <Panel
              title="Etapas"
              className="flex-shrink-0"
              bodyClassName="flex flex-col gap-[.375rem] p-[.625rem]"
              action={
                <span className="font-black text-[.625rem] text-white/35 uppercase">
                  {step} / {TOTAL_STEPS}
                </span>
              }
            >
              {STEPS.map((item, index) => {
                const number = index + 1;
                const active = number === step;
                const done = number < step && stepValid(number);
                return (
                  <button
                    key={item.title}
                    type="button"
                    disabled={!canReach(number)}
                    onClick={() => canReach(number) && setStep(number)}
                    className={cn(
                      "ghost-btn flex items-center gap-2 rounded-[.3125rem] border border-white/5 border-solid px-[.625rem] py-[.5rem] text-left transition-all duration-300",
                      active && "is-active"
                    )}
                  >
                    <span
                      className={cn(
                        "relative z-10 flex size-[1.5rem] flex-shrink-0 items-center justify-center rounded-[.25rem] border border-white/[.06] border-solid font-black text-[.625rem]",
                        active || done ? "text-white" : "text-white/35"
                      )}
                    >
                      {done ? (
                        <IconCheck stroke={2.5} className="size-[.75rem]" />
                      ) : (
                        number
                      )}
                    </span>
                    <span className="relative z-10 flex min-w-0 flex-col">
                      <span
                        className={cn(
                          "truncate font-black text-[.6875rem] uppercase",
                          active ? "text-white" : "text-white/60"
                        )}
                      >
                        {item.title}
                      </span>
                      <span className="truncate font-semibold text-[.625rem] text-white/30">
                        {item.hint}
                      </span>
                    </span>
                  </button>
                );
              })}
            </Panel>

            <Panel
              title="Como funciona"
              className="flex-1"
              bodyClassName="customScrollbar overflow-y-auto p-[.75rem]"
            >
              <p className="font-semibold text-[.6875rem] text-white/55 leading-relaxed">
                {mode.description}
              </p>

              <div className="mt-3 flex items-start gap-2 rounded-[.3125rem] border border-[#FFB951]/25 border-solid bg-[#FFB951]/[.04] p-[.625rem]">
                <IconAlertTriangle
                  stroke={2}
                  className="mt-0.5 size-[.875rem] flex-shrink-0 text-[#FFB951]"
                />
                <p className="font-semibold text-[.625rem] text-[#FFB951]/85 leading-relaxed">
                  {mode.helper}
                </p>
              </div>
            </Panel>
          </div>

          <Panel
            title={STEPS[step - 1].title}
            className="flex-1"
            bodyClassName="customScrollbar overflow-y-auto p-[1.125rem]"
            action={
              <span className="font-black text-[.625rem] text-white/30 uppercase">
                {STEPS[step - 1].hint}
              </span>
            }
          >
            {step === 1 && (
              <div className="flex flex-col gap-5">
                <Field label="Tipo do baú">
                  <Select
                    value={form.mode}
                    onChange={(e) => {
                      const newMode = e.target.value;
                      setForm((prev) => {
                        const next = { ...prev, mode: newMode };
                        if (
                          getMode(newMode).requiresNameEqualsRole &&
                          prev.permission
                        ) {
                          next.name = prev.permission;
                        }
                        return next;
                      });
                    }}
                  >
                    {MODE_OPTIONS.map((option) => (
                      <option
                        key={option.value}
                        value={option.value}
                        className="bg-[#151519]"
                      >
                        {option.label}
                      </option>
                    ))}
                  </Select>
                </Field>

                <div className="grid grid-cols-2 gap-4">
                  <Field
                    label="Cargo necessário"
                    hint={
                      mode.value !== "1"
                        ? "O jogador precisa estar em serviço do cargo."
                        : "Neste modo o nome é espelhado do cargo."
                    }
                  >
                    <Input
                      placeholder="EX: Policia, Paramedico, Mecanico…"
                      value={form.permission}
                      onChange={(e) => {
                        const value = e.target.value;
                        setForm((prev) => {
                          const next = { ...prev, permission: value };
                          if (getMode(prev.mode).requiresNameEqualsRole)
                            next.name = value;
                          return next;
                        });
                      }}
                    />
                  </Field>

                  <Field label="Nome (identificador único)">
                    <Input
                      placeholder={
                        mode.requiresNameEqualsRole
                          ? "Será preenchido com o cargo"
                          : "EX: ArmazemPolicia, FerragemMecanica…"
                      }
                      value={form.name}
                      disabled={mode.requiresNameEqualsRole}
                      onChange={(e) => setForm({ ...form, name: e.target.value })}
                    />
                  </Field>
                </div>
              </div>
            )}

            {step === 2 && (
              <div className="grid grid-cols-3 gap-5">
                <Field label="Peso máximo (kg)">
                  <Input
                    type="number"
                    min={1}
                    value={form.weight}
                    onChange={(e) => setForm({ ...form, weight: e.target.value })}
                  />
                </Field>
                <Field label="Quantidade de slots">
                  <Input
                    type="number"
                    min={1}
                    value={form.slots}
                    onChange={(e) => setForm({ ...form, slots: e.target.value })}
                  />
                </Field>
                <Field
                  label="Raio de detecção (m)"
                  hint="Entre 0.5m e 10m · padrão 1.25m"
                >
                  <Input
                    type="number"
                    step="0.05"
                    min={0.5}
                    max={10}
                    value={form.distance}
                    onChange={(e) =>
                      setForm({ ...form, distance: e.target.value })
                    }
                  />
                </Field>
              </div>
            )}

            {step === 3 && (
              <div className="flex flex-col gap-4">
                <Field
                  label="Coordenadas"
                  hint="Mira: aponte para o local, [E] confirma, [X] cancela."
                >
                  <div className="filter-bar flex h-[2.25rem] items-center rounded-[.25rem] border border-white/[.08] border-solid px-[.625rem] font-extrabold text-[.75rem] text-white/70">
                    {form.coords
                      ? `${form.coords.x.toFixed(2)}, ${form.coords.y.toFixed(
                          2
                        )}, ${form.coords.z.toFixed(2)}`
                      : "Nenhuma posição selecionada"}
                  </div>
                </Field>

                <div className="grid grid-cols-2 gap-3">
                  <Button
                    size="lg"
                    variant="ghost"
                    icon={
                      <IconMapPin
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={useCurrentCoords}
                  >
                    Posição atual
                  </Button>
                  <Button
                    size="lg"
                    variant="ghost"
                    icon={
                      <IconCrosshair
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={() => fetchNui("selectChestPosition")}
                  >
                    Selecionar com mira
                  </Button>
                </div>
              </div>
            )}
          </Panel>
        </div>
      </Page>
    );
  }

  return (
    <>
      <Page>
        <Toolbar>
          {switcher}
          <ToolbarDivider />
          <Search
            value={searchTerm}
            placeholder="Buscar baú pelo nome"
            onChange={(e) => setSearchTerm(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={modeTabs}
            value={modeFilter}
            onChange={setModeFilter}
          />
          <ToolbarDivider />
          <ToolbarCount value={filtered.length} label="baús" />
          <Button
            variant="accent"
            className="w-[9rem]"
            icon={<IconPlus stroke={2.5} className="size-[.875rem] text-white" />}
            onClick={openCreate}
          >
            Novo baú
          </Button>
        </Toolbar>

        <Table
          className="flex-1"
          columns={[
            { label: "Baú", className: "flex-[1.4]" },
            "Permissão",
            "Peso / slots",
            { label: "Raio", className: "max-w-[6rem]" },
            "Coordenadas",
            { label: "Ações", className: "max-w-[10rem] text-right" },
          ]}
        >
          {paginated.length === 0 ? (
            <Empty icon={IconArchive} label="Nenhum baú cadastrado" />
          ) : (
            paginated.map((chest) => (
              <Row key={chest.id}>
                <Cell className="flex-[1.4]">
                  <CellStack
                    title={chest.name}
                    subtitle={getMode(chest.mode).short}
                  />
                </Cell>
                <Cell>
                  {chest.permission ? (
                    <Badge color="#C7C7C7">{chest.permission}</Badge>
                  ) : (
                    <span className="text-white/25">—</span>
                  )}
                </Cell>
                <Cell>
                  {chest.weight}kg / {chest.slots}
                </Cell>
                <Cell className="max-w-[6rem] text-white/60">
                  {(chest.distance ?? 1.25).toFixed(2)}m
                </Cell>
                <Cell className="font-semibold text-[.6875rem] text-white/40">
                  {fmt(chest.coords?.x)}, {fmt(chest.coords?.y)},{" "}
                  {fmt(chest.coords?.z)}
                </Cell>
                <Cell className="max-w-[10rem] justify-end">
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Teleportar"
                    icon={
                      <IconMapPin
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={() => fetchNui("teleportToChest", { id: chest.id })}
                  />
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Editar"
                    icon={
                      <IconPencil
                        stroke={2}
                        className="size-[.875rem] text-white"
                      />
                    }
                    onClick={() => openEdit(chest)}
                  />
                  <Button
                    size="sm"
                    variant="ghost"
                    title="Remover"
                    icon={
                      <IconTrash
                        stroke={2}
                        className="size-[.875rem] text-[#FF4B4B]"
                      />
                    }
                    onClick={() => setChestToRemove(chest)}
                  />
                </Cell>
              </Row>
            ))
          )}
        </Table>

        {filtered.length > 0 && (
          <Pagination
            page={currentPage}
            totalPages={totalPages}
            summary={`Página ${currentPage} de ${totalPages}`}
            onChange={setPage}
          />
        )}
      </Page>

      <Modal
        visible={!!chestToRemove}
        icon={IconTrash}
        title="Remover baú"
        danger
        description={
          chestToRemove
            ? `Tem certeza que deseja remover o baú ${chestToRemove.name}?`
            : undefined
        }
        footerLabels={{ cancel: "Cancelar", confirm: "Remover" }}
        onClose={() => setChestToRemove(null)}
        onConfirm={async () => {
          if (!chestToRemove) return;
          await fetchNui("deleteChest", { id: chestToRemove.id });
          setChestToRemove(null);
          setTimeout(() => fetchNui("getChests"), 250);
        }}
      />
    </>
  );
}
