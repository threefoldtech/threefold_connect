import { ref, Ref } from 'vue';
import { useLocalStorage } from '@vueuse/core';
import { nanoid } from 'nanoid';

export const username: Ref<string> = useLocalStorage<string>('username', localStorage.getItem('username') as string);
export const appId = ref<string>();
export const scope = ref<string>();
export const state = ref<string>();
export const selectedImageId = ref<number>(0);
export const appPublicKey = ref<string>();
export const userKnown = ref<boolean>(false);
export const locationId: Ref<string> = useLocalStorage<string>(
    'locationId',
    localStorage.getItem('locationId') ? (localStorage.getItem('locationId') as string) : nanoid()
);
export const redirectUrl = ref<string>();
