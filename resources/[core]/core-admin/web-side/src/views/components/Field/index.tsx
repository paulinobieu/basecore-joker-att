import { cn } from "@app/utils";
import { IconSearch } from "@tabler/icons-react";
import type {
  InputHTMLAttributes,
  ReactNode,
  SelectHTMLAttributes,
  TextareaHTMLAttributes,
} from "react";

const control =
  "filter-bar w-full rounded-[.25rem] border border-white/[.08] border-solid px-[.625rem] font-extrabold text-[.75rem] text-white outline-none transition-all duration-300 placeholder:text-[#EDEAE54D] focus:border-primaryColor/60 disabled:cursor-not-allowed disabled:opacity-50";

export function Label({ children }: { children: ReactNode }) {
  return (
    <span className="mb-1.5 block font-black text-[.6875rem] text-[#EDEAE580] uppercase">
      {children}
    </span>
  );
}

export function Hint({ children }: { children: ReactNode }) {
  return (
    <p className="mt-1.5 font-semibold text-[.6875rem] text-white/35 leading-snug">
      {children}
    </p>
  );
}

interface FieldProps {
  label?: ReactNode;
  hint?: ReactNode;
  className?: string;
  children: ReactNode;
}

export function Field({ label, hint, className, children }: FieldProps) {
  return (
    <div className={className}>
      {label && <Label>{label}</Label>}
      {children}
      {hint && <Hint>{hint}</Hint>}
    </div>
  );
}

export function Input({
  className,
  ...props
}: InputHTMLAttributes<HTMLInputElement>) {
  return <input {...props} className={cn(control, "h-[2.25rem]", className)} />;
}

export function Textarea({
  className,
  ...props
}: TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      {...props}
      className={cn(control, "resize-none py-2 leading-relaxed", className)}
    />
  );
}

export function Select({
  className,
  children,
  ...props
}: SelectHTMLAttributes<HTMLSelectElement>) {
  return (
    <select {...props} className={cn(control, "h-[2.25rem]", className)}>
      {children}
    </select>
  );
}

interface SearchProps extends InputHTMLAttributes<HTMLInputElement> {
  wrapperClassName?: string;
}

export function Search({ wrapperClassName, className, ...props }: SearchProps) {
  return (
    <div
      className={cn(
        "filter-bar flex h-[2.25rem] items-center gap-1.5 rounded-[.25rem] border border-white/[.08] border-solid px-[.5rem]",
        wrapperClassName
      )}
    >
      <IconSearch stroke={2} className="size-[.875rem] text-[#EDEAE54D]" />
      <input
        placeholder="Buscar"
        {...props}
        className={cn(
          "flex-1 bg-transparent font-extrabold text-[.75rem] text-white uppercase outline-none placeholder:text-[#EDEAE54D]",
          className
        )}
      />
    </div>
  );
}
