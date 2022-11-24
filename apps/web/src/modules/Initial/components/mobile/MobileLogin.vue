<template>
    <div class="mt-4">
        <button
            type="button"
            class="bg-threefoldPink w-full text-center items-center px-3 py-3 border border-transparent text-sm leading-4 font-medium rounded-md shadow-sm text-white hover:bg-threefoldPink"
            @click="loginMobile"
        >
            Open ThreeFold Connect app
        </button>
    </div>
</template>

<script lang="ts" setup>
    import { loginUserMobile } from '@/modules/Login/services/login.service';

    const loginMobile = () => {
        loginUserMobile();
    };
</script>

<style scoped></style>
