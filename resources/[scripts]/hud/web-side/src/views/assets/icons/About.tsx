import { memo } from "react";

export const AboutIcon = memo(({ size }: { size?: string }) => (
    <svg
        width={size || ".8125rem"}
        height={size || ".8125rem"}
        viewBox="0 0 13 13"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
    >
        <path
            d="M6.5 4.1H6.5048M6.5 8.9V5.9M12.5 6.5C12.5 9.8138 9.8138 12.5 6.5 12.5C3.1862 12.5 0.5 9.8138 0.5 6.5C0.5 3.1862 3.1862 0.5 6.5 0.5C9.8138 0.5 12.5 3.1862 12.5 6.5Z"
            stroke="white"
            stroke-miterlimit="10"
            stroke-linecap="round"
            stroke-linejoin="round"
        />
    </svg>
));
