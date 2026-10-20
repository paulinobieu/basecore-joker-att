import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { usePagination } from "@app/hooks/usePagination";
import { fetchNui } from "@app/utils/fetchNui";
import {
  IconArrowLeft,
  IconBuildingEstate,
  IconCar,
  IconFridge,
  IconInfoCircle,
  IconMapPin,
  IconPencil,
  IconTrash,
  IconVectorTriangle,
} from "@tabler/icons-react";
import { Avatar } from "@views/components/Avatar";
import { Badge } from "@views/components/Badge";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Field, Input, Search, Select } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Pagination } from "@views/components/Pagination";
import { Panel } from "@views/components/Panel";
import { Empty } from "@views/components/State";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useEffect, useState } from "react";
import type { ReactNode } from "react";

interface PropertyData {
  name: string;
  interior: string;
  passport: number;
  ownerName: string;
  vault: number;
  fridge: number;
  tax: number;
  coords: { x: number; y: number; z: number } | null;
  hasGarage: boolean;
  hasVault: boolean;
  hasFridge: boolean;
  garage: string | null;
}

interface InteriorInfo {
  name: string;
  hasVault: boolean;
  hasFridge: boolean;
  hasClothes: boolean;
  hasLocker?: boolean;
  furnitureCount?: number;
}

interface PropertiesPayload {
  properties: PropertyData[];
  interiors: InteriorInfo[];
}

const INTERIOR_DESCRIPTIONS: Record<
  string,
  { title: string; description: string; helper: string }
> = {
  Emerald: {
    title: "Emerald — Apartamento Básico",
    description:
      "Apartamento de entrada. Tem cofre/baú, geladeira e guarda-roupa, com cerca de 11 móveis decorativos. Ideal para o primeiro imóvel do jogador.",
    helper: "Pequeno e econômico. Boa opção para jogadores iniciantes.",
  },
  Ruby: {
    title: "Ruby — Apartamento Médio",
    description:
      "Apartamento intermediário, com mais espaço que o Emerald. Mantém cofre, geladeira e guarda-roupa, com aproximadamente 13 móveis.",
    helper: "Upgrade natural a partir do Emerald. Layout um pouco mais amplo.",
  },
  Sapphire: {
    title: "Sapphire — Apartamento Grande",
    description:
      "Apartamento amplo de dois ambientes com aproximadamente 23 móveis. Cofre, geladeira e guarda-roupa inclusos.",
    helper:
      "Espaçoso. Pessoas que gostam de decorar têm mais slots de móveis.",
  },
  Amethyst: {
    title: "Amethyst — Apartamento Luxuoso",
    description:
      "Apartamento de alto padrão com cerca de 26 móveis. Possui cofre, geladeira e guarda-roupa.",
    helper: "Top do mercado para apartamentos. Maior número de slots de móveis.",
  },
  Amber: {
    title: "Amber — Cobertura / Penthouse",
    description:
      "Cobertura em múltiplos níveis (~18 móveis). Cofre, geladeira e guarda-roupa. Decoração espalhada por andares.",
    helper: "Visual mais sofisticado, ideal para jogadores de status alto.",
  },
  Galpao: {
    title: "Galpão",
    description:
      "Galpão industrial: só cofre/baú, sem geladeira nem guarda-roupa. Pensado para armazenamento, não para morar.",
    helper:
      "Use para baú de organização/empresa. Não tem mobília nem garagem própria.",
  },
};

const PAGE_SIZE = 24;

const FILTERS = [
  { value: "all", label: "Todas" },
  { value: "garage", label: "Com garagem" },
  { value: "vault", label: "Com baú" },
  { value: "fridge", label: "Com geladeira" },
];

