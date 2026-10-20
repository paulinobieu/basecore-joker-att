import { useWeatherStore } from "@app/stores/Weather";
import { SkyTimeSlider } from "@views/components/SkyTimeSlider";
import { useShallow } from "zustand/shallow";

export function TimeControls() {
	const { fetchApplyTime, fetchResetSync } = useWeatherStore(
		useShallow((state) => ({
			fetchApplyTime: state.fetchApplyTime,
			fetchResetSync: state.fetchResetSync,
		})),
	);

	return (
		<section className="weather-section">
			<span className="section-label-text">Alterar Horário</span>

			<SkyTimeSlider />

			<div className="time-actions">
				<button
					type="button"
					className="btn btn--primary"
					onClick={fetchApplyTime}
				>
					Aplicar Horário
				</button>

				<button
					type="button"
					className="btn btn--ghost"
					onClick={fetchResetSync}
				>
					Sincronizar com a Cidade
				</button>
			</div>
		</section>
	);
}
