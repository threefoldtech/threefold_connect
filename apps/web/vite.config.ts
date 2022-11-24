import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import * as path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [vue()],
    server: {
        port: 3000,
        proxy: {
            '/api': {
                target: 'http://localhost:3001',
            },
            '/socket.io': {
                target: 'http://localhost:3001',
            },
        },
    },

    resolve: {
        alias: {
            '@': path.resolve(__dirname, '/src'),
        },
    },
});
