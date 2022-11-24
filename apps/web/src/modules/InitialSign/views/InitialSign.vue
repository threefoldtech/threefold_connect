<template>
    <div>
        <MainLayout>
            <template #content>
                <div class="prose">
                    <h1>Threefold Connect Authenticator</h1>
                    <p>
                        Welcome to the <a class="font-bold">ThreeFold Connect</a> two-factor authenticator, enabling you
                        access to
                        <a class="font-bold">ThreeFold</a>
                        Grid tools and solutions. Not a single person in the world will be able to log in to your
                        account, not even us.
                    </p>
                </div>

                <div v-if="isMobile()">
                    <MobileSign></MobileSign>
                </div>

                <div v-else>
                    <WebSign></WebSign>
                </div>
            </template>
        </MainLayout>
    </div>
</template>

<script lang="ts" setup>
    import MainLayout from '@/modules/Core/layouts/MainLayout.vue';
    import { isMobile } from '@/modules/Core/utils/mobile.util';
    import MobileSign from '@/modules/InitialSign/components/mobile/MobileSign.vue';
    import WebSign from '@/modules/InitialSign/components/web/WebSign.vue';
</script>
