import { useVehiclesRefresh } from "@app/hooks/useAutoRefresh";
import { useServerVehicles } from "@app/hooks/useServerVehicles";
import { IconCar, IconStarFilled } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Search } from "@views/components/Field";
import { Page } from "@views/components/Page";
import { Pagination } from "@views/components/Pagination";
import { Empty, ErrorState, Loading } from "@views/components/State";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useEffect, useState } from "react";

const TABS = [
  { value: "carros", label: "Carros" },
  { value: "motos", label: "Motos" },
  { value: "caminhoes", label: "Caminhões" },
  { value: "aeronaves", label: "Aeronaves" },
];

const FALLBACK_IMAGE =
  "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+Cjx0ZXh0IHg9IjUwIiB5PSI1NSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjQwIiBmaWxsPSIjZmZmZmZmIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4/PC90ZXh0Pgo8L3N2Zz4K";

export function Vehicles() {
  const {
    vehicles,
    loading,
    error,
    spawnVehicle,
    fetchVehicles,
    goToPage,
    totalVehicles,
    currentPage,
    pageSize,
  } = useServerVehicles();

  const [searchTerm, setSearchTerm] = useState("");
  const [activeTab, setActiveTab] = useState("carros");

  useVehiclesRefresh();

  useEffect(() => {
    fetchVehicles(1, searchTerm, activeTab);
  }, [searchTerm, activeTab]);

  const totalPages = Math.max(1, Math.ceil(totalVehicles / pageSize));
  const safePage = Math.min(Math.max(1, currentPage), totalPages);

  return (
    <Page>
      <Toolbar>
        <Search
          value={searchTerm}
          placeholder="Buscar veículo pelo nome ou spawn"
          onChange={(e) => setSearchTerm(e.target.value)}
          wrapperClassName="flex-1"
        />
        <Tabs
          fill={false}
          items={TABS}
          value={activeTab}
          onChange={setActiveTab}
        />
        <ToolbarDivider />
        <ToolbarCount value={totalVehicles} label="veículos" />
      </Toolbar>

      <div className="customScrollbar flex-1 overflow-y-auto">
        {loading ? (
          <Loading label="Carregando veículos" />
        ) : error ? (
          <ErrorState message={error} />
        ) : vehicles.length === 0 ? (
          <Empty
            icon={IconCar}
            label="Nenhum veículo encontrado"
            hint={searchTerm.trim() ? "Tente outro termo de busca" : undefined}
          />
        ) : (
          <div className="grid h-full grid-cols-6 grid-rows-4 gap-[.625rem] pr-1">
            {vehicles.map((vehicle) => (
              <Card key={vehicle.spawn} detail={false} className="group p-[.625rem]">
                <div className="flex w-full items-center justify-between gap-1">
                  <span
                    title={vehicle.name}
                    className="truncate font-black text-[.6875rem] text-white uppercase"
                  >
                    {vehicle.name}
                  </span>
                  {vehicle.favorite && (
                    <IconStarFilled className="size-[.6875rem] flex-shrink-0 text-[#FFD700]" />
                  )}
                </div>

                <div className="relative my-[.375rem] flex h-[4rem] w-full items-center justify-center">
                  <img
                    src={vehicle.image}
                    alt={vehicle.name}
                    loading="lazy"
                    decoding="async"
                    className="h-full w-full object-contain transition-opacity duration-300 group-hover:opacity-20"
                    onError={(e) => {
                      e.currentTarget.src = FALLBACK_IMAGE;
                    }}
                  />

                  <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                    <Button
                      size="sm"
                      variant="accent"
                      className="w-[5rem] opacity-0 transition-opacity duration-300 group-hover:pointer-events-auto group-hover:opacity-100"
                      onClick={() => spawnVehicle(vehicle)}
                    >
                      Spawnar
                    </Button>
                  </div>
                </div>

                <span className="w-full truncate text-center font-semibold text-[.625rem] text-white/30">
                  {vehicle.spawn}
                </span>
              </Card>
            ))}
          </div>
        )}
      </div>

      {totalVehicles > 0 && (
        <Pagination
          page={safePage}
          totalPages={totalPages}
          summary={`Página ${safePage} de ${totalPages}`}
          onChange={goToPage}
        />
      )}
    </Page>
  );
}
