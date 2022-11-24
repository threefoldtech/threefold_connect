<!-- This example requires Tailwind CSS v2.0+ -->
<template>
    <MainLayout>
        <template #content>
            <div class="prose">
                <h1 class="m-0">404</h1>
                <div class="text-2xl pt-1">Oops, we couldn't find this page.</div>
            </div>
        </template>
    </MainLayout>
</template>

<script lang="ts" setup>
    import MainLayout from '@/modules/Core/layouts/MainLayout.vue';
</script>
