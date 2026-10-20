import { useRef, useState, useEffect } from "react";

interface CustomSelectProps {
  options: { value: string; label: string }[];
  selected?: string;
  onChange: (value: string) => void;
}

export function CustomSelect({ options, selected, onChange }: CustomSelectProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  const current = options.find((o) => o.value === selected) || options[0];

  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("click", handleClick);
    return () => document.removeEventListener("click", handleClick);
  }, []);

  return (
    <div className="select" ref={ref}>
      <select
        aria-hidden="true"
        style={{ display: "none" }}
        tabIndex={-1}
        value={current?.value}
        onChange={() => undefined}
      >
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
      <div
        className={`select-selected${open ? " select-arrow-active" : ""}`}
        onClick={(e) => {
          e.stopPropagation();
          setOpen(!open);
        }}
      >
        {current?.label}
      </div>
      <div className={`select-items${open ? "" : " select-hide"}`}>
        {options.map((o) => (
          <div
            key={o.value}
            className={o.value === current?.value ? "same-as-selected" : ""}
            onClick={() => {
              onChange(o.value);
              setOpen(false);
            }}
          >
            {o.label}
          </div>
        ))}
      </div>
    </div>
  );
}
