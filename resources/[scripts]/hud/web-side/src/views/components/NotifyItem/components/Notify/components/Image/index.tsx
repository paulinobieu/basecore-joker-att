import { useImageValidation } from "@app/hooks/useImageValidation";

import FallbackImage from "@views/assets/images/fallback-weapon.webp";

export function Image({
    action,
    image,
}: {
    action: "add" | "remove";
    image: string;
}) {
    const { imageUrl, isImageValid } = useImageValidation(image);

    return (
        <div className="-left-[1.625rem] absolute flex size-[3.75rem] items-center justify-center">
            <img
                src={isImageValid ? imageUrl : FallbackImage}
                alt=""
                className="absolute z-10 size-10 object-contain"
            />
            <svg
                width="3.75rem"
                height="3.75rem"
                viewBox="0 0 60 60"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path
                    d="M25.7574 4.24264C28.1005 1.8995 31.8995 1.8995 34.2426 4.24264L55.7574 25.7574C58.1005 28.1005 58.1005 31.8995 55.7574 34.2426L34.2426 55.7574C31.8995 58.1005 28.1005 58.1005 25.7574 55.7574L4.24264 34.2426C1.8995 31.8995 1.8995 28.1005 4.24264 25.7574L25.7574 4.24264Z"
                    fill="#151515"
                    fill-opacity="0.7"
                />
                <path
                    d="M25.7574 4.24264C28.1005 1.8995 31.8995 1.8995 34.2426 4.24264L55.7574 25.7574C58.1005 28.1005 58.1005 31.8995 55.7574 34.2426L34.2426 55.7574C31.8995 58.1005 28.1005 58.1005 25.7574 55.7574L4.24264 34.2426C1.8995 31.8995 1.8995 28.1005 4.24264 25.7574L25.7574 4.24264Z"
                    fill={`url(#paint0_linear_208_73-${action})`}
                    fill-opacity="0.2"
                />
                <path
                    d="M27.1717 7.32794C28.7338 5.76585 31.2664 5.76584 32.8285 7.32794L52.6717 27.1711C54.2338 28.7332 54.2338 31.2658 52.6717 32.8279L32.8285 52.6711C31.2664 54.2332 28.7338 54.2332 27.1717 52.6711L7.32855 32.8279C5.76646 31.2658 5.76645 28.7332 7.32855 27.1711L27.1717 7.32794Z"
                    fill="#151515"
                    fill-opacity="0.7"
                />
                <path
                    d="M27.1717 7.32794C28.7338 5.76585 31.2664 5.76584 32.8285 7.32794L52.6717 27.1711C54.2338 28.7332 54.2338 31.2658 52.6717 32.8279L32.8285 52.6711C31.2664 54.2332 28.7338 54.2332 27.1717 52.6711L7.32855 32.8279C5.76646 31.2658 5.76645 28.7332 7.32855 27.1711L27.1717 7.32794Z"
                    fill={`url(#paint1_linear_208_73-${action})`}
                    fill-opacity="0.2"
                />
                <path
                    d="M27.5255 7.68115C28.8923 6.31473 31.108 6.31472 32.4747 7.68115L52.3185 27.5249C53.6849 28.8917 53.6849 31.1074 52.3185 32.4741L32.4747 52.3179C31.108 53.6843 28.8923 53.6843 27.5255 52.3179L7.68176 32.4741C6.31533 31.1074 6.31533 28.8917 7.68176 27.5249L27.5255 7.68115Z"
                    stroke={`url(#paint2_linear_208_73-${action})`}
                    stroke-opacity="0.7"
                />
                <path
                    d="M28.7267 12.3562C29.4296 11.6533 30.5696 11.6533 31.2726 12.3562L47.6447 28.7273C48.3475 29.4302 48.3473 30.5702 47.6447 31.2732L31.2726 47.6453C30.5696 48.348 29.4295 48.3481 28.7267 47.6453L12.3556 31.2732C11.6527 30.5702 11.6527 29.4302 12.3556 28.7273L28.7267 12.3562Z"
                    fill={`url(#paint3_linear_208_73-${action})`}
                    stroke={action === "add" ? "#9AFF35" : "#FF3535"}
                    stroke-width="0.4"
                />
                <rect
                    x="12"
                    y="8"
                    width="40"
                    height="40"
                    fill="url(#pattern0_208_73)"
                />
                <defs>
                    <linearGradient
                        id={`paint0_linear_208_73-${action}`}
                        x1="-3"
                        y1="2.25"
                        x2="30"
                        y2="60"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0.7"
                        />
                        <stop
                            offset="1"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0"
                        />
                    </linearGradient>
                    <linearGradient
                        id={`paint1_linear_208_73-${action}`}
                        x1="1.95012"
                        y1="6.41201"
                        x2="30.0001"
                        y2="55.4995"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0.7"
                        />
                        <stop
                            offset="1"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0"
                        />
                    </linearGradient>
                    <linearGradient
                        id={`paint2_linear_208_73-${action}`}
                        x1="30.0001"
                        y1="4.49951"
                        x2="30.0001"
                        y2="55.4995"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop
                            offset="0.0721073"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0"
                        />
                        <stop
                            offset="0.5"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                        />
                        <stop
                            offset="0.937911"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0"
                        />
                    </linearGradient>
                    <linearGradient
                        id={`paint3_linear_208_73-${action}`}
                        x1="14.7529"
                        y1="10.8005"
                        x2="37.5428"
                        y2="52.6291"
                        gradientUnits="userSpaceOnUse"
                    >
                        <stop
                            offset="0.238476"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                        />
                        <stop
                            offset="0.845384"
                            stop-color={
                                action === "add" ? "#9AFF35" : "#FF3535"
                            }
                            stop-opacity="0.2"
                        />
                    </linearGradient>
                </defs>
            </svg>
        </div>
    );
}