export function Properties({ switcher }: { switcher?: ReactNode }) {
  const [properties, setProperties] = useState<PropertyData[]>([]);
  const [interiors, setInteriors] = useState<InteriorInfo[]>([]);
  const [searchProperty, setSearchProperty] = useState("");
  const [resourceFilter, setResourceFilter] = useState("all");

  const [editing, setEditing] = useState<PropertyData | null>(null);
  const [propertyToRemove, setPropertyToRemove] = useState<PropertyData | null>(
    null
  );

  const [editPassport, setEditPassport] = useState("");
  const [editInterior, setEditInterior] = useState("");
  const [editVault, setEditVault] = useState("");
  const [editFridge, setEditFridge] = useState("");

  useNuiEvent<PropertiesPayload | PropertyData[]>(
    "receiveProperties",
    (data) => {
      if (Array.isArray(data)) {
        setProperties(data || []);
        return;
      }
      if (data) {
        setProperties(data.properties || []);
        setInteriors(data.interiors || []);
      }
    }
  );

  useEffect(() => {
    fetchNui("getProperties");
  }, []);

  const searched = properties.filter(
    (property) =>
      property.name.toLowerCase().includes(searchProperty.toLowerCase()) ||
      property.ownerName.toLowerCase().includes(searchProperty.toLowerCase()) ||
      String(property.passport || "").includes(searchProperty)
  );

  const filtered = searched.filter((property) =>
    resourceFilter === "all"
      ? true
      : resourceFilter === "garage"
      ? property.hasGarage
      : resourceFilter === "vault"
      ? property.hasVault
      : property.hasFridge
  );

  const { currentPage, totalPages, startIndex, endIndex, setPage } =
    usePagination({
      totalItems: filtered.length,
      itemsPerPage: PAGE_SIZE,
      resetKey: `${searchProperty}-${resourceFilter}`,
    });

  const paginated = filtered.slice(startIndex, endIndex);

  const tabs = FILTERS.map((filter) => ({
    ...filter,
    count:
      filter.value === "all"
        ? searched.length
        : searched.filter((property) =>
            filter.value === "garage"
              ? property.hasGarage
              : filter.value === "vault"
              ? property.hasVault
              : property.hasFridge
          ).length,
  }));

  const openEdit = (property: PropertyData) => {
    setEditPassport(String(property.passport ?? ""));
    setEditInterior(property.interior || "");
    setEditVault(String(property.vault ?? 0));
    setEditFridge(String(property.fridge ?? 0));
    setEditing(property);
  };

  const submitEdit = async () => {
    if (!editing) return;
    await fetchNui("updateProperty", {
      name: editing.name,
      passport: editPassport ? Number.parseInt(editPassport) : undefined,
      interior: editInterior || undefined,
      vault: editVault !== "" ? Number.parseInt(editVault) : undefined,
      fridge: editFridge !== "" ? Number.parseInt(editFridge) : undefined,
    });
    setEditing(null);
  };

  const confirmRemove = async () => {
    if (!propertyToRemove) return;
    await fetchNui("removeProperty", { name: propertyToRemove.name });
    if (editing?.name === propertyToRemove.name) setEditing(null);
    setPropertyToRemove(null);
  };

  const removeModal = (
    <Modal
      visible={!!propertyToRemove}
      icon={IconTrash}
      danger
      title="Remover propriedade"
      description={
        propertyToRemove
          ? `Remover ${propertyToRemove.name} de ${propertyToRemove.ownerName} (#${propertyToRemove.passport})? Essa ação é permanente.`
          : undefined
      }
      footerLabels={{ cancel: "Cancelar", confirm: "Remover" }}
      onClose={() => setPropertyToRemove(null)}
      onConfirm={confirmRemove}
    />
  );

  if (editing) {
    const interiorInfo = interiors.find((item) => item.name === editInterior);
    const description = INTERIOR_DESCRIPTIONS[editInterior];

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
            onClick={() => setEditing(null)}
          >
            Voltar
          </Button>

          <ToolbarDivider />

          <div className="flex min-w-0 flex-col">
            <span className="truncate font-black text-[.875rem] text-white uppercase">
              {editing.name}
            </span>
            <span className="truncate font-semibold text-[.625rem] text-white/30">
              {editing.ownerName} · #{editing.passport}
            </span>
          </div>

          <div className="ml-auto flex items-center gap-[.625rem]">
            <Button
              variant="danger"
              className="w-[10rem]"
              icon={<IconTrash stroke={2} className="size-[.875rem] text-white" />}
              onClick={() => setPropertyToRemove(editing)}
            >
              Remover
            </Button>
            <Button variant="accent" className="w-[9rem]" onClick={submitEdit}>
              Salvar
            </Button>
          </div>
        </Toolbar>

        <div className="flex flex-1 gap-[.9375rem] overflow-hidden">
          <Panel
            title="Dados da propriedade"
            className="flex-1"
            bodyClassName="customScrollbar overflow-y-auto p-[1.125rem]"
          >
            <div className="grid grid-cols-2 gap-4">
              <Field
                label="Passaporte do dono"
                hint={`Atual: #${editing.passport} · ${editing.ownerName}`}
              >
                <Input
                  type="number"
                  placeholder="ID do dono"
                  value={editPassport}
                  onChange={(e) => setEditPassport(e.target.value)}
                />
              </Field>

              <Field label="Interior" hint={`Atual: ${editing.interior}`}>
                {interiors.length > 0 ? (
                  <Select
                    value={editInterior}
                    onChange={(e) => setEditInterior(e.target.value)}
                  >
                    <option value="" className="bg-[#151519]">
                      Selecionar interior
                    </option>
                    {interiors.map((item) => (
                      <option
                        key={item.name}
                        value={item.name}
                        className="bg-[#151519]"
                      >
                        {item.name}
                      </option>
                    ))}
                  </Select>
                ) : (
                  <Input
                    placeholder="EX: Emerald, Ruby, Galpao"
                    value={editInterior}
                    onChange={(e) => setEditInterior(e.target.value)}
                  />
                )}
              </Field>

              <Field
                label="Peso do baú (kg)"
                hint={`Atual: ${editing.vault}kg`}
              >
                <Input
                  type="number"
                  min={0}
                  value={editVault}
                  onChange={(e) => setEditVault(e.target.value)}
                />
              </Field>

              <Field
                label="Peso da geladeira (kg)"
                hint={`Atual: ${editing.fridge}kg`}
              >
                <Input
                  type="number"
                  min={0}
                  value={editFridge}
                  onChange={(e) => setEditFridge(e.target.value)}
                />
              </Field>
            </div>

            <div className="mt-5 flex flex-wrap items-center gap-1.5 border-white/[.05] border-t border-solid pt-4">
              <span className="mr-1 font-black text-[.625rem] text-white/35 uppercase">
                Recursos atuais
              </span>
              {editing.hasGarage && <Badge color="#3C8EDC">Garagem</Badge>}
              {editing.hasVault && <Badge color="#FFB951">Baú</Badge>}
              {editing.hasFridge && <Badge color="#10B981">Geladeira</Badge>}
              {!editing.hasGarage &&
                !editing.hasVault &&
                !editing.hasFridge && (
                  <span className="font-semibold text-[.625rem] text-white/25">
                    Sem recursos extras
                  </span>
                )}
            </div>
          </Panel>

          <Panel
            title="Sobre o interior"
            className="w-[26rem] flex-shrink-0"
            bodyClassName="customScrollbar overflow-y-auto p-[1.125rem]"
          >
            {description ? (
              <div className="flex h-full flex-col gap-3">
                <div className="flex items-start gap-2">
                  <IconInfoCircle
                    stroke={2}
                    className="mt-0.5 size-[.9375rem] flex-shrink-0 text-primaryColor"
                  />
                  <h3 className="font-black text-[.8125rem] text-white uppercase leading-snug">
                    {description.title}
                  </h3>
                </div>

                <p className="font-semibold text-[.6875rem] text-white/60 leading-relaxed">
                  {description.description}
                </p>
                <p className="font-semibold text-[.6875rem] text-white/35 italic leading-relaxed">
                  {description.helper}
                </p>

                {interiorInfo && (
                  <div className="mt-auto border-white/[.05] border-t border-solid pt-3">
                    <span className="mb-2 block font-black text-[.625rem] text-white/35 uppercase">
                      Recursos do interior
                    </span>
                    <div className="flex flex-wrap items-center gap-1.5">
                      {interiorInfo.hasVault && (
                        <Badge color="#FFB951">Baú</Badge>
                      )}
                      {interiorInfo.hasFridge && (
                        <Badge color="#10B981">Geladeira</Badge>
                      )}
                      {interiorInfo.hasClothes && (
                        <Badge color="#8B5CF6">Guarda-roupa</Badge>
                      )}
                      {!!interiorInfo.furnitureCount && (
                        <Badge color="#3C8EDC">
                          {interiorInfo.furnitureCount} móveis
                        </Badge>
                      )}
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <Empty
                icon={IconVectorTriangle}
                label="Selecione um interior"
                hint="A descrição aparece aqui"
              />
            )}
          </Panel>
        </div>
        </Page>

        {removeModal}
      </>
    );
  }

  return (
    <>
      <Page>
        <Toolbar>
          {switcher}
          <ToolbarDivider />
          <Search
            value={searchProperty}
            placeholder="Buscar por nome, dono ou passaporte"
            onChange={(e) => setSearchProperty(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={tabs}
            value={resourceFilter}
            onChange={setResourceFilter}
          />
          <ToolbarDivider />
          <ToolbarCount value={filtered.length} label="propriedades" />
        </Toolbar>

        <div className="customScrollbar flex-1 overflow-y-auto">
          {paginated.length === 0 ? (
            <Empty
              icon={IconBuildingEstate}
              label={
                properties.length === 0
                  ? "Nenhuma propriedade encontrada"
                  : "Nenhuma propriedade corresponde ao filtro"
              }
            />
          ) : (
            <div className="grid grid-cols-4 gap-[.625rem] pr-1">
              {paginated.map((property) => (
                <Card key={property.name} className="p-[.875rem]">
                  <div className="flex items-start justify-between gap-2">
                    <div className="min-w-0">
                      <h3
                        title={property.name}
                        className="truncate font-black text-[.8125rem] text-white uppercase"
                      >
                        {property.name}
                      </h3>
                      <p className="truncate font-semibold text-[.625rem] text-white/35">
                        {property.interior}
                      </p>
                    </div>
                    <span className="flex-shrink-0 font-black text-[.625rem] text-primaryColor">
                      #{property.passport || "?"}
                    </span>
                  </div>

                  <div className="mt-3 flex items-center gap-2">
                    <Avatar name={property.ownerName} />
                    <span
                      title={property.ownerName}
                      className="min-w-0 truncate font-bold text-[.75rem] text-white/85"
                    >
                      {property.ownerName}
                    </span>
                  </div>

                  <div className="mt-3 flex flex-wrap items-center gap-1.5">
                    {property.hasGarage && (
                      <Badge color="#3C8EDC">
                        <IconCar stroke={2} className="size-[.6875rem]" />
                        Garagem
                      </Badge>
                    )}
                    {property.hasVault && (
                      <Badge color="#FFB951">
                        <IconVectorTriangle
                          stroke={2}
                          className="size-[.6875rem]"
                        />
                        {property.vault}kg
                      </Badge>
                    )}
                    {property.hasFridge && (
                      <Badge color="#10B981">
                        <IconFridge stroke={2} className="size-[.6875rem]" />
                        {property.fridge}kg
                      </Badge>
                    )}
                    {!property.hasGarage &&
                      !property.hasVault &&
                      !property.hasFridge && (
                        <span className="font-semibold text-[.625rem] text-white/25">
                          Sem recursos extras
                        </span>
                      )}
                  </div>

                  <div className="mt-auto flex items-center gap-1.5 pt-3">
                    <Button
                      size="sm"
                      variant="ghost"
                      className="flex-1"
                      disabled={!property.coords}
                      icon={
                        <IconMapPin
                          stroke={2}
                          className="size-[.8125rem] text-white"
                        />
                      }
                      onClick={() =>
                        fetchNui("teleportToProperty", { name: property.name })
                      }
                    >
                      TP
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="flex-1"
                      icon={
                        <IconPencil
                          stroke={2}
                          className="size-[.8125rem] text-white"
                        />
                      }
                      onClick={() => openEdit(property)}
                    >
                      Editar
                    </Button>
                    <Button
                      size="sm"
                      variant="ghost"
                      title="Remover"
                      className="w-[2rem] px-0"
                      icon={
                        <IconTrash
                          stroke={2}
                          className="size-[.8125rem] text-[#FF4B4B]"
                        />
                      }
                      onClick={() => setPropertyToRemove(property)}
                    />
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>

        {filtered.length > 0 && (
          <Pagination
            page={currentPage}
            totalPages={totalPages}
            summary={`Página ${currentPage} de ${totalPages}`}
            onChange={setPage}
          />
        )}
      </Page>

      {removeModal}
    </>
  );
}
