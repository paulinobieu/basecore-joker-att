<template>
  <div class="flex flex-col items-start gap-y-[0.9259vh] w-[29.8148vh]">
    <p class="font-['Manrope-Semibold'] text-[#FFF] text-[1.4815vh] line-clamp-1">{{ defaultData.GetLocale('fingers.choose_finger') }}</p>
    <div class="w-full flex flex-col items-start gap-y-[1.1111vh]">
      <div class="flex items-center gap-x-[0.9259vh]">
        <div class="w-[14.4444vh] h-[3.7037vh] flex items-center justify-center border-[0.0926vh] border-solid rounded-[0.463vh] cursor-pointer" :class="`${ defaultData.selectedHand == 'left_hand' ? 'bg-[#FFFFFF1A] border-[#FFFFFF]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29]' }`" @click="defaultData.SaveSelectedItem('hand', 'left_hand')">
          <p class="font-['Manrope-Regular'] text-[1.2963vh] line-clamp-1" :class="`${ defaultData.selectedHand == 'left_hand' ? 'text-[#FFF]' : 'text-[#FFFFFF80] ' }`">{{ defaultData.GetLocale('fingers.left_hand') }}</p>
        </div>
        <div class="w-[14.4444vh] h-[3.7037vh] flex items-center justify-center border-[0.0926vh] border-solid rounded-[0.463vh] cursor-pointer" :class="`${ defaultData.selectedHand == 'right_hand' ? 'bg-[#FFFFFF1A] border-[#FFFFFF]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29]' }`" @click="defaultData.SaveSelectedItem('hand', 'right_hand')">
          <p class="font-['Manrope-Regular'] text-[1.2963vh] line-clamp-1" :class="`${ defaultData.selectedHand == 'right_hand' ? 'text-[#FFF]' : 'text-[#FFFFFF80]' }`">{{ defaultData.GetLocale('fingers.right_hand') }}</p>
        </div>
      </div>
      <div class="flex flex-col items-start gap-y-[0.7407vh] w-full">
        <div v-for="finger in defaultData.fingers" :key="finger.id" class="w-full flex items-center gap-x-[0.5556vh]">
          <div class="w-full h-[3.7037vh] border-[0.0926vh] border-solid rounded-[0.463vh] flex items-center justify-between px-[0.7407vh] cursor-pointer" :class="`${isFingerSelected(finger.id) ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29]'}`" @click="defaultData.SaveSelectedItem('finger', { id: finger.id, hand: finger.name })">
            <div class="flex items-center gap-x-[0.9259vh]">
              <div class="w-[2.2222vh] h-[2.2222vh] flex items-center justify-center rounded-[5px] bg-[#FFFFFF1F]">
                <svg width="8" height="14" viewBox="0 0 8 14" fill="none" xmlns="http://www.w3.org/2000/svg" :class="`${isFingerSelected(finger.id) ? 'fill-white' : 'fill-white/30'}`">
                  <path d="M0.799805 2.46289C0.297743 3.14831 2.15322e-05 3.99965 0 4.9209V13.998H8V4.9209C7.99998 3.99965 7.70226 3.14831 7.2002 2.46289V5.74121C7.2002 7.55036 5.76448 9.02246 4 9.02246C2.23552 9.02246 0.799805 7.55036 0.799805 5.74121V2.46289ZM6.40039 12.6318H1.59961V11.8115H6.40039V12.6318ZM6.40039 10.9912H1.59961V10.1709H6.40039V10.9912ZM4 6.15137C3.22624 6.15137 2.49907 6.53847 2.05078 7.17578C2.48689 7.79682 3.19832 8.20215 4 8.20215C4.80157 8.20212 5.51214 7.7967 5.94824 7.17578C5.49995 6.53865 4.77362 6.15139 4 6.15137ZM3.2002 0C2.31808 0 1.59981 0.735248 1.59961 1.63965V5.74121C1.59961 5.95385 1.6261 6.16046 1.67578 6.35742C2.27373 5.71174 3.11387 5.33105 4 5.33105C4.88595 5.33108 5.72534 5.71197 6.32324 6.35742C6.37296 6.1604 6.39941 5.95392 6.39941 5.74121V1.63965C6.39921 0.735248 5.68192 0 4.7998 0H3.2002Z" />
                </svg>
              </div>
              <p class="font-['Manrope-Regular'] text-[1.2963vh] text-[#FFFFFF] line-clamp-1">{{ finger.name }}</p>
            </div>
            <svg v-if="isFingerSelected(finger.id)" width="1.2963vh" height="1.2963vh" viewBox="0 0 14 14" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" clip-rule="evenodd" d="M0 7C0 3.13401 3.13401 0 7 0C10.866 0 14 3.13401 14 7C14 10.866 10.866 14 7 14C3.13401 14 0 10.866 0 7ZM9.59201 5.69759C9.76486 5.4556 9.70881 5.1193 9.46682 4.94645C9.22483 4.7736 8.88853 4.82965 8.71568 5.07164L6.39283 8.32364L5.2269 7.15771C5.01662 6.94743 4.67569 6.94743 4.4654 7.15771C4.25512 7.36799 4.25512 7.70893 4.4654 7.91921L6.08079 9.5346C6.19271 9.64652 6.34821 9.70353 6.50595 9.69047C6.66369 9.67742 6.8077 9.59562 6.8997 9.46682L9.59201 5.69759Z" fill="#CB3AB0" style="fill:#CB3AB0;fill:color(display-p3 0.7961 0.2275 0.6902);fill-opacity:1;"/>
            </svg>
          </div>
          <div class="w-[3.7037vh] h-[3.7037vh] border-[0.0926vh] border-solid border-[#e30000] bg-[#e30000]/10 flex items-center justify-center rounded-[0.463vh] cursor-pointer tranistion-all duration-300 hover:bg-[#e30000]/20" @click="defaultData.ClearFingerDesign(finger.id)">
            <p class="text-[#e30000] text-[1.2963vh] font-medium font-['Manrope-Medium']">X</p>
          </div>
        </div>
      </div>
      <div class="flex items-center justify-center  w-full bg-[#CB3AB029] hover:bg-[#CB3AB0] transition-all duration-300 rounded-[0.463vh] cursor-pointer py-[0.9259vh] group" @click="defaultData.ApplyNailDesign()">
        <p class="text-[#CB3AB0] group-hover:text-black text-[1.2963vh] font-['Manrope-Semibold'] line-clamp-1 transition-colors duration-300">{{ defaultData.GetLocale('fingers.apply') }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { useDefaultData } from '@/stores/index';

  const defaultData = useDefaultData();

  const isFingerSelected = (fingerId: number) => {
    if (!defaultData.selectedHand) return false;
    const fingerKey = `${defaultData.selectedHand}_${fingerId}` as keyof typeof defaultData.fingerBoneMap;
    const boneId = defaultData.fingerBoneMap[fingerKey];
    if (!boneId) return false;
    return !!defaultData.selectedItems[String(boneId)];
  };
</script>
