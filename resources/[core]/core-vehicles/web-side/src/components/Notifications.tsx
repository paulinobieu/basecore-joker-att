import { useEffect, useState } from "react";
import ReactDOM from "react-dom";
import { useAppStore } from "@app/stores/store";
import {
  getVehicleImage,
  replaceMissingVehicleImage,
  formatSeconds,
} from "@app/utils/format";

export function Notifications() {
  const lockNotifications = useAppStore((s) => s.lockNotifications);
  const testDrive = useAppStore((s) => s.testDrive);

  const container = document.getElementById("v-notify");
  if (!container) return null;

  return ReactDOM.createPortal(
    <>
      {lockNotifications.map((n) => (
        <LockNotifyItem key={n.id} lockState={n.lockState} model={n.model} id={n.id} />
      ))}
      {testDrive && (
        <div className="notify test-drive" id="test-drive">
          <img
            src={getVehicleImage(testDrive.model)}
            onError={replaceMissingVehicleImage}
          />
          <div className="text">TESTE DRIVE</div>
          <div className="timer" id="test-drive-timer">
            {formatSeconds(testDrive.seconds)}
          </div>
          <div className="tip">PRESSIONE [E] PARA ENCERRAR</div>
        </div>
      )}
    </>,
    container
  );
}

function LockNotifyItem({
  lockState,
  model,
  id,
}: {
  lockState: boolean;
  model: string;
  id: number;
}) {
  const [leaving, setLeaving] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setLeaving(true), 2000);
    return () => clearTimeout(t);
  }, []);

  return (
    <div className="notify" style={leaving ? { marginLeft: "-700px" } : undefined}>
      <img
        src={getVehicleImage(model)}
        onError={replaceMissingVehicleImage}
      />
      <div className="text">
        {lockState ? (
          <>
            <i className="fa-solid fa-lock" /> TRANCADO
          </>
        ) : (
          <>
            <i className="fa-solid fa-lock-open" /> DESTRANCADO
          </>
        )}
      </div>
    </div>
  );
}
