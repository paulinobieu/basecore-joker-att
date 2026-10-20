<template>
  <div class="w-screen h-screen items-center justify-center overflow-hidden flex">
    <Main />
    <SaveModal v-if="defaultData.isShowingSave" />
  </div>
</template>

<script setup lang="ts">
  import messageEvents from '@utils/message';
  import keydownEvents from '@utils/keydown';

  import Main from '@pages/Main/Page.vue';
  import SaveModal from '@components/Modal/SaveDesign.vue';

  import { useDefaultData } from '@/stores/index';

  const defaultData = useDefaultData();

  import { onMounted } from 'vue';

  onMounted(() => {
    messageEvents();
    keydownEvents();
  });
</script>
