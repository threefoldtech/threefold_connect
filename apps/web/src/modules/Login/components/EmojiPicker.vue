<template>
    <div class="flex flex-col items-center justify-center">
        <div
            class="w-16 h-16 animate-spin spinner--circle-2 rounded-full border-4 border-solid border-threefoldPink border-t-white"
        ></div>
        <span class="absolute text-2xl">
            <img :src="`/icons/${selectedImageId}.png`" class="h-6 w-6" alt="icon" />
        </span>
    </div>
</template>
<script lang="ts" setup>
    import { selectedImageId } from '@/modules/Initial/data';
</script>
