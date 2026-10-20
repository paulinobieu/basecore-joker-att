<template>
  <div class="inset-0 absolute top-0 left-0 bg-black/40 flex items-center justify-center p-4 z-10">
    <div class="bg-white rounded-md shadow-2xl w-full max-w-md overflow-hidden">
      <div class="p-6">
        <h2 class="text-xl font-bold text-black text-center">{{ defaultData.GetLocale('save_design.save_nail_design') }}</h2>
        <p class="text-black/70 text-center mt-2 text-base">{{ defaultData.GetLocale('save_design.would_you_like_to_save_your_current_nail_design') }}</p>
      </div>

      <div class="bg-gray-50 px-6 py-4 flex gap-3">
        <button class="flex-1 px-4 py-3 border border-gray-300 text-gray-700 font-medium rounded-md hover:bg-gray-100 transition" @click="defaultData.DontSaveAndClose();defaultData.isShowingSave = false;">
          {{ defaultData.GetLocale('save_design.cancel') }}
        </button>
        <button class="flex-1 px-4 py-3 bg-[#DD26B5] text-white font-medium rounded-md hover:bg-[#C0219F] transition shadow-lg" @click="defaultData.SaveDesignAndClose();defaultData.isShowingSave = false;">
          {{ defaultData.GetLocale('save_design.save') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
  import { useDefaultData } from '@/stores/index';
  const defaultData = useDefaultData();
</script>
