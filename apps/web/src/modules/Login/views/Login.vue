<template>
    <MainLayout>
        <template #content>
            <div class="prose prose-blue">
                <h1>Threefold Connect Authenticator</h1>
                <div v-if="secondsTillTimeout <= 0">
                    <ExpiredAttempt></ExpiredAttempt>
                </div>
                <div v-else>
                    <p>
                        Please open the ThreeFold Connect app on your mobile device, authenticate either with pin or
                        Touch ID, and then match the following icon from the choices given.
                    </p>
                    <p class="pt-4">
                        <EmojiPicker :key="selectedImageId"></EmojiPicker>
                    </p>
                    <p>Please enter your pin or use fingerprint and select this icon on your mobile phone.</p>
                    <p class="text-sm font-semibold">
                        Your login attempt is valid for another {{ secondsTillTimeout }} seconds.
                    </p>
                    <div>
                        <button
                            type="button"
                            class="bg-threefoldPink w-full text-center items-center px-3 py-3 border border-transparent text-sm leading-4 font-medium rounded-md shadow-sm text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                            @click="resendNotification"
                        >
                            Resend notification
                        </button>
                    </div>
                </div>
            </div>
        </template>
    </MainLayout>
</template>

<script lang="ts" setup>
    import EmojiPicker from '@/modules/Login/components/EmojiPicker.vue';
    import MainLayout from '@/modules/Core/layouts/MainLayout.vue';
    import { onBeforeUnmount, ref } from 'vue';
    import ExpiredAttempt from '@/modules/Login/components/ExpiredAttempt.vue';
    import { loginUserWeb } from '@/modules/Login/services/login.service';
    import { selectedImageId } from '@/modules/Initial/data';
    import { generateRandomImageId } from '@/modules/Login/utils/generate.util';
    const timeoutSeconds = 120;

    const secondsTillTimeout = ref<number>(timeoutSeconds);

    // Needed to always clear the interval when the component is destroyed
    onBeforeUnmount(() => {
        clearInterval(counter);
    });

    const counter = setInterval(() => {
        validateTimeoutSeconds();
    }, 1000);

    const validateTimeoutSeconds = () => {
        if (secondsTillTimeout.value <= 0) {
            clearInterval(counter);
            return;
        }

        secondsTillTimeout.value--;
    };

    const resendNotification = async () => {
        secondsTillTimeout.value = timeoutSeconds;

        selectedImageId.value = generateRandomImageId();
        await loginUserWeb();
    };
</script>
