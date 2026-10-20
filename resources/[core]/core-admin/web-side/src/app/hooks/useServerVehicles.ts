import { useState } from "react";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { fetchNui } from "@app/utils/fetchNui";

export interface ServerVehicle {
  id?: number;
  name: string;
  spawn: string;
  image: string;
  favorite: boolean;
  attributes: {
    engine: number;
    body: number;
    gas: number;
    trunk: number;
  };
}

export interface PersonalVehicle extends ServerVehicle {
  plate: string;
}

export const useServerVehicles = () => {
  const [vehicles, setVehicles] = useState<ServerVehicle[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [totalVehicles, setTotalVehicles] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [currentSearch, setCurrentSearch] = useState("");
  const [currentCategory, setCurrentCategory] = useState("all");

  const VEHICLES_PER_PAGE = 24;

  const fetchVehicles = async (page: number = 1, searchTerm: string = "", category: string = "all") => {
    setLoading(true);
    setError(null);
    try {
      await fetchNui("getServerVehicles", {
        page,
        limit: VEHICLES_PER_PAGE,
        searchTerm,
        category
      });

      setCurrentPage(page);
      setCurrentSearch(searchTerm);
      setCurrentCategory(category);
    } catch (err) {
      setError("Erro ao buscar veículos");
    } finally {
      setLoading(false);
    }
  };

  const loadMoreVehicles = async () => {
    if (hasMore && !loading) {
      await fetchVehicles(currentPage + 1, currentSearch, currentCategory);
    }
  };

  const goToPage = async (page: number) => {
    if (!loading) {
      await fetchVehicles(page, currentSearch, currentCategory);
    }
  };

  const spawnVehicle = async (vehicle: ServerVehicle) => {
    try {
      await fetchNui("spawnVehicle", { vehicle });
    } catch (err) {
    }
  };

  const addVehicleToUser = async (vehicle: ServerVehicle, userId: number, duration?: number) => {
    try {
      await fetchNui("addVehicleToUser", { vehicle, userId, duration });
    } catch (err) {
    }
  };

  useNuiEvent("receiveServerVehicles", (data: { vehicles: ServerVehicle[], total: number, page: number, hasMore: boolean }) => {
    // Substitui a página atual ao invés de acumular (paginação por página, sem infinite scroll)
    setVehicles(data.vehicles);
    setTotalVehicles(data.total);
    setHasMore(data.hasMore);
    setLoading(false);
  });


  return {
    vehicles,
    loading,
    error,
    fetchVehicles,
    loadMoreVehicles,
    goToPage,
    spawnVehicle,
    addVehicleToUser,
    totalVehicles,
    hasMore,
    currentPage,
    pageSize: VEHICLES_PER_PAGE,
  };
};
