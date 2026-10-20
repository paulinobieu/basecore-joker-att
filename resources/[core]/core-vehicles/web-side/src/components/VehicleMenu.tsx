import ReactDOM from "react-dom";
import { useAppStore } from "@app/stores/store";
import { fetchNui } from "@app/utils/nui";

export function VehicleMenu() {
  const open = useAppStore((s) => s.vehicleMenuOpen);
  const backSeats = useAppStore((s) => s.vehicleMenuBackSeats);
  const currentSeat = useAppStore((s) => s.vehicleMenuCurrentSeat);

  const container = document.getElementById("v-menu");
  if (!container || !open) return null;

  function toggle(item: string) {
    fetchNui({ action: "toggleVehMenuItem", item }).then((r: any) => {
      if (item.startsWith("seat-") && r) {
        useAppStore.getState().openVehicleMenu(
          useAppStore.getState().vehicleMenuKey,
          backSeats,
          item.replace("seat-", "")
        );
      }
    });
  }

  const btn = (action: string, img: string, extraStyle?: React.CSSProperties) => (
    <div
      className="button"
      onClick={() => toggle(action)}
      style={{
        backgroundImage: `url(img/vehmenu/${img}.png)`,
        ...extraStyle,
      }}
    />
  );

  if (currentSeat === "P1") {
    return ReactDOM.createPortal(
      <>
        <div className="buttons" style={{ width: "fit-content" }}>
          {btn("lock", "key")}
          {btn("power", "power")}
          {btn("door-frontHood", "frontHood")}
          {btn("door-rearHood", "rearHood")}
        </div>
        <div className="buttons" style={{ width: "fit-content" }}>
          {btn("win-P1", "windowFrontLeft")}
          {btn("door-P1", "doorFrontLeft")}
          {btn("seat-P1", "seat-P1")}
          {btn("seat-P2", "seat-P2")}
          {btn("door-P2", "doorFrontRight")}
          {btn("win-P2", "windowFrontRight")}
        </div>
        <div
          className="buttons"
          style={backSeats ? { width: "fit-content" } : { display: "none", width: "fit-content" }}
        >
          {btn("win-P3", "windowRearLeft")}
          {btn("door-P3", "doorRearLeft")}
          {btn("seat-P3", "seat-P3")}
          {btn("seat-P4", "seat-P4")}
          {btn("door-P4", "doorRearRight")}
          {btn("win-P4", "windowRearRight")}
        </div>
      </>,
      container
    );
  }

  const isP2 = currentSeat === "P1" || currentSeat === "P2";
  const isP3 = currentSeat === "P1" || currentSeat === "P3";
  const isP4 = currentSeat === "P1" || currentSeat === "P4";

  return ReactDOM.createPortal(
    <>
      <div className="buttons" style={{ width: "fit-content" }}>
        {btn("seat-P1", "seat-P1")}
        {btn("seat-P2", "seat-P2")}
        {btn("door-P2", "doorFrontRight", isP2 ? undefined : { display: "none" })}
        {btn("win-P2", "windowFrontRight", isP2 ? undefined : { display: "none" })}
      </div>
      <div
        className="buttons"
        style={backSeats ? { width: "fit-content" } : { display: "none", width: "fit-content" }}
      >
        {btn("seat-P3", "seat-P3")}
        {btn("seat-P4", "seat-P4")}
        {btn("win-P3", "windowRearLeft", isP3 ? undefined : { display: "none" })}
        {btn("door-P3", "doorRearLeft", isP3 ? undefined : { display: "none" })}
        {btn("door-P4", "doorRearRight", isP4 ? undefined : { display: "none" })}
        {btn("win-P4", "windowRearRight", isP4 ? undefined : { display: "none" })}
      </div>
    </>,
    container
  );
}
