import { useEffect } from "react";
import { useVisibility } from "../providers/VisibilityProvider";
import { fetchNui } from "../utils/fetchNui";

export const useAutoRefresh = (
  dataFetchers: (() => void)[],
  dependencies: any[] = []
) => {
  const { visible } = useVisibility();

  useEffect(() => {
    if (visible) {
      dataFetchers.forEach((fetcher) => {
        fetcher();
      });
    }
  }, [visible, ...dependencies]);
};

export const usePlayersRefresh = () => {
  useAutoRefresh([() => fetchNui("getPlayers", { searchTerm: "" })]);
};

export const useDashboardRefresh = () => {
  useAutoRefresh([
    () => fetchNui("getNotifications"),
    () => fetchNui("getOnlinePlayers"),
    () => fetchNui("getServerData"),
    () => fetchNui("getChatMessages"),
    () => fetchNui("getUserInfo"),
    // Alimentam os paineis de distribuicao (profissoes, orgs e staff em servico).
    () => fetchNui("getPlayers", ""),
    () => fetchNui("getServerStaff"),
    () => fetchNui("getServerOrganizations"),
  ]);
};

export const useItemsRefresh = () => {
  useAutoRefresh([() => fetchNui("getServerItems")]);
};

export const useVehiclesRefresh = () => {
  useAutoRefresh([() => fetchNui("getServerVehicles", { page: 1, limit: 1200, searchTerm: "", category: "all" })]);
};

export const useOrganizationsRefresh = () => {
  useAutoRefresh([() => fetchNui("getServerOrganizations")]);
};

export const useStaffRefresh = () => {
  useAutoRefresh([() => fetchNui("getServerStaff")]);
};
