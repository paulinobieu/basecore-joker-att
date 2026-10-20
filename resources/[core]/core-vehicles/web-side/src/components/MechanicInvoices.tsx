import { useRef, useMemo, useState } from "react";
import { useAppStore } from "@app/stores/store";
import { fetchNui, sendNui } from "@app/utils/nui";
import { formatCurrency } from "@app/utils/format";
import { Modal } from "./Modal";

export function MechanicInvoices() {
  const invoicesData = useAppStore((s) => s.invoicesData);
  const currentVehicle = useAppStore((s) => s.invoicesCurrentVehicle);
  const close = useAppStore((s) => s.close);

  const cooldownRef = useRef(false);
  const [cancelPlate, setCancelPlate] = useState<string | null>(null);

  const sortedInvoices = useMemo(() => {
    if (!invoicesData) return [];
    const current: any[] = [];
    const rest: any[] = [];
    for (const plate in invoicesData) {
      const inv = invoicesData[plate]?.[1];
      if (inv) {
        const entry = { plate, invoice: inv };
        if (currentVehicle && currentVehicle === plate) {
          current.push(entry);
        } else {
          rest.push(entry);
        }
      }
    }
    return [...current, ...rest];
  }, [invoicesData, currentVehicle]);

  if (!invoicesData) return null;

  function tryCall(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "tryCallMechanicInvoice", plate }).then((r: any) => {
      if (r?.remove) {
        delete invoicesData[plate];
        useAppStore.getState().openInvoices(
          useAppStore.getState().invoicesId,
          { ...invoicesData },
          currentVehicle
        );
      }
      setTimeout(() => (cooldownRef.current = false), 800);
    });
  }

  function tryApply(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    fetchNui({ action: "tryApplyMechanicInvoice", plate }).then((r: any) => {
      if (r?.success) {
        delete invoicesData[plate];
        sendNui({ action: "close" });
        close();
      }
      setTimeout(() => (cooldownRef.current = false), 800);
    });
  }

  function tryCancel(plate: string) {
    if (cooldownRef.current) return;
    cooldownRef.current = true;
    setCancelPlate(null);
    delete invoicesData[plate];
    sendNui({ action: "tryCancelMechanicInvoice", plate });
    useAppStore.getState().openInvoices(
      useAppStore.getState().invoicesId,
      { ...invoicesData },
      currentVehicle
    );
    setTimeout(() => (cooldownRef.current = false), 800);
  }

  return (
    <>
      <div className="gp-gradient" />
      <div id="left">
        <div id="mechanic-menu">
          <div className="menu">
            <div className="title">PEDIDOS</div>
            <div className="subtitle">ATENDA OS PEDIDOS RECEBIDOS</div>
            <div id="invoices">
              {sortedInvoices.length === 0 ? (
                <div className="empty">
                  <i className="fa-solid fa-circle-xmark" /> Ops, parece que
                  ainda não existem pedidos!
                </div>
              ) : (
                sortedInvoices.map(({ plate, invoice }) => {
                  const isCurrent = currentVehicle === plate;
                  return (
                    <div
                      className="invoice"
                      key={plate}
                      id={`invoice-${plate}`}
                    >
                      <div className="info">
                        <div className="key">PLACA</div>
                        <div className="value">{plate}</div>
                      </div>
                      <div className="info">
                        <div className="key">MODELO</div>
                        <div className="value">{invoice[2]}</div>
                      </div>
                      <div className="info">
                        <div className="key">CONTATO</div>
                        <div className="value">{invoice[1]}</div>
                      </div>
                      <div className="info">
                        <div className="key">VALOR</div>
                        <div className="value">
                          {formatCurrency(invoice[3])}
                        </div>
                      </div>
                      <div className="buttons">
                        <div className="call" onClick={() => tryCall(plate)}>
                          CHAMAR
                        </div>
                        <div
                          className={`apply${isCurrent ? " currentVehicle" : ""}`}
                          onClick={() => tryApply(plate)}
                        >
                          APLICAR
                        </div>
                        <div
                          className="cancel"
                          onClick={() => setCancelPlate(plate)}
                        >
                          <i className="fa-solid fa-xmark" />
                        </div>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>
      </div>

      {cancelPlate && (
        <Modal
          title="CANCELAR PEDIDO"
          icon="fa-solid fa-file-circle-xmark"
          onConfirm={() => tryCancel(cancelPlate)}
          onCancel={() => setCancelPlate(null)}
        >
          <div className="text">
            Deseja realmente cancelar o pedido #{cancelPlate}?
          </div>
        </Modal>
      )}
    </>
  );
}
