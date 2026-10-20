import { useDefaultData } from "@stores/index";
import { storeToRefs } from "pinia";
import { FetchNUI } from "@/utils/index";

export default function () {
  const StoreData = useDefaultData();
  const {isShowingMenu, activeCategory, selectedItems} = storeToRefs(StoreData);

  window.addEventListener("keydown", async ({ key }) => {
  });
};
