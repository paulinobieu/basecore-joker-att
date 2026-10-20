<template>
  <div v-if="defaultData.isShowingMenu" class="w-full h-full relative p-[3.7037vh]">
    <div class="h-full flex flex-col items-start gap-y-[1.3889vh] relative z-10">
      <div class="flex flex-col items-start gap-y-[0.5556vh]">
        <div class="flex items-center gap-x-[0.7407vh]">
          <h2 class="font-['Unbounded-Bold'] text-[2.2222vh] text-[#DD26B5]">{{ defaultData.GetLocale('header.nails') }}</h2>
          <h2 class="font-['Unbounded-Bold'] text-[2.2222vh] text-[#FFFFFF]">{{ defaultData.GetLocale('header.menu') }}</h2>
        </div>
        <p class="font-['Manrope-Regular'] text-[1.2963vh] text-[#FFFFFF80] line-clamp-2">{{ defaultData.GetLocale('header.description') }}</p>
      </div>
      <div class="flex items-start h-full gap-x-[1.4815vh]">
        <Sidebar />
        <NailLength />
        <NailColor />
        <NailPattern />
        <Fingers />
      </div>
    </div>
    <div class="w-[64.8148vh] h-full absolute top-0 left-0" style="background: linear-gradient(270deg, rgba(15, 16, 24, 0) 0%, rgba(15, 16, 24, 0.6) 50.95%, #0F1017 100%);"></div>
  </div>
</template>

<script setup>
  import Sidebar from '@/components/Main/Sidebar.vue';
  import NailLength from '@/components/Main/NailLength.vue';
  import NailColor from '@/components/Main/NailColor.vue';
  import NailPattern from '@/components/Main/NailPattern.vue';
  import Fingers from '@/components/Main/Fingers.vue';

  import { useDefaultData } from '@/stores/index';

  const defaultData = useDefaultData();
</script>
