import { useImageValidation } from "@app/hooks/useImageValidation";
import { useVisibilityStore } from "@app/stores/Visibility";
import { fetchNui } from "@app/utils/fetchNui";
import { useCallback, useEffect, useState } from "react";

import FallbackLogo from "@views/assets/images/logos/fallback-logo.webp";
import { NotifyRequest } from "../NotifyRequest";
import { Safezone } from "../Safezone";

interface IData {
    logo: string;
    dimensions: { width: string; height: string; top: string };
}

export function Logo() {
    const visible = useVisibilityStore((state) => state.visible);
    const [data, setData] = useState<IData | null>(null);

    const { imageUrl, isImageValid } = useImageValidation(data?.logo || "");

    const handleGetData = useCallback(async () => {
        const mockData: IData = {
            dimensions: {
                height: "9.375rem",
                top: "-1.1875rem",
                width: "9.375rem",
            },
            logo: "",
        };
        const response = await fetchNui({ path: "get:logo:data", mockData });

        if (!response) return;

        setData(response);
    }, []);

    useEffect(() => {
        if (!visible) return;

        handleGetData();
    }, [visible, handleGetData]);

    return (
        <div
            className="-translate-x-1/2 absolute left-1/2 flex flex-col items-center gap-3"
            style={{
                top: data?.dimensions?.top || "-1.1875rem",
            }}
        >
            <img
                src={isImageValid ? imageUrl : FallbackLogo}
                alt=""
                className="size-[9.375rem] object-contain"
                style={
                    data?.dimensions
                        ? {
                              width: data.dimensions.width,
                              height: data.dimensions.height,
                          }
                        : undefined
                }
            />
            <Safezone />
            <NotifyRequest />
        </div>
    );
}
