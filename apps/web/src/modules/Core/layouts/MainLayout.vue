<template>
    <div class="min-h-screen bg-white md:block flex justify-center items-center">
        <img
            class="absolute left-2 top-2 w-20 h-16 lg:w-32 lg:h-24 md:filter-whiteout"
            src="https://www.threefold.io/home/black_threefold_header.png#mx-auto#medium"
            alt=""
        />
        <div class="grid md:grid-cols-2">
            <div class="hidden md:block h-screen">
                <img src="/side.jpg" alt="" class="h-full w-full object-cover object-center" />
            </div>
            <div class="md:w-3/5 mx-auto px-8 md:px-0">
                <div class="flex items-center h-full">
                    <div class="flex flex-col">
                        <slot name="content"></slot>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts" setup></script>
