import { useEffect, useState } from "react";
import {
  IconCrown,
  IconDiamond,
  IconUser,
  IconWeight,
} from "@tabler/icons-react";

import { useProfile } from "@/stores/useNui";

const imageCache = new Map<string, string>();
const MAX_CACHED_IMAGES = 8;

function isDirectImageUrl(value: string) {
  return /^(https?:|data:|blob:)/i.test(value);
}

/** Acima disso o pixel é do personagem, não do fundo. */
const BACKDROP_CEILING = 40;
/** Abaixo disso some por completo; entre os dois, desbota para não serrilhar. */
const BACKDROP_FLOOR = 14;

/**
 * O mugshot que o jogo entrega vem com fundo preto opaco, então o painel
 * translúcido atrás dele não aparecia. Como a imagem já passa por canvas para
 * virar data URL, o recorte sai de graça aqui: pixel escuro o bastante vira
 * transparente, com uma rampa curta na borda para o contorno não serrilhar.
 *
 * `getImageData` estoura se a textura tiver contaminado o canvas; nesse caso a
 * conversão segue sem recorte em vez de perder a foto.
 */
function knockOutBackdrop(
  context: CanvasRenderingContext2D,
  width: number,
  height: number,
) {
  let frame: ImageData;

  try {
    frame = context.getImageData(0, 0, width, height);
  } catch {
    return;
  }

  const pixels = frame.data;

  for (let index = 0; index < pixels.length; index += 4) {
    const luminance =
      pixels[index] * 0.299 +
      pixels[index + 1] * 0.587 +
      pixels[index + 2] * 0.114;

    if (luminance >= BACKDROP_CEILING) continue;

    if (luminance <= BACKDROP_FLOOR) {
      pixels[index + 3] = 0;
      continue;
    }

    const ramp =
      (luminance - BACKDROP_FLOOR) / (BACKDROP_CEILING - BACKDROP_FLOOR);
    pixels[index + 3] = Math.round(pixels[index + 3] * ramp);
  }

  context.putImageData(frame, 0, 0);
}

function getBase64Image(
  src: string,
  outputFormat = "image/png",
): Promise<string> {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.crossOrigin = "Anonymous";

    image.onload = () => {
      const canvas = document.createElement("canvas");
      canvas.width = image.naturalWidth;
      canvas.height = image.naturalHeight;
      const context = canvas.getContext("2d");
      if (!context) {
        reject(new Error("Canvas 2D context is unavailable"));
        return;
      }

      context.drawImage(image, 0, 0);
      knockOutBackdrop(context, canvas.width, canvas.height);
      resolve(canvas.toDataURL(outputFormat));
    };

    image.onerror = reject;
    image.src = src;
  });
}

async function convertProfileImage(mugShotTxd: string) {
  if (!mugShotTxd || isDirectImageUrl(mugShotTxd)) return mugShotTxd;

  const cachedImage = imageCache.get(mugShotTxd);
  if (cachedImage) return cachedImage;

  const temporaryUrl = `https://nui-img/${mugShotTxd}/${mugShotTxd}`;
  const dataUrl = await getBase64Image(temporaryUrl);

  if (imageCache.size >= MAX_CACHED_IMAGES) {
    const oldestKey = imageCache.keys().next().value;
    if (oldestKey) imageCache.delete(oldestKey);
  }

  imageCache.set(mugShotTxd, dataUrl);
  return dataUrl;
}

export function Profile() {
  const profile = useProfile((state) => state.current);
  const [imageUrl, setImageUrl] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setImageUrl(null);

    if (!profile.image) return;

    void convertProfileImage(profile.image)
      .then((convertedImage) => {
        if (!cancelled) setImageUrl(convertedImage);
      })
      .catch(() => {
        if (!cancelled) setImageUrl(null);
      });

    return () => {
      cancelled = true;
    };
  }, [profile.image]);

  return (
    <header className="inventory-profile">
      <div className="inventory-profile-main">
        <div className="inventory-avatar">
          {imageUrl ? (
            <img
              src={imageUrl}
              alt={`Foto de ${profile.name}`}
              className="inventory-avatar-image"
              onError={() => setImageUrl(null)}
            />
          ) : (
            <IconUser
              aria-label="Perfil sem foto"
              className="inventory-avatar-placeholder"
              role="img"
              stroke={1.4}
            />
          )}
        </div>
        <div className="inventory-identity">
          <div className="inventory-name-block">
            <span className="inventory-label">Nome</span>
            <h1 className="inventory-profile-name">{profile.name}</h1>
          </div>
          <div className="inventory-profile-details">
            <div>
              <span className="inventory-label">Identidade</span>
              <strong>{profile.id}</strong>
            </div>
            <div>
              <span className="inventory-label">VIP</span>
              <strong>
                {profile.vip?.current ? (
                  <>
                    <IconCrown aria-hidden="true" stroke={1.8} />
                    {profile.vip.current}
                  </>
                ) : (
                  "Cidadão"
                )}
              </strong>
            </div>
          </div>
        </div>
      </div>

      <div className="inventory-account">
        <div className="inventory-account-item">
          <IconDiamond aria-hidden="true" stroke={1.8} />
          <strong>{(profile.gens ?? 0).toLocaleString("pt-BR")}</strong>
        </div>
        <div className="inventory-account-item inventory-account-weight">
          <IconWeight aria-hidden="true" stroke={1.8} />
          <strong>{profile.weight}</strong>
          <span>/ {profile.maxWeight} kg</span>
        </div>
      </div>
    </header>
  );
}
