<template>
    <MainLayout>
        <template #content>
            <div class="prose">
                <h1>Error</h1>

                <div v-if="reason === Reasons.FLAGSMITH">
                    <p>Sadly, we couldn't initialize the FlagSmith client</p>
                    <p>Please contact the <a href="https://threefold.io/support/"> ThreeFold support </a> service</p>
                </div>
                <div v-else>
                    <p>
                        We didn't get the required parameters to make this work. You need to come from a third party app
                        to use this.
                    </p>

                    <p>If you want to register, you can do this from the ThreeFold Connect app.</p>
                </div>
            </div>
        </template>
    </MainLayout>
</template>
<script lang="ts" setup>
    import MainLayout from '@/modules/Core/layouts/MainLayout.vue';
    import { useRoute } from 'vue-router';
    import { computed } from 'vue';

    const route = useRoute();

    enum Reasons {
        FLAGSMITH = 'flagsmith',
    }

    const reason = computed(() => {
        return route.params.reason;
    });
</script>
