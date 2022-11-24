<template>
    <div class="pt-8">
        <label class="text-sm font-black text-gray-800" for="name">
            What is your username? This can be found under settings in the mobile app</label
        >
        <div class="mt-1 relative rounded-md shadow-sm">
            <input
                id="name"
                v-model="username"
                aria-describedby="email-error"
                :class="{
                    'border-red-300 placeholder-red-300 focus:ring-red-500 focus:border-red-500': errorUsername,
                }"
                class="block w-full pr-14 focus:outline-none sm:text-sm rounded-md"
                name="name"
                type="text"
                :maxlength="50"
                @keyup.enter="login"
                @keyup="listenToUsername"
            />
            <div class="text-sm text-gray-600 absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                .3bot
            </div>
        </div>
        <p v-show="errorUsername" id="name-error" class="mt-2 text-xs text-red-600">
            {{ errorUsername }}
        </p>
    </div>
    <div v-show="username && username.length > 0" class="prose text-xs text-gray-600">
        <div class="pt-1">Your ThreeFold ID: {{ username }}.3bot</div>
    </div>

    <div class="pt-4">
        <button
            :disabled="!userKnown"
            type="button"
            :class="{
                'bg-gray-500': !userKnown,
                'bg-threefoldPink': userKnown,
            }"
            class="disabled:hover:bg-gray-500 w-full text-center items-center px-3 py-3 border border-transparent text-sm leading-4 font-medium rounded-md shadow-sm text-white hover:bg-threefoldPink"
            @click="login"
        >
            Sign in
        </button>
    </div>
</template>

<script lang="ts" setup>
    import { onMounted, ref } from 'vue';
    import { useDebounceFn } from '@vueuse/core';
    import { Config } from '@/modules/Core/configs/config';
    import { selectedImageId, userKnown, username } from '@/modules/Initial/data';
    import { emitCheckName } from '@/modules/Core/services/socket.service';
    import { useRouter } from 'vue-router';
    import { generateRandomImageId } from '@/modules/Login/utils/generate.util';
    import { loginUserWeb } from '@/modules/Login/services/login.service';
    import { ISocketCheckName } from 'shared-types/src';
    import { validateName } from '@/modules/Core/validators/name.validate';

    const router = useRouter();

    const isValidUsername = ref<boolean>(false);
    const errorUsername = ref<string | null>(null);

    onMounted(() => {
        if (!username.value) return;
        setTimeout(() => {
            checkName();
        }, 1000);
    });

    const debounceCheckName = useDebounceFn(() => {
        checkName();
    }, Config.DEBOUNCE_NAME_SOCKET);

    const checkName = () => {
        const socketName: ISocketCheckName = { username: username.value + '.3bot' };
        emitCheckName(socketName);
    };

    const listenToUsername = () => {
        debounceCheckName();
        validateUsername();
    };

    const validateUsername = () => {
        const isValidName = validateName(username.value);
        isValidUsername.value = isValidName.valid;
        errorUsername.value = isValidName.error;
    };

    const login = async () => {
        validateUsername();

        if (!isValidUsername.value) return;
        if (!userKnown.value) return;

        selectedImageId.value = generateRandomImageId();

        await loginUserWeb();

        await router.push({ name: 'login' });
    };
</script>

<style scoped></style>
