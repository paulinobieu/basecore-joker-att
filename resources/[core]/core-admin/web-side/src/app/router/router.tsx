import { routes } from "@app/router/routes";
import { Layout } from "@views/layout";
import { Commands } from "@views/pages/Commands";
import { Estate } from "@views/pages/Estate";
import { Home } from "@views/pages/Home";
import { Inventory } from "@views/pages/Inventory";
import { Organizations } from "@views/pages/Organizations";
import { Players } from "@views/pages/Players";
import { Staff } from "@views/pages/Staff";
import { Vehicles } from "@views/pages/Vehicles";
import { Navigate, Route, Routes } from "react-router-dom";

export function Router() {
  return (
    <Routes>
      <Route element={<Layout />} path="/">
        <Route index element={<Navigate to={routes.home} replace />} />
        <Route element={<Home />} path={routes.home} />
        <Route element={<Commands />} path={routes.commands} />
        <Route element={<Players />} path={routes.players} />
        <Route element={<Organizations />} path={routes.organizations} />
        <Route element={<Inventory />} path={routes.inventory} />
        <Route element={<Vehicles />} path={routes.vehicles} />
        <Route element={<Estate />} path={routes.properties} />
        <Route element={<Staff />} path={routes.staff} />
        <Route path="*" element={<Navigate to={routes.home} replace />} />
      </Route>
    </Routes>
  );
}
