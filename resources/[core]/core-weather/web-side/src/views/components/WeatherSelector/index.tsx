import {
	WEATHERS_PER_PAGE,
	pageCount,
	useWeatherStore,
	weatherTypes,
} from "@app/stores/Weather";
import { IconChevronLeft, IconChevronRight } from "@tabler/icons-react";
import { cn } from "@app/utils";
import { useShallow } from "zustand/shallow";

export function WeatherSelector() {
	const { selectedWeather, page, setSelectedWeather, setPage, fetchApplyWeather } =
		useWeatherStore(
			useShallow((state) => ({
				selectedWeather: state.selectedWeather,
				page: state.page,
				setSelectedWeather: state.setSelectedWeather,
				setPage: state.setPage,
				fetchApplyWeather: state.fetchApplyWeather,
			})),
		);

	const pageItems = weatherTypes.slice(
		page * WEATHERS_PER_PAGE,
		(page + 1) * WEATHERS_PER_PAGE,
	);

	return (
		<section className="weather-section">
			<div className="section-header">
				<span className="section-label-text">Alterar Clima</span>
				{pageCount > 1 && (
					<div className="pager">
						<button
							type="button"
							className="pager-btn"
							disabled={page === 0}
							onClick={() => setPage(Math.max(0, page - 1))}
						>
							<IconChevronLeft size={16} stroke={2.5} />
						</button>
						<span className="pager-info">
							{page + 1}/{pageCount}
						</span>
						<button
							type="button"
							className="pager-btn"
							disabled={page === pageCount - 1}
							onClick={() => setPage(Math.min(pageCount - 1, page + 1))}
						>
							<IconChevronRight size={16} stroke={2.5} />
						</button>
					</div>
				)}
			</div>

			<div className="weather-grid" key={page}>
				{pageItems.map((weather) => (
					<button
						type="button"
						key={weather.id}
						className={cn(
							"weather-option",
							selectedWeather === weather.id && "selected",
						)}
						onClick={() => setSelectedWeather(weather.id)}
					>
						<weather.Icon size={30} stroke={2} />
						<span className="weather-option-name">{weather.name}</span>
					</button>
				))}
			</div>

			<button
				type="button"
				className="btn btn--primary"
				onClick={fetchApplyWeather}
			>
				Aplicar Clima
			</button>
		</section>
	);
}
