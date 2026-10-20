import {
  IconBolt,
  IconBuildingCommunity,
  IconCar,
  IconHome2,
  IconLayoutDashboard,
  IconPackages,
  IconShieldHalfFilled,
  IconUsers,
} from "@tabler/icons-react";
import type { Icon } from "@tabler/icons-react";

export const routes = {
  home: "home",
  commands: "commands",
  players: "players",
  organizations: "organizations",
  inventory: "inventory",
  vehicles: "vehicles",
  properties: "properties",
  staff: "staff",
};

export interface NavigationEntry {
  route: string;
  label: string;
  subtitle: string;
  icon: Icon;
}

export const navigation: NavigationEntry[] = [
  {
    route: routes.home,
    label: "Dashboard",
    subtitle: "Visão geral do servidor",
    icon: IconLayoutDashboard,
  },
  {
    route: routes.commands,
    label: "Comandos",
    subtitle: "Ações rápidas",
    icon: IconBolt,
  },
  {
    route: routes.players,
    label: "Jogadores",
    subtitle: "Buscar e administrar players",
    icon: IconUsers,
  },
  {
    route: routes.organizations,
    label: "Organizações",
    subtitle: "Grupos e hierarquias",
    icon: IconBuildingCommunity,
  },
  {
    route: routes.inventory,
    label: "Inventário",
    subtitle: "Catálogo de itens",
    icon: IconPackages,
  },
  {
    route: routes.vehicles,
    label: "Veículos",
    subtitle: "Catálogo de veículos",
    icon: IconCar,
  },
  {
    route: routes.properties,
    label: "Propriedades",
    subtitle: "Imóveis e baús",
    icon: IconHome2,
  },
  {
    route: routes.staff,
    label: "Equipe Staff",
    subtitle: "Cargos administrativos",
    icon: IconShieldHalfFilled,
  },
];
