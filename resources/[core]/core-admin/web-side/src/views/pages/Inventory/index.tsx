import { usePagination } from "@app/hooks/usePagination";
import { ServerItem, useServerItems } from "@app/hooks/useServerItems";
import { IconPackages } from "@tabler/icons-react";
import { Button } from "@views/components/Button";
import { Card } from "@views/components/Card";
import { Field, Input, Search } from "@views/components/Field";
import { Modal } from "@views/components/Modal";
import { Page } from "@views/components/Page";
import { Pagination } from "@views/components/Pagination";
import { Empty, ErrorState, Loading } from "@views/components/State";
import { Tabs } from "@views/components/Tabs";
import { Toolbar, ToolbarCount, ToolbarDivider } from "@views/components/Toolbar";
import { useState } from "react";

const PAGE_SIZE = 32;
const CATEGORIES = ["all", "armamento", "usável", "comum"];

const FALLBACK_IMAGE =
  "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAwIiBoZWlnaHQ9IjEwMCIgdmlld0JveD0iMCAwIDEwMCAxMDAiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+Cjx0ZXh0IHg9IjUwIiB5PSI1NSIgZm9udC1mYW1pbHk9IkFyaWFsLCBzYW5zLXNlcmlmIiBmb250LXNpemU9IjQwIiBmaWxsPSIjZmZmZmZmIiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj4/PC90ZXh0Pgo8L3N2Zz4K";

export function Inventory() {
  const { items, loading, error, takeItem, searchItems } = useServerItems();

  const [searchItem, setSearchItem] = useState("");
  const [activeTab, setActiveTab] = useState("all");
  const [selectedItem, setSelectedItem] = useState<ServerItem | null>(null);
  const [itemQuantity, setItemQuantity] = useState("1");

  const byCategory = (item: ServerItem) =>
    activeTab === "all" || (item.type?.toLowerCase() || "") === activeTab;

  const filteredItems = (
    searchItem.trim() ? searchItems(searchItem) : items
  ).filter(byCategory);

  const { currentPage, totalPages, startIndex, endIndex, setPage } =
    usePagination({
      totalItems: filteredItems.length,
      itemsPerPage: PAGE_SIZE,
      resetKey: `${searchItem}-${activeTab}`,
    });

  const paginated = filteredItems.slice(startIndex, endIndex);

  const tabs = CATEGORIES.map((category) => ({
    value: category,
    label:
      category === "all"
        ? "Todos"
        : category.charAt(0).toUpperCase() + category.slice(1),
    count:
      category === "all"
        ? items.length
        : items.filter((item) => (item.type?.toLowerCase() || "") === category)
            .length,
  }));

  return (
    <>
      <Page>
        <Toolbar>
          <Search
            value={searchItem}
            placeholder="Buscar item pelo nome ou spawn"
            onChange={(e) => setSearchItem(e.target.value)}
            wrapperClassName="flex-1"
          />
          <Tabs
            fill={false}
            items={tabs}
            value={activeTab}
            onChange={setActiveTab}
          />
          <ToolbarDivider />
          <ToolbarCount value={filteredItems.length} label="itens" />
        </Toolbar>

        <div className="customScrollbar flex-1 overflow-y-auto">
          {loading ? (
            <Loading label="Carregando itens" />
          ) : error ? (
            <ErrorState message={error} />
          ) : paginated.length === 0 ? (
            <Empty
              icon={IconPackages}
              label="Nenhum item encontrado"
              hint={searchItem.trim() ? "Tente outro termo de busca" : undefined}
            />
          ) : (
            <div className="grid h-full grid-cols-8 grid-rows-4 gap-[.625rem] pr-1">
              {paginated.map((item) => (
                <Card key={item.id} detail={false} className="group p-[.625rem]">
                  <div className="flex w-full items-center justify-between">
                    <span
                      title={item.type || "Item"}
                      className="truncate font-black text-[.625rem] text-primaryColor uppercase"
                    >
                      {item.type || "Item"}
                    </span>
                    <span className="flex-shrink-0 font-semibold text-[.625rem] text-white/35">
                      {item.weight || 0}kg
                    </span>
                  </div>

                  <div className="relative my-[.375rem] flex h-[3.5rem] w-full items-center justify-center">
                    <img
                      src={item.image}
                      alt={item.name}
                      loading="lazy"
                      decoding="async"
                      className="size-[3.5rem] object-contain transition-opacity duration-300 group-hover:opacity-20"
                      onError={(e) => {
                        e.currentTarget.src = FALLBACK_IMAGE;
                      }}
                    />

                    <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
                      <Button
                        size="sm"
                        variant="accent"
                        className="w-[4.5rem] opacity-0 transition-opacity duration-300 group-hover:pointer-events-auto group-hover:opacity-100"
                        onClick={() => {
                          setSelectedItem(item);
                          setItemQuantity("1");
                        }}
                      >
                        Pegar
                      </Button>
                    </div>
                  </div>

                  <span
                    title={item.name}
                    className="w-full truncate text-center font-black text-[.6875rem] text-white uppercase"
                  >
                    {item.name}
                  </span>
                  <span className="w-full truncate text-center font-semibold text-[.625rem] text-white/30">
                    {item.spawn}
                  </span>
                </Card>
              ))}
            </div>
          )}
        </div>

        {filteredItems.length > 0 && (
          <Pagination
            page={currentPage}
            totalPages={totalPages}
            summary={`Página ${currentPage} de ${totalPages}`}
            onChange={setPage}
          />
        )}
      </Page>

      <Modal
        visible={!!selectedItem}
        icon={IconPackages}
        title={`Pegar ${selectedItem?.name || "item"}`}
        footerLabels={{ cancel: "Cancelar", confirm: "Pegar" }}
        onClose={() => setSelectedItem(null)}
        onConfirm={async () => {
          if (!selectedItem) return;
          const quantity = Number.parseInt(itemQuantity);
          if (!quantity || quantity <= 0) return;
          await takeItem(selectedItem, quantity);
          setSelectedItem(null);
          setItemQuantity("1");
        }}
      >
        <Field label="Quantidade">
          <Input
            type="number"
            min={1}
            value={itemQuantity}
            onChange={(e) => setItemQuantity(e.target.value)}
          />
        </Field>
      </Modal>
    </>
  );
}
