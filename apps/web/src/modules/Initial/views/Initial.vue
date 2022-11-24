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
                    <MobileLogin></MobileLogin>
                </div>

                <div v-else>
                    <WebLogin></WebLogin>
                </div>
            </template>
        </MainLayout>
    </div>
</template>

<script lang="ts" setup>
    import MainLayout from '@/modules/Core/layouts/MainLayout.vue';
    import { isMobile } from '@/modules/Core/utils/mobile.util';
    import MobileLogin from '@/modules/Initial/components/mobile/MobileLogin.vue';
    import WebLogin from '@/modules/Initial/components/web/WebLogin.vue';
</script>
