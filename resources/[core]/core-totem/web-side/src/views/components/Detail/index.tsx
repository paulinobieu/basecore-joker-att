export function Detail() {
	return (
		<div className="pointer-events-none absolute inset-0 z-20 rounded-[.3125rem]">
			<div className="relative h-full w-full rounded-[.3125rem]">
				<div className="absolute top-5 h-px w-full bg-[#d9d9d9]/[.03] transition-colors duration-500 group-hover:bg-[#d9d9d9]/[.13]" />
				<div className="absolute left-5 h-full w-px bg-[#d9d9d9]/[.03] transition-colors duration-500 group-hover:bg-[#d9d9d9]/[.13]" />
				<div className="absolute right-5 h-full w-px bg-[#d9d9d9]/[.03] transition-colors duration-500 group-hover:bg-[#d9d9d9]/[.13]" />
				<div className="absolute bottom-5 h-px w-full bg-[#d9d9d9]/[.03] transition-colors duration-500 group-hover:bg-[#d9d9d9]/[.13]" />
				<span className="detail-dot left-[1.0625rem] top-[1.0625rem]" />
				<span className="detail-dot right-[1.0625rem] top-[1.0625rem]" />
				<span className="detail-dot bottom-[1.0625rem] left-[1.0625rem]" />
				<span className="detail-dot bottom-[1.0625rem] right-[1.0625rem]" />
			</div>
		</div>
	);
}
