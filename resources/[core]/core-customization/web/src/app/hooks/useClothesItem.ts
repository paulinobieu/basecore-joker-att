import { activeClothesItem, useClothesStore } from "@app/stores/Clothes";
import { useConfigStore } from "@app/stores/Config";
import { type TextureVariant, useTexturesStore } from "@app/stores/Textures";
import { clamp } from "@app/utils/misc";
import { requestPreview } from "@app/utils/updateClient";
import { useCallback, useMemo } from "react";

/** Referência estável: um `{}` novo por render invalidaria o seletor. */
const EMPTY: Record<string, TextureVariant> = {};

/**
 * Navegação da peça em edição.
 *
 * Os índices vêm do catálogo, não de um contador: modelos bloqueados
 * pelo servidor simplesmente não estão lá, e andar de um em um tem que
 * pular por cima deles.
 */
export function useClothesItem() {
	const pedType = useConfigStore((state) => state.pedType);
	const activeItem = useClothesStore((state) => state.activeItem);
	const entry = useClothesStore(activeClothesItem);

	const setItem = useClothesStore((state) => state.setItem);
	const setTexture = useClothesStore((state) => state.setTexture);

	const variants = useTexturesStore(
		(state) => state.catalog[pedType]?.[activeItem] ?? EMPTY,
	);

	const indexes = useMemo(
		() =>
			Object.keys(variants)
				.map(Number)
				.sort((a, b) => a - b),
		[variants],
	);

	const item = entry?.item ?? 0;
	const texture = entry?.texture ?? 0;
	const maxTexture = variants[String(item)]?.max ?? 0;

	const applyItem = useCallback(
		(value: number) => {
			setItem(value);
			requestPreview();
		},
		[setItem],
	);

	const applyTexture = useCallback(
		(value: number) => {
			setTexture(value);
			requestPreview();
		},
		[setTexture],
	);

	/** Anda pela lista de índices disponíveis, dando a volta nas pontas. */
	const stepItem = useCallback(
		(delta: number) => {
			if (indexes.length === 0) return;

			const position = indexes.indexOf(item);
			const from = position < 0 ? 0 : position;
			const next = (from + delta + indexes.length * 2) % indexes.length;

			applyItem(indexes[next]);
		},
		[indexes, item, applyItem],
	);

	/**
	 * Digitar um número solta qualquer valor no campo; o mais próximo
	 * disponível é o que o jogador quis dizer.
	 */
	const selectItem = useCallback(
		(value: number) => {
			if (indexes.length === 0) return;

			if (variants[String(value)]) return applyItem(value);

			const nearest = indexes.reduce((best, current) =>
				Math.abs(current - value) < Math.abs(best - value) ? current : best,
			);

			applyItem(nearest);
		},
		[indexes, variants, applyItem],
	);

	const stepTexture = useCallback(
		(delta: number) => {
			const total = maxTexture + 1;

			applyTexture((texture + delta + total * 2) % total);
		},
		[maxTexture, texture, applyTexture],
	);

	const selectTexture = useCallback(
		(value: number) => applyTexture(clamp(value, 0, maxTexture)),
		[maxTexture, applyTexture],
	);

	return {
		entry,
		variants,
		indexes,
		item,
		texture,
		maxTexture,
		stepItem,
		selectItem,
		stepTexture,
		selectTexture,
	};
}
