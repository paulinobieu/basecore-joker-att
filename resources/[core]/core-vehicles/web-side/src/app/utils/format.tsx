export function formatCurrency(value: number, paymentType?: string): string {
  if (paymentType === "secondary") {
    return `◆ ${Number(parseInt(String(value))).toLocaleString("pt-BR")}`;
  }
  return `R$ ${Number(parseInt(String(value))).toLocaleString("pt-BR")}`;
}

export function formatCurrencyJSX(value: number, paymentType?: string) {
  if (paymentType === "secondary") {
    return (
      <>
        <i className="fa-regular fa-gem" aria-hidden="true" />
        {Number(parseInt(String(value))).toLocaleString("pt-BR")}
      </>
    );
  }
  return <>R$ {Number(parseInt(String(value))).toLocaleString("pt-BR")}</>;
}

// A URL base vem do config: config/config.ui.js -> window.VEHICLE_IMAGE_URL
// (carregado pelo index.html ANTES do bundle). Mude a linha no config e de
// restart no resource que muda em tudo, sem recompilar. O valor abaixo eh so
// o padrao caso o config nao defina nada.
function vehicleImageBase(): string {
  return (
    (typeof window !== "undefined" &&
      (window as unknown as { VEHICLE_IMAGE_URL?: string }).VEHICLE_IMAGE_URL) ||
    "https://cdn.corenetwork.dev/corevehicles"
  );
}

export function getVehicleImage(vehicleIndex: string): string {
  return `${vehicleImageBase()}/${vehicleIndex}.png`;
}

// O index vem em minusculo do banco. Se "<index>.png" nao existir no bucket,
// tenta a versao com a 1a letra maiuscula (addons ex.: Blu1200.png) antes de
// mostrar o placeholder. Sem loop: data-img-retry limita a 1 tentativa extra.
export function replaceMissingVehicleImage(
  e: React.SyntheticEvent<HTMLImageElement>
) {
  const img = e.currentTarget;
  const base = vehicleImageBase();
  const file = (img.src.split("/").pop() || "").replace(/\.png(\?.*)?$/i, "");
  const lower = file.toLowerCase();
  const capFirst = lower.charAt(0).toUpperCase() + lower.slice(1);

  if (!img.dataset.imgRetry && capFirst !== lower) {
    img.dataset.imgRetry = "1";
    img.src = `${base}/${capFirst}.png`;
    return;
  }

  img.onerror = null;
  img.src = `${base}/not_found.png`;
}

export function formatDateFromTime(
  timeMs: number,
  showHours?: boolean
): string {
  const d = new Date(timeMs);
  const dd = String(d.getDate()).padStart(2, "0");
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const yyyy = d.getFullYear();
  let result = `${dd}/${mm}/${yyyy}`;
  if (showHours) {
    const hh = String(d.getHours()).padStart(2, "0");
    const min = String(d.getMinutes()).padStart(2, "0");
    result += ` - ${hh}:${min}`;
  }
  return result;
}

export function formatSeconds(sec: number): string {
  const hrs = Math.floor(sec / 3600);
  const mins = Math.floor((sec % 3600) / 60);
  const secs = Math.floor(sec % 60);
  return `${hrs ? hrs + ":" : ""}${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
}

export function getRGBFromHex(
  hex: string
): [number, number, number] | null {
  const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
  hex = hex.replace(shorthandRegex, (_m, r, g, b) => r + r + g + g + b + b);
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result
    ? [
        parseInt(result[1], 16),
        parseInt(result[2], 16),
        parseInt(result[3], 16),
      ]
    : null;
}

const audioCache: Record<string, HTMLAudioElement> = {};
export function playSound(sound: string, volume: number) {
  let audio = audioCache[sound];
  if (!audio) {
    audio = new Audio();
    audio.src = `sounds/${sound}`;
    audio.load();
    audioCache[sound] = audio;
  }
  audio.volume = volume;
  audio.currentTime = 0;
  audio.play();
}
