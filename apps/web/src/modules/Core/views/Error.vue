<template>
    <MainLayout>
        <template #content>
            <div class="prose">
                <h1>Error</h1>
                <p>
                    We didn't get the required parameters to make this work. You need to come from a third party app to
                    use this.
                </p>

                <p>If you want to register, you can do this from the ThreeFold Connect app.</p>
            </div>
        </template>
    </MainLayout>
</template>

<style scoped></style>
<script lang="ts" setup>
    import MainLayout from '@/modules/Core/layouts/MainLayout.vue';
</script>
