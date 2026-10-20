export function EmptyIcon() {
    return (
        <svg
            width="1.5rem"
            height="1.5rem"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            className="absolute z-10"
        >
            <g filter="url(#filter0_d_243_446)">
                <path
                    d="M5.15679 6.19081C5.52339 5.81328 5.95861 5.5138 6.43759 5.30948C6.91658 5.10516 7.42996 5 7.94842 5C8.46687 5 8.98025 5.10516 9.45924 5.30948C9.93823 5.5138 10.3734 5.81328 10.74 6.19081L12.0001 7.48838L13.2601 6.19081C14.0006 5.42837 15.0049 5.00008 16.052 5.00016C17.0992 5.00024 18.1034 5.42869 18.8438 6.19125C19.5842 6.95381 20.0001 7.98802 20 9.06635C19.9999 10.1447 19.5839 11.1788 18.8434 11.9413L17.5833 13.238L17.5946 13.2495L12.0113 19L12.0001 18.9884L11.9888 19L6.40558 13.2495L6.41683 13.238L5.15679 11.9413C4.79005 11.5637 4.49913 11.1155 4.30065 10.6222C4.10216 10.1288 4 9.60005 4 9.06604C4 8.53203 4.10216 8.00326 4.30065 7.50992C4.49913 7.01658 4.79005 6.56834 5.15679 6.19081Z"
                    stroke="white"
                    stroke-width="1.2"
                    stroke-linejoin="round"
                />
            </g>
            <defs>
                <filter
                    id="filter0_d_243_446"
                    x="0.399902"
                    y="2.40002"
                    width="23.2002"
                    height="21.2"
                    filterUnits="userSpaceOnUse"
                    color-interpolation-filters="sRGB"
                >
                    <feFlood flood-opacity="0" result="BackgroundImageFix" />
                    <feColorMatrix
                        in="SourceAlpha"
                        type="matrix"
                        values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
                        result="hardAlpha"
                    />
                    <feOffset dy="1" />
                    <feGaussianBlur stdDeviation="1.5" />
                    <feComposite in2="hardAlpha" operator="out" />
                    <feColorMatrix
                        type="matrix"
                        values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.6 0"
                    />
                    <feBlend
                        mode="normal"
                        in2="BackgroundImageFix"
                        result="effect1_dropShadow_243_446"
                    />
                    <feBlend
                        mode="normal"
                        in="SourceGraphic"
                        in2="effect1_dropShadow_243_446"
                        result="shape"
                    />
                </filter>
            </defs>
        </svg>
    );
}
