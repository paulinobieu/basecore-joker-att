import { useStaffRefresh } from "@app/hooks/useAutoRefresh";
import { StaffMember, useServerStaff } from "@app/hooks/useServerStaff";
import {
  IconArrowDown,
  IconArrowUp,
  IconShieldHalfFilled,
  IconUserOff,
  IconUsersGroup,
  IconWifi,
} from "@tabler/icons-react";
import { Avatar } from "@views/components/Avatar";
import { Badge, StatusBadge } from "@views/components/Badge";
import { Button } from "@views/components/Button";
import { Search } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Empty, ErrorState, Loading } from "@views/components/State";
import { Stat } from "@views/components/Stat";
import { Cell, CellStack, Row, Table } from "@views/components/Table";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useEffect, useState } from "react";

const GROUP_COLORS: Record<string, string> = {
  Owner: "#FFD700",
  Admin: "#FF4444",
  Moderador: "rgb(var(--primaryColor))",
  Suporte: "#10B981",
};

export function Staff() {
  const {
    staffMembers,
    loading,
    error,
    fetchStaff,
    promoteStaff,
    demoteStaff,
    removeStaff,
    searchStaff,
  } = useServerStaff();

  const [searchTerm, setSearchTerm] = useState("");
  const [groupFilter, setGroupFilter] = useState("all");
  const [memberToRemove, setMemberToRemove] = useState<StaffMember | null>(null);

  useStaffRefresh();

  useEffect(() => {
    fetchStaff();
  }, []);

  const searched = searchTerm.trim() ? searchStaff(searchTerm) : staffMembers;

  const filtered = searched.filter((member) =>
    groupFilter === "all" ? true : member.group === groupFilter
  );

  const groups = [...new Set(staffMembers.map((member) => member.group))];

  const tabs = [
    { value: "all", label: "Todos", count: searched.length },
    ...groups
      .map((group) => ({
        value: group,
        label: group,
        count: searched.filter((member) => member.group === group).length,
      }))
      .filter((tab) => tab.count > 0),
  ];

  const onlineCount = staffMembers.filter((member) => member.online).length;

  return (
    <>
      <Page>
        <Toolbar>
          <Search
            value={searchTerm}
            placeholder="Buscar membro do staff"
            onChange={(e) => setSearchTerm(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={tabs}
            value={groupFilter}
            onChange={setGroupFilter}
          />
          <ToolbarDivider />
          <ToolbarCount value={filtered.length} label="membros" />
        </Toolbar>

        <div className="flex h-[6.25rem] flex-shrink-0 items-stretch gap-[.75rem]">
          <Stat
            label="Membros do staff"
            icon={IconShieldHalfFilled}
            className="flex-1"
            value={staffMembers.length}
            hint="Somando todos os grupos"
          />
          <Stat
            label="Online agora"
            icon={IconWifi}
            className="flex-1"
            value={onlineCount}
            meter={{ value: onlineCount, max: staffMembers.length || 1 }}
          />
          <Stat
            label="Grupos ativos"
            icon={IconUsersGroup}
            className="flex-1"
            value={groups.length}
            hint="Com pelo menos um membro"
          />
        </div>

        <Table
          className="flex-1"
          columns={[
            { label: "Staff", className: "flex-[1.5]" },
            "Grupo",
            "Hierarquia",
            { label: "Status", className: "max-w-[7rem]" },
            { label: "Ações", className: "max-w-[10rem] text-right" },
          ]}
        >
          {loading && staffMembers.length === 0 ? (
            <Loading label="Carregando staff" />
          ) : error ? (
            <ErrorState message={error} />
          ) : filtered.length === 0 ? (
            <Empty
              icon={IconShieldHalfFilled}
              label="Nenhum membro do staff encontrado"
            />
          ) : (
            filtered.map((member) => {
              const nextRank = member.promoteTo;
              const previousRank = member.demoteTo;
              return (
                <Row key={member.id}>
                  <Cell className="flex-[1.5]">
                    <Avatar name={member.name} online={member.online} />
                    <CellStack
                      title={member.name}
                      subtitle={`Passaporte #${member.id}`}
                    />
                  </Cell>
                  <Cell>
                    <Badge color={GROUP_COLORS[member.group] || "#C7C7C7"}>
                      {member.group}
                    </Badge>
                  </Cell>
                  <Cell>
                    <Badge color={member.color || "#C7C7C7"}>
                      {member.hierarchy}
                    </Badge>
                  </Cell>
                  <Cell className="max-w-[7rem]">
                    <StatusBadge online={member.online} />
                  </Cell>
                  <Cell className="max-w-[10rem] justify-end">
                    {nextRank && (
                      <Button
                        size="sm"
                        variant="ghost"
                        title={`Promover para ${nextRank}`}
                        icon={
                          <IconArrowUp
                            stroke={2}
                            className="size-[.875rem] text-[#9CF35B]"
                          />
                        }
                        onClick={() =>
                          promoteStaff(member.id, member.group, nextRank)
                        }
                      />
                    )}
                    {previousRank && (
                      <Button
                        size="sm"
                        variant="ghost"
                        title={`Rebaixar para ${previousRank}`}
                        icon={
                          <IconArrowDown
                            stroke={2}
                            className="size-[.875rem] text-[#FFB951]"
                          />
                        }
                        onClick={() =>
                          demoteStaff(member.id, member.group, previousRank)
                        }
                      />
                    )}
                    <Button
                      size="sm"
                      variant="ghost"
                      title="Demitir do staff"
                      icon={
                        <IconUserOff
                          stroke={2}
                          className="size-[.875rem] text-[#FF4B4B]"
                        />
                      }
                      onClick={() => setMemberToRemove(member)}
                    />
                  </Cell>
                </Row>
              );
            })
          )}
        </Table>
      </Page>

      <Modal
        visible={!!memberToRemove}
        icon={IconUserOff}
        title="Demitir do staff"
        danger
        description={
          memberToRemove
            ? `Tem certeza que deseja demitir ${memberToRemove.name} (${memberToRemove.hierarchy}) do staff?`
            : undefined
        }
        footerLabels={{ cancel: "Cancelar", confirm: "Demitir" }}
        onClose={() => setMemberToRemove(null)}
        onConfirm={async () => {
          if (!memberToRemove) return;
          await removeStaff(memberToRemove.id, memberToRemove.group);
          setMemberToRemove(null);
        }}
      />
    </>
  );
}
