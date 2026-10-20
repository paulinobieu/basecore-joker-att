import { defineStore } from 'pinia';
import type { NailPattern, NailColors } from '@/types/index';
import { FetchNUI } from '@utils/index';
import SaveDesign from '@/components/Modal/SaveDesign.vue';

export const useDefaultData = defineStore("DefaultData", {
  state: () => ({
    isShowingMenu: false as boolean,
    isShowingSave: false as boolean,
    activeCategory: 'length-nail' as string,
    nailColors: [
      { id: 0, name: 'Pacific', from: '#FFFFFF', to: '#E6E6E6' },
      { id: 1, name: "Solaris", from: "#ffd000", to: "#dbb404" },
      { id: 2, name: "Amberflare", from: "#ff9100", to: "#fc950d" },
      { id: 3, name: "Crimsonflare", from: "#ff033e", to: "#fc0d45" },
      { id: 4, name: "Bloodline", from: "#d40032", to: "#c90c39" },
      { id: 5, name: "Lemonburst", from: "#f6ff00", to: "#f4fc17" },
      { id: 6, name: "Citrine", from: "#e5ff00", to: "#e8ff1c" },
      { id: 7, name: "Sunbeam", from: "#f4fc4e", to: "#f7ff59" },
      { id: 8, name: "Mintshore", from: "#c2eb7c", to: "#c2eb7c" },
      { id: 9, name: "Meadow", from: "#abd16b", to: "#abd16b" },
      { id: 10, name: "Cloverfield", from: "#abd16b", to: "#abd16b" },
      { id: 11, name: "Springwave", from: "#62e391", to: "#62e391" },
      { id: 12, name: "Neongreen", from: "#52fa55", to: "#52fa55" },
      { id: 13, name: "Freshleaf", from: "#4ccf4f", to: "#4ccf4f" },
      { id: 14, name: "Verdant", from: "#3cb03e", to: "#3cb03e" },
      { id: 15, name: "Everforest", from: "#288029", to: "#288029" },
      { id: 16, name: "Skydrift", from: "#5cdcff", to: "#5cdcff" },
      { id: 17, name: "Frostmist", from: "#bafeff", to: "#bafeff" },
      { id: 18, name: "Iceflare", from: "#69fcff", to: "#69fcff" },
      { id: 19, name: "Aquasurge", from: "#00f2ff", to: "#00f2ff" },
      { id: 20, name: "Aquasurge", from: "#00f2ff", to: "#00f2ff" },
      { id: 21, name: "Bluecore", from: "#00aeff", to: "#00aeff" },
      { id: 22, name: "Nebula", from: "#4800ff", to: "#4800ff" },
      { id: 23, name: "Voidbeam", from: "#5d00ff", to: "#5d00ff" },
      { id: 24, name: "Ultraviolet", from: "#8400ff", to: "#8400ff" },
      { id: 25, name: "Amethyst", from: "#9000ff", to: "#9000ff" },
      { id: 26, name: "Lavendersky", from: "#ec99ff", to: "#ec99ff" },
      { id: 27, name: "MagentaCore", from: "#d000ff", to: "#d000ff" },
      { id: 28, name: "Bloomflare", from: "#e600ff", to: "#e600ff" },
      { id: 30, name: "Violetburst", from: "#bb00ff", to: "#bb00ff" },
      { id: 31, name: "Honeylight", from: "#ffef78", to: "#ffef78" },
      { id: 32, name: "Butterglow", from: "#fff18a", to: "#fff18a" },
      { id: 33, name: "Goldencrest", from: "#ffe100", to: "#ffe100" },
      { id: 34, name: "Firetrail", from: "#ff6600", to: "#ff6600" },
      { id: 35, name: "Amberflare", from: "#fc9003", to: "#fc9003" },
      { id: 36, name: "Emberroot", from: "#982f31", to: "#982f31" },
      { id: 37, name: "Crimsonbrand", from: "#b62328", to: "#b62328" },
      { id: 38, name: "Bloodspark", from: "#991e2f", to: "#991e2f" },
      { id: 39, name: "Scarletforge", from: "#ac283a", to: "#ac283a" },
      { id: 40, name: "Violetcrest", from: "#ae65c4", to: "#ae65c4" },
      { id: 41, name: "Dustwhisper", from: "#997a58", to: "#997a58" },
      { id: 42, name: "Oakburn", from: "#836540", to: "#836540" },
      { id: 43, name: "Emberwood", from: "#7c5734", to: "#7c5734" },
      { id: 44, name: "Timberfall", from: "#684127", to: "#684127" },
      { id: 45, name: "Shadowbark", from: "#3f2e23", to: "#3f2e23" },
      { id: 46, name: "Silverveil", from: "#c3c1c0", to: "#c3c1c0" },
      { id: 47, name: "Fogsteel", from: "#b8b7b5", to: "#b8b7b5" },
      { id: 48, name: "Ashgleam", from: "#aaa7a9", to: "#aaa7a9" },
      { id: 49, name: "Greyward", from: "#9e9e9e", to: "#9e9e9e" },
      { id: 50, name: "Mistiron", from: "#939496", to: "#939496" },
      { id: 51, name: "Duskslate", from: "#888688", to: "#888688" },
      { id: 52, name: "Ironshade", from: "#676769", to: "#676769" },
      { id: 53, name: "Charcoaldusk", from: "#4f4d4f", to: "#4f4d4f" },
      { id: 54, name: "Nightash", from: "#25282b", to: "#25282b" },
      { id: 55, name: "Obsidiancore", from: "#0e0e0d", to: "#0e0e0d" }
    ] as NailColors[],
    nailPatterns: [
      { id: 'diamond', name: 'Pattern #1', image: 'pattern_one' },
      { id: 'diashape', name: 'Pattern #2', image: 'pattern_two' },
      { id: 'empty', name: 'Pattern #3', image: 'pattern_three' },
      { id: 'line', name: 'Pattern #4', image: 'pattern_four' },
      { id: 'nude', name: 'Pattern #5', image: 'pattern_five' },
      { id: 'square', name: 'Pattern #6', image: 'pattern_six' },
      { id: 'zigzag', name: 'Pattern #7', image: 'pattern_seven' },
      { id: 'zigzag2', name: 'Pattern #8', image: 'pattern_eight' },
      { id: 'bow', name: 'Pattern #9', image: 'pattern_nine' },
      { id: 'heart', name: 'Pattern #10', image: 'pattern_eleven' },
      { id: 'star', name: 'Pattern #11', image: 'pattern_twelve' },
    ] as NailPattern[],
    selectedHand: 'left_hand' as string | null,
    selectedItems: {} as Record<string, {
      colorNail: number,
      patternNail: string | null,
      lengthNail: string | null,
      boneId: number
    }>,
    fingerBoneMap: {
      left_hand_1: 45,
      left_hand_2: 50,
      left_hand_3: 54,
      left_hand_4: 57,
      left_hand_5: 60,
      right_hand_1: 74,
      right_hand_2: 79,
      right_hand_3: 83,
      right_hand_4: 86,
      right_hand_5: 89
    } as Record<string, number>,
    locales: {} as Record<string, any>
  }),
  getters: {
    fingers: (state) => {
      const fingerKeys = ['thumb', 'index', 'middle', 'ring', 'pinkie'];
      return fingerKeys.map((key, index) => ({
        id: index + 1,
        name: state.locales?.fingers?.[key] || ['Thumb', 'Index', 'Middle', 'Ring', 'Pinkie'][index]
      }));
    }
  },
  actions: {
    SetLocales(locales: Record<string, any>) {
      this.locales = locales;
    },
    GetLocale(key: string) {
      const keys = key.split('.');
      let value: any = this.locales;

      for (const k of keys) {
        if (value && typeof value === 'object' && k in value) {
          value = value[k];
        } else {
          return key;
        }
      }

      return typeof value === 'string' ? value : key;
    },
    SetActiveCategory(category: string) {
      this.activeCategory = category;
    },
    SaveSelectedItem(type: string, value: any) {
      switch (type) {
        case 'length-nail':
          Object.keys(this.selectedItems).forEach(boneId => {
            const item = this.selectedItems[boneId];
            if (item) item.lengthNail = value;
          });
          break;
        case 'color-nail':
          Object.keys(this.selectedItems).forEach(boneId => {
            const item = this.selectedItems[boneId];
            if (item) item.colorNail = value;
          });
          break;
        case 'pattern-nail':
          Object.keys(this.selectedItems).forEach(boneId => {
            const item = this.selectedItems[boneId];
            if (item) item.patternNail = value;
          });
          break;
        case 'finger':
          if (!value.id || !this.selectedHand) return;

          const fingerKey = `${this.selectedHand}_${value.id}` as keyof typeof this.fingerBoneMap;
          const boneId = this.fingerBoneMap[fingerKey];

          if (!boneId) return;

          const boneIdStr = String(boneId);

          if (this.selectedItems[boneIdStr]) {
            delete this.selectedItems[boneIdStr];
          } else {
            const existingFinger = Object.values(this.selectedItems)[0];
            this.selectedItems[boneIdStr] = {
              colorNail: existingFinger?.colorNail ?? -1,
              patternNail: existingFinger?.patternNail ?? null,
              lengthNail: existingFinger?.lengthNail ?? null,
              boneId: boneId
            };
          }
          break;
        case 'hand':
          this.selectedHand = value;
          FetchNUI('nui/set-hand', { hand: value });
          break;
        default:
          break;
      }
    },
    CloseUI() {
      this.isShowingMenu = false;
      this.activeCategory = 'length-nail';
      this.selectedItems = {};
      FetchNUI('nui/close', {});
    },
    SaveDesignAndClose() {
      FetchNUI('nui/save-naildesign', {});
      this.CloseUI();
    },
    DontSaveAndClose() {
      FetchNUI('nui/restore-naildesign', {});
      this.CloseUI();
    },
    ApplyNailDesign() {
      const selectedFingers = Object.values(this.selectedItems);
      if (selectedFingers.length === 0) return;

      const hasSmallFrench = selectedFingers.some(f => f.lengthNail === 'small_french');

      if (hasSmallFrench) {
        Object.keys(this.selectedItems).forEach(boneId => {
          const item = this.selectedItems[boneId];
          if (item && item.lengthNail === 'small_french') {
            if (item.colorNail < 0 || item.colorNail === undefined) {
              item.colorNail = 0;
            }
            if (!item.patternNail) {
              item.patternNail = 'empty';
            }
          }
        });
        FetchNUI('nui/apply-naildesign', this.selectedItems);
      } else {
        if (selectedFingers.every(f => f.lengthNail && f.colorNail >= 0 && f.patternNail)) {
          FetchNUI('nui/apply-naildesign', this.selectedItems);
        }
      }
    },
    ClearFingerDesign(fingerId: number) {
      FetchNUI('nui/clear-finger-design', {
        fingerId: fingerId,
        hand: this.selectedHand
      });
    },
  }
});
