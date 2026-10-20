import { useState } from "react";
import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { fetchNui } from "@app/utils/fetchNui";
import { useAutoRefresh } from "@app/hooks/useAutoRefresh";

export interface ServerItem {
  id: number;
  name: string;
  spawn: string;
  image: string;
  weight?: number;
  category?: string;
  type?: string;
}

export const useServerItems = () => {
  const [items, setItems] = useState<ServerItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useNuiEvent("receiveServerItems", (data: ServerItem[]) => {
    setItems(data);
    setLoading(false);
    setError(null);
  });

  const fetchItems = async () => {
    setLoading(true);
    setError(null);
    try {
      await fetchNui("getServerItems");
    } catch (err) {
      setError("Erro ao buscar itens");
      setLoading(false);
    }
  };

  useAutoRefresh([fetchItems]);

  const takeItem = async (item: ServerItem, quantity: number) => {
    try {
      await fetchNui("takeItem", {
        item: item.spawn,
        quantity: quantity
      });
    } catch (error) {
    }
  };

  const getItemsByCategory = (category: string) => {
    return items.filter(item => item.category === category);
  };

  const searchItems = (searchTerm: string) => {
    if (!searchTerm.trim()) return items;
    return items.filter(item =>
      item.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.spawn.toLowerCase().includes(searchTerm.toLowerCase())
    );
  };

  const getCategories = () => {
    const categories = [...new Set(items.map(item => item.category).filter(Boolean))];
    return categories as string[];
  };

  return {
    items,
    loading,
    error,
    fetchItems,
    takeItem,
    getItemsByCategory,
    searchItems,
    getCategories
  };
};
