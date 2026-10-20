import { useOrganizationsRefresh } from "@app/hooks/useAutoRefresh";
import {
  ServerOrganization,
  useServerOrganizations,
} from "@app/hooks/useServerOrganizations";
import { IconBuildingCommunity, IconCrown, IconUsers } from "@tabler/icons-react";
import { Avatar } from "@views/components/Avatar";
import { Badge, StatusBadge } from "@views/components/Badge";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Search } from "@views/components/Field";
import { Meter } from "@views/components/Meter";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Empty, ErrorState, Loading } from "@views/components/State";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useEffect, useState } from "react";

const TYPES: { match: string[]; name: string; color: string }[] = [
  { match: ["hospital", "medic", "saude"], name: "Saúde", color: "#FF4B4B" },
  {
    match: ["police", "policia", "pm"],
    name: "Policial",
    color: "rgb(var(--primaryColor))",
  },
  {
    match: ["military", "militar", "exercito"],
    name: "Militar",
    color: "#8B5CF6",
  },
  { match: ["gang", "facção", "crime"], name: "Criminal", color: "#FFB951" },
  {
    match: ["government", "governo", "prefeitura"],
    name: "Governo",
    color: "#10B981",
  },
];

function getOrganizationType(name: string) {
  const lower = name.toLowerCase();
  const found = TYPES.find((type) =>
    type.match.some((token) => lower.includes(token))
  );
  return found || { name: "Organização", color: "#C7C7C7" };
}

export function Organizations() {
  const {
    organizations,
    loading,
    error,
    organizationMembers,
    fetchOrganizations,
    selectOrganization,
    searchOrganizations,
  } = useServerOrganizations();

  const [searchTerm, setSearchTerm] = useState("");
  const [typeFilter, setTypeFilter] = useState("all");
  const [openedOrganization, setOpenedOrganization] =
    useState<ServerOrganization | null>(null);

  useOrganizationsRefresh();

  useEffect(() => {
    fetchOrganizations();
  }, []);

  const searched = searchTerm.trim()
    ? searchOrganizations(searchTerm)
    : organizations;

  const filtered = searched.filter((organization) =>
    typeFilter === "all"
      ? true
      : getOrganizationType(organization.name).name === typeFilter
  );

  const tabs = [
    { value: "all", label: "Todas", count: searched.length },
    ...TYPES.map((type) => ({
      value: type.name,
      label: type.name,
      count: searched.filter(
        (organization) => getOrganizationType(organization.name).name === type.name
      ).length,
    })).filter((tab) => tab.count > 0),
  ];

  const openMembers = (organization: ServerOrganization) => {
    setOpenedOrganization(organization);
    selectOrganization(organization);
  };

  return (
    <>
      <Page>
        <Toolbar>
          <Search
            value={searchTerm}
            placeholder="Buscar organização ou líder"
            onChange={(e) => setSearchTerm(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={tabs}
            value={typeFilter}
            onChange={setTypeFilter}
          />
          <ToolbarDivider />
          <ToolbarCount value={filtered.length} label="organizações" />
        </Toolbar>

        <div className="customScrollbar flex-1 overflow-y-auto">
          {loading && organizations.length === 0 ? (
            <Loading label="Carregando organizações" />
          ) : error ? (
            <ErrorState message={error} />
          ) : filtered.length === 0 ? (
            <Empty
              icon={IconBuildingCommunity}
              label="Nenhuma organização encontrada"
            />
          ) : (
            <div className="grid grid-cols-3 gap-[.625rem] pr-1">
              {filtered.map((organization) => {
                const type = getOrganizationType(organization.name);
                return (
                  <Card key={organization.id} className="p-[.875rem]">
                    <div className="flex items-start justify-between gap-2">
                      <div className="flex min-w-0 items-center gap-2">
                        <IconBuildingCommunity
                          stroke={2}
                          className="size-[1rem] flex-shrink-0 text-primaryColor"
                        />
                        <h3 className="truncate font-black text-[.8125rem] text-white uppercase">
                          {organization.name}
                        </h3>
                      </div>
                      <Badge color={type.color}>{type.name}</Badge>
                    </div>

                    <div className="mt-3 flex items-center gap-2">
                      <Avatar
                        name={organization.leader?.name || "?"}
                        online={organization.leader?.online}
                      />
                      <div className="flex min-w-0 flex-col">
                        <span className="font-black text-[.625rem] text-white/35 uppercase">
                          Líder
                        </span>
                        <span
                          className={`truncate font-black text-[.75rem] ${
                            organization.leader ? "text-white" : "text-white/25"
                          }`}
                        >
                          {organization.leader?.name || "Sem líder"}
                        </span>
                      </div>
                      {organization.leader && (
                        <IconCrown
                          stroke={2}
                          className="ml-auto size-[.9375rem] flex-shrink-0 text-[#FFD700]"
                        />
                      )}
                    </div>

                    <Meter
                      className="mt-3"
                      label="Membros online"
                      value={organization.onlineMembers}
                      max={organization.totalMembers || 1}
                      suffix={`${organization.onlineMembers} / ${organization.totalMembers}`}
                    />

                    <Button
                      size="sm"
                      variant="ghost"
                      className="mt-3 w-full"
                      icon={
                        <IconUsers
                          stroke={2}
                          className="size-[.8125rem] text-white"
                        />
                      }
                      onClick={() => openMembers(organization)}
                    >
                      Ver membros
                    </Button>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      </Page>

      <Modal
        visible={!!openedOrganization}
        icon={IconUsers}
        width="30rem"
        hideFooter
        title={openedOrganization?.name || "Membros"}
        onClose={() => setOpenedOrganization(null)}
      >
        <div className="customScrollbar flex max-h-[24rem] flex-col overflow-y-auto pr-1">
          {organizationMembers.length === 0 ? (
            <div className="flex h-[8rem] items-center justify-center font-black text-[.6875rem] text-white/25 uppercase">
              Nenhum membro encontrado
            </div>
          ) : (
            organizationMembers.map((member) => (
              <div
                key={member.id}
                className="flex items-center gap-2 border-white/[.04] border-b border-solid py-[.5rem] last:border-0"
              >
                <Avatar name={member.name} online={member.online} />
                <div className="flex min-w-0 flex-1 flex-col">
                  <span className="truncate font-black text-[.75rem] text-white">
                    {member.name}
                  </span>
                  <span className="truncate font-semibold text-[.625rem] text-white/30">
                    Passaporte #{member.id}
                  </span>
                </div>
                <Badge color="#C7C7C7">{member.role}</Badge>
                <StatusBadge online={member.online} />
              </div>
            ))
          )}
        </div>

        <Button
          size="lg"
          variant="ghost"
          className="w-full"
          onClick={() => setOpenedOrganization(null)}
        >
          Fechar
        </Button>
      </Modal>
    </>
  );
}
