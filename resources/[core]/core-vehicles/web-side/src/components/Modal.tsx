import { useEffect } from "react";
import ReactDOM from "react-dom";
import { useAppStore } from "@app/stores/store";

interface ModalProps {
  children: React.ReactNode;
  onConfirm: () => void;
  onCancel?: () => void;
  title?: string;
  icon?: string | React.ReactNode;
  confirmLabel?: string;
  cancelLabel?: string;
  showClose?: boolean;
  contentClassName?: string;
}

export function Modal({
  children,
  onConfirm,
  onCancel,
  title,
  icon = "fa-solid fa-circle-exclamation",
  confirmLabel = "CONFIRMAR",
  cancelLabel = "CANCELAR",
  showClose = false,
  contentClassName,
}: ModalProps) {
  const setModalOpen = useAppStore((s) => s.setModalOpen);

  const handleCancel = () => {
    if (onCancel) onCancel();
    else closeModal();
  };

  function closeModal() {
    setModalOpen(false);
    const root = document.getElementById("root");
    const manager = document.getElementById("v-manager");
    if (root) root.style.pointerEvents = "";
    if (manager) {
      manager.style.pointerEvents = "";
      manager.style.opacity = "1";
    }
  }

  useEffect(() => {
    setModalOpen(true);
    const root = document.getElementById("root");
    const manager = document.getElementById("v-manager");
    if (root) root.style.pointerEvents = "none";
    if (manager) {
      manager.style.pointerEvents = "none";
      manager.style.opacity = "0";
    }
    return () => {
      setModalOpen(false);
      if (root) root.style.pointerEvents = "";
      if (manager) {
        manager.style.pointerEvents = "";
        manager.style.opacity = "1";
      }
    };
  }, []);

  const container = document.getElementById("v-modals");
  if (!container) return null;

  return ReactDOM.createPortal(
    <div className="v-modal-frame" role="presentation">
      <div
        className={`v-modal-content${contentClassName ? ` ${contentClassName}` : ""}`}
        role="dialog"
        aria-modal="true"
        aria-label={title || "Confirmação"}
      >
        {title && (
          <div className="v-modal-header">
            <div className="v-modal-header-left">
              <div className="v-modal-header-icon">
                {typeof icon === "string" ? <i className={icon} /> : icon}
              </div>
              <div className="v-modal-header-title">{title}</div>
            </div>
            {showClose && (
              <button
                type="button"
                className="v-modal-close-btn"
                onClick={handleCancel}
              >
                <i className="fa-solid fa-xmark" />
              </button>
            )}
          </div>
        )}
        <div className="v-modal-body">{children}</div>
        <div className="v-modal-actions">
          <button
            type="button"
            className="v-modal-btn-cancel"
            onClick={handleCancel}
          >
            {cancelLabel}
          </button>
          <button
            type="button"
            className="v-modal-btn-confirm"
            onClick={onConfirm}
          >
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>,
    container
  );
}
