<template>
    <RouterView :key="$route.fullPath" />
</template>

<script lang="ts" setup>
    import { initializeSockets } from '@/modules/Core/services/socket.service';

    initializeSockets();
</script>

<style></style>
