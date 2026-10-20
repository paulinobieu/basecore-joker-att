<template>
    <div v-if="defaultData.activeCategory == 'length-nail'" class="w-[29.8148vh] flex flex-col items-start gap-y-[1.1111vh]">
      <div class="w-full flex flex-col items-start gap-y-[0.9259vh]">
        <p class="text-[#FFFFFF] font-['Manrope-Semibold'] line-clamp-1 text-[1.4815vh]">{{ defaultData.GetLocale('lengths.length_of_nails') }}</p>
        <div class="w-full h-[3.7037vh] bg-[#FFFFFF0A] border-[#FFFFFF29] border-[0.0463vh] border-solid rounded-[5px] flex items-center pr-[1.1111vh]">
          <input type="text" :placeholder="defaultData.GetLocale('lengths.select_length')" class="w-full h-full bg-transparent pl-[1.1111vh] mr-[1.8519vh] text-[#FFFFFF] font-['Manrope-Regular'] text-[1.2963vh] placeholder:text-[#FFFFFF80] outline-none rounded-[5px]" />
          <svg width="1.5741vh" height="1.5741vh" viewBox="0 0 17 17" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M16.5 16.5L11.8807 11.8807M11.8807 11.8807C13.0871 10.6743 13.8333 9.00762 13.8333 7.16667C13.8333 3.48477 10.8486 0.5 7.16667 0.5C3.48477 0.5 0.5 3.48477 0.5 7.16667C0.5 10.8486 3.48477 13.8333 7.16667 13.8333C9.00762 13.8333 10.6743 13.0871 11.8807 11.8807Z" stroke="white" stroke-opacity="0.5" style="stroke:white;stroke-opacity:0.5;" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
      </div>
      <div class="w-full flex flex-col items-start gap-y-[0.9259vh]">
        <div class="w-full flex flex-col items-center h-[14.4444vh] rounded-[0.463vh] border-solid border-[0.0463vh] pt-[1.8519vh] px-[1.8519vh] cursor-pointer" :class="`${isLengthSelected('small') ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29] '}`" @click="defaultData.SaveSelectedItem('length-nail', 'small')">
          <div class="w-[26.1111vh] h-[8.3333vh] flex items-center justify-center bg-[#FFFFFF0F] rounded-[0.463vh] mb-[1.2037vh]">
            <svg width="6.4815vh" height="2.4074vh" viewBox="0 0 70 26" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" clip-rule="evenodd" d="M61.4198 22.1006C59.1507 24.5053 55.9948 26.0006 52.4999 26.001L9.99989 26.001C4.47713 26.001 3.05176e-05 21.5237 -0.000106812 16.001V10C0.000144958 4.47737 4.4772 0 9.99989 0L52.4999 0C55.9948 6.23016e-05 59.1507 1.49606 61.4198 3.90039L47.079 3.90039L46.4384 5.50488C45.484 7.89913 45.0009 10.4184 45.0009 12.9932C45.0009 15.5754 45.484 18.1004 46.4384 20.4961L47.079 22.1006H61.4198ZM67.4091 6.50098C70.8635 10.0925 70.8625 15.9134 67.4091 19.501H48.7479C47.1485 15.4868 47.0207 10.8323 48.7479 6.50098L67.4091 6.50098Z" fill="white" style="fill:white;fill-opacity:1;"/>
            </svg>
          </div>
          <p class="text-[#FFFFFF] text-[1.2963vh] font-['Manrope-Medium'] line-clamp-1 text-center">{{ defaultData.GetLocale('lengths.short') }}</p>
        </div>
        <div class="w-full flex flex-col items-center h-[14.4444vh] rounded-[0.463vh] border-solid border-[0.0463vh] pt-[1.8519vh] px-[1.8519vh] cursor-pointer" :class="`${isLengthSelected('med') ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29] '}`" @click="defaultData.SaveSelectedItem('length-nail', 'med')">
          <div class="w-[26.1111vh] h-[8.3333vh] flex items-center justify-center bg-[#FFFFFF0F] rounded-[0.463vh] mb-[1.2037vh]">
            <svg width="7.4074vh" height="2.4074vh" viewBox="0 0 80 26" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" clip-rule="evenodd" d="M61.42 22.1006C59.1508 24.5052 55.995 26.0007 52.5001 26.001L10.0001 26.001C4.47734 26.0009 0.000198364 21.5237 6.10352e-05 16.001V10C0.000312805 4.4774 4.47741 4.58558e-05 10.0001 0L52.5001 0C55.995 0 59.1508 1.49609 61.42 3.90039L47.0792 3.90039L46.4395 5.50488C45.4852 7.89913 45.002 10.4184 45.002 12.9932C45.002 15.5754 45.4852 18.1004 46.4395 20.4961L47.0792 22.1006L61.42 22.1006ZM77.4102 6.50098C80.8644 10.0925 80.8635 15.9135 77.4102 19.501L48.7491 19.501C47.1497 15.4867 47.0218 10.8323 48.7491 6.50098L77.4102 6.50098Z" fill="white" style="fill:white;fill-opacity:1;"/>
            </svg>
          </div>
          <p class="text-[#FFFFFF] text-[1.2963vh] font-['Manrope-Medium'] line-clamp-1 text-center">{{ defaultData.GetLocale('lengths.medium') }}</p>
        </div>
        <div class="w-full flex flex-col items-center h-[14.4444vh] rounded-[0.463vh] border-solid border-[0.0463vh] pt-[1.8519vh] px-[1.8519vh] cursor-pointer" :class="`${isLengthSelected('long') ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29] '}`" @click="defaultData.SaveSelectedItem('length-nail', 'long')">
          <div class="w-[26.1111vh] h-[8.3333vh] flex items-center justify-center bg-[#FFFFFF0F] rounded-[0.463vh] mb-[1.2037vh]">
            <svg width="8.3333vh" height="2.4074vh" viewBox="0 0 90 26" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" clip-rule="evenodd" d="M61.4199 22.1006C59.1508 24.5052 55.9949 26.0007 52.5 26.001H10C4.47734 26.0009 0.000152588 21.5236 1.52588e-05 16.001V10C0.000267029 4.47743 4.47741 0.000102545 10 0L52.5 0C55.995 0 59.1508 1.49612 61.4199 3.90039L47.0791 3.90039L46.4395 5.50488C45.4851 7.89913 45.002 10.4184 45.002 12.9932C45.002 15.5754 45.4851 18.1004 46.4395 20.4961L47.0791 22.1006L61.4199 22.1006ZM87.4102 6.50098C90.8644 10.0925 90.8635 15.9134 87.4102 19.501L48.749 19.501C47.1496 15.4867 47.0218 10.8323 48.749 6.50098L87.4102 6.50098Z" fill="white" style="fill:white;fill-opacity:1;"/>
            </svg>
          </div>
          <p class="text-[#FFFFFF] text-[1.2963vh] font-['Manrope-Medium'] line-clamp-1 text-center">{{ defaultData.GetLocale('lengths.long') }}</p>
        </div>
        <div class="w-full flex flex-col items-center h-[14.4444vh] rounded-[0.463vh] border-solid border-[0.0463vh] pt-[1.8519vh] px-[1.8519vh] cursor-pointer" :class="`${isLengthSelected('small_french') ? 'border-[#CB3AB0] bg-[#CB3AB01A]' : 'bg-[#FFFFFF0A] border-[#FFFFFF29] '}`" @click="defaultData.SaveSelectedItem('length-nail', 'small_french');">
          <div class="w-[26.1111vh] h-[8.3333vh] flex items-center justify-center bg-[#FFFFFF0F] rounded-[0.463vh] mb-[1.2037vh]">
            <svg width="6.4815vh" height="2.4074vh" viewBox="0 0 70 26" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path fill-rule="evenodd" clip-rule="evenodd" d="M61.4198 22.1006C59.1507 24.5053 55.9948 26.0006 52.4999 26.001L9.99989 26.001C4.47713 26.001 3.05176e-05 21.5237 -0.000106812 16.001V10C0.000144958 4.47737 4.4772 0 9.99989 0L52.4999 0C55.9948 6.23016e-05 59.1507 1.49606 61.4198 3.90039L47.079 3.90039L46.4384 5.50488C45.484 7.89913 45.0009 10.4184 45.0009 12.9932C45.0009 15.5754 45.484 18.1004 46.4384 20.4961L47.079 22.1006H61.4198ZM67.4091 6.50098C70.8635 10.0925 70.8625 15.9134 67.4091 19.501H48.7479C47.1485 15.4868 47.0207 10.8323 48.7479 6.50098L67.4091 6.50098Z" fill="white" style="fill:white;fill-opacity:1;"/>
            </svg>
          </div>
          <p class="text-[#FFFFFF] text-[1.2963vh] font-['Manrope-Medium'] line-clamp-1 text-center">{{ defaultData.GetLocale('lengths.small_french') }}</p>
        </div>
      </div>
    </div>
</template>

<script setup lang="ts">
  import { useDefaultData } from '@/stores/index';

  const defaultData = useDefaultData();

  const isLengthSelected = (length: string) => {
    const selectedFingers = Object.values(defaultData.selectedItems);
    if (selectedFingers.length === 0) return false;
    return selectedFingers.every(f => f.lengthNail === length);
  };
</script>
