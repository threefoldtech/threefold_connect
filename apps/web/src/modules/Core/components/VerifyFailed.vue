<template>
    <div class="o-circle c-container__circle o-circle__sign--failure">
        <div class="o-circle__sign"></div>
    </div>
    <p class="text-center text-red-500 font-semibold">{{ text }}</p>
</template>

<script lang="ts" setup>
    interface IProps {
        text: string;
    }

    const { text } = defineProps<IProps>();
</script>
