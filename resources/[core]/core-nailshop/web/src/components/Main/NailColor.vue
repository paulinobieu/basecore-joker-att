<template>
  <div v-if="defaultData.activeCategory == 'color-nail'" class="w-[29.8148vh] flex flex-col items-start gap-y-[1.1111vh]">
    <div class="w-full flex flex-col items-start gap-y-[0.9259vh]">
      <p class="text-[#FFFFFF] font-['Manrope-Semibold'] line-clamp-1 text-[1.4815vh]">{{ defaultData.GetLocale('colors.color_of_nails') }}</p>
      <div class="w-full h-[3.7037vh] bg-[#FFFFFF0A] border-[#FFFFFF29] border-[0.0463vh] border-solid rounded-[5px] flex items-center pr-[1.1111vh]">
        <input type="text" :placeholder="defaultData.GetLocale('colors.select_color')" class="w-full h-full bg-transparent pl-[1.1111vh] mr-[1.8519vh] text-[#FFFFFF] font-['Manrope-Regular'] text-[1.2963vh] placeholder:text-[#FFFFFF80] outline-none rounded-[5px]" />
        <svg width="1.5741vh" height="1.5741vh" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path d="M16.5 16.5L11.8807 11.8807M11.8807 11.8807C13.0871 10.6743 13.8333 9.00762 13.8333 7.16667C13.8333 3.48477 10.8486 0.5 7.16667 0.5C3.48477 0.5 0.5 3.48477 0.5 7.16667C0.5 10.8486 3.48477 13.8333 7.16667 13.8333C9.00762 13.8333 10.6743 13.0871 11.8807 11.8807Z" stroke="white" stroke-opacity="0.5" style="stroke:white;stroke-opacity:0.5;" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </div>
    </div>
    <div class="w-full grid grid-cols-2 gap-[0.9259vh] max-h-[76.6667vh] overflow-y-auto">
      <div class="w-[14.4444vh] h-[14.4444vh] bg-[#FFFFFF0A] border-[.5px] border-solid border-[#FFFFFF29] py-[1.2963vh] rounded-[0.463vh] cursor-pointer flex flex-col items-center" :class="`${isColorSelected(-1) ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : ''}`" @click="defaultData.SaveSelectedItem('color-nail', -1)">
        <div class="w-[8.3333vh] h-[8.3333vh] bg-[#FFFFFF0F] rounded-[5px] mt-[0.5556vh] mb-[1.2037vh] flex items-center justify-center">
          <svg width="5.8333vh" height="5.8333vh" viewBox="0 0 63 63" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M51.8062 51.8062C63.2001 40.4124 63.2001 21.9393 51.8062 10.5454C40.4124 -0.848468 21.9393 -0.848468 10.5454 10.5454M51.8062 51.8062C40.4124 63.2001 21.9393 63.2001 10.5454 51.8062C-0.848468 40.4124 -0.848468 21.9393 10.5454 10.5454M51.8062 51.8062L10.5454 10.5454" stroke="white" stroke-opacity="0.3" style="stroke:white;stroke-opacity:0.3;" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <p class="font-['Manrope-Medium'] text-[1.2963vh] text-[#FFFFFF] line-clamp-1">{{ defaultData.GetLocale('colors.none') }}</p>
      </div>
      <div v-for="color in defaultData.nailColors" class="w-[14.4444vh] h-[14.4444vh] border-[.5px] border-solid py-[1.2963vh] rounded-[0.463vh] cursor-pointer flex flex-col items-center" :class="`${isColorSelected(color.id) ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29] '}`" @click="defaultData.SaveSelectedItem('color-nail', color.id)">
        <div class="w-[8.3333vh] h-[8.3333vh] bg-[#FFFFFF0F] rounded-[5px] mt-[0.5556vh] mb-[1.2037vh] flex items-center justify-center">
          <div class="w-[3.7037vh] h-[5.5556vh] rounded-b-[0.9259vh] rounded-t-[2.7778vh]" :style="{ background: `linear-gradient(180deg, ${color.from} 0%, ${color.to} 100%)` }"></div>
        </div>
        <p class="font-['Manrope-Medium'] text-[1.2963vh] text-[#FFFFFF] line-clamp-1">{{ color.name }}</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { useDefaultData } from '@/stores/index';

  const defaultData = useDefaultData();

  const isColorSelected = (colorId: number) => {
    const selectedFingers = Object.values(defaultData.selectedItems);
    if (selectedFingers.length === 0) return false;
    return selectedFingers.every(f => f.colorNail === colorId);
  };
</script>
