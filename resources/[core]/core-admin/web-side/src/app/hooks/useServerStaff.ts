import { useState } from "react";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { fetchNui } from "@app/utils/fetchNui";

export interface StaffMember {
  id: number;
  name: string;
  group: string;
  level: number;
  /** Cargo dentro da Hierarchy do grupo (ex.: "Supervisor"). */
  hierarchy: string;
  /** Posicao na Hierarchy; 1 é o topo. */
  hierarchyLevel: number;
  /** Cargo imediatamente acima, ou null se ja está no topo. */
  promoteTo: string | null;
  /** Cargo imediatamente abaixo, ou null se ja está na base. */
  demoteTo: string | null;
  online: boolean;
  source?: number;
  color: string;
  bgColor: string;
  canPromote: boolean;
  canDemote: boolean;
  canManage: boolean;
}

export const useServerStaff = () => {
  const [staffMembers, setStaffMembers] = useState<StaffMember[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useNuiEvent("receiveServerStaff", (data: StaffMember[]) => {
    setStaffMembers(data);
    setLoading(false);
    setError(null);
  });

  const fetchStaff = async () => {
    setLoading(true);
    setError(null);
    try {
      await fetchNui("getServerStaff");
    } catch (err) {
      setError("Erro ao buscar o staff");
      setLoading(false);
    }
  };

  const promoteStaff = async (targetUserId: number, currentGroup: string, newGroup: string) => {
    try {
      await fetchNui("promoteStaff", { targetUserId, currentGroup, newGroup });
      await fetchStaff();
    } catch (err) {
    }
  };

  // Promover e rebaixar sao a mesma operacao: definir o cargo do membro dentro
  // da hierarquia do grupo. O client so expoe o callback "promoteStaff", entao
  // os dois caminham por ele -- quem resolve o nivel é o servidor.
  const demoteStaff = async (targetUserId: number, currentGroup: string, newGroup: string) => {
    try {
      await fetchNui("promoteStaff", { targetUserId, currentGroup, newGroup });
      await fetchStaff();
    } catch (err) {
    }
  };

  const removeStaff = async (targetUserId: number, currentGroup: string) => {
    try {
      await fetchNui("removeStaff", { targetUserId, currentGroup });
      await fetchStaff();
    } catch (err) {
    }
  };

  const searchStaff = (searchTerm: string) => {
    if (!searchTerm.trim()) return staffMembers;
    const lowerTerm = searchTerm.toLowerCase();
    return staffMembers.filter(member =>
      member.name.toLowerCase().includes(lowerTerm) ||
      member.group.toLowerCase().includes(lowerTerm) ||
      (member.hierarchy ?? "").toLowerCase().includes(lowerTerm) ||
      String(member.id).includes(lowerTerm)
    );
  };

  return {
    staffMembers,
    loading,
    error,
    fetchStaff,
    promoteStaff,
    demoteStaff,
    removeStaff,
    searchStaff,
  };
};
