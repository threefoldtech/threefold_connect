<template>
    <div class="mt-4">
        <button
            type="button"
            class="bg-threefoldPink w-full text-center items-center px-3 py-3 border border-transparent text-sm leading-4 font-medium rounded-md shadow-sm text-white hover:bg-threefoldPink"
            @click="signMobile"
        >
            Open ThreeFold Connect app
        </button>
    </div>
</template>

<script lang="ts" setup>
    import { signUserMobile } from '@/modules/InitialSign/services/sign.service';

    const signMobile = () => {
        signUserMobile();
    };
</script>

<style scoped></style>
