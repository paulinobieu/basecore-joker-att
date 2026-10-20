import { useDefaultData } from "@stores/index";
import { storeToRefs } from "pinia";
import { FetchNUI } from "@/utils/index";

export default function () {
  const StoreData = useDefaultData();
  const {isShowingMenu, selectedHand} = storeToRefs(StoreData);

  window.addEventListener("message", async ({ data }) => {
    switch (data.action) {
      case "nui/check":
        FetchNUI("nui/checked", {});
        break;
      case "nui/set-locales":
        StoreData.SetLocales(data.payload.locales);
        break;
      case "nui/toggle":
        isShowingMenu.value = data.payload.show;
        FetchNUI('nui/set-hand', { hand: selectedHand.value });
        break;
      default:
        console.warn(`Unknown action received: ${data.action}`);
        break;
    }
  });
};
