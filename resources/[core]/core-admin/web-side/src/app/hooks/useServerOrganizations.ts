import { useState } from "react";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { fetchNui } from "@app/utils/fetchNui";

export interface OrganizationMember {
  id: number;
  name: string;
  level: number;
  online: boolean;
  source?: number;
  role: string;
}

export interface ServerOrganization {
  id: number;
  name: string;
  leader: OrganizationMember | null;
  members: OrganizationMember[];
  totalMembers: number;
  onlineMembers: number;
}

export const useServerOrganizations = () => {
  const [organizations, setOrganizations] = useState<ServerOrganization[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedOrganization, setSelectedOrganization] = useState<ServerOrganization | null>(null);
  const [organizationMembers, setOrganizationMembers] = useState<OrganizationMember[]>([]);

  useNuiEvent("receiveServerOrganizations", (data: ServerOrganization[]) => {
    if (data && Array.isArray(data)) {
      setOrganizations(data);
      setLoading(false);
      setError(null);
    } else {
      setError("Dados inválidos recebidos do servidor");
      setLoading(false);
    }
  });

  useNuiEvent("receiveOrganizationMembers", (data: { groupName: string; members: OrganizationMember[] }) => {
    setOrganizationMembers(data.members);
    setLoading(false);
    setError(null);
  });

  const fetchOrganizations = async () => {
    setLoading(true);
    setError(null);
    try {
      await fetchNui("getServerOrganizations");
    } catch (error) {
      setError("Erro ao buscar organizações");
      setLoading(false);
    }
  };

  const fetchOrganizationMembers = async (groupName: string) => {
    setLoading(true);
    setError(null);
    await fetchNui("getOrganizationMembers", { groupName });
  };

  const selectOrganization = async (organization: ServerOrganization) => {
    setSelectedOrganization(organization);
    await fetchOrganizationMembers(organization.name);
  };

  const searchOrganizations = (searchTerm: string) => {
    if (!searchTerm.trim()) return organizations;
    const lowerTerm = searchTerm.toLowerCase();
    return organizations.filter(org =>
      org.name.toLowerCase().includes(lowerTerm) ||
      (org.leader && org.leader.name.toLowerCase().includes(lowerTerm))
    );
  };

  return {
    organizations,
    loading,
    error,
    selectedOrganization,
    organizationMembers,
    fetchOrganizations,
    fetchOrganizationMembers,
    selectOrganization,
    searchOrganizations,
  };
};
