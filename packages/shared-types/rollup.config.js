import alias from '@rollup/plugin-alias';

import externals from 'rollup-plugin-node-externals';
import { nodeResolve } from '@rollup/plugin-node-resolve';
import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';

import typescript from 'rollup-plugin-typescript2';
import ttypescript from 'ttypescript';

import path from 'path';

const config = [
    // Build for Vue-compatibility
    {
        input: 'src/index.ts',
        plugins: [
            alias({
                entries: [
                    {
                        find: '@',
                        replacement: `${path.resolve(path.resolve(__dirname, './'), 'src')}`,
                    },
                ],
            }),
            typescript({
                typescript: ttypescript,
                useTsconfigDeclarationDir: true,
                emitDeclarationOnly: true,
            }),
            json(),
            externals({
                devDeps: true,
            }),
        ],
        output: {
            file: 'dist/es/index.js',
            format: 'es',
            sourcemap: true,
            exports: 'auto',
        },
    },
    {
        // Build for Nest-compatibility
        input: 'src/index.ts',
        plugins: [
            alias({
                entries: [
                    {
                        find: '@',
                        replacement: `${path.resolve(path.resolve(__dirname, './'), 'src')}`,
                    },
                ],
            }),
            typescript({
                typescript: ttypescript,
                useTsconfigDeclarationDir: true,
                emitDeclarationOnly: true,
            }),
            externals({
                devDeps: true,
            }),
            nodeResolve({
                preferBuiltins: true,
            }),
            commonjs(),
            json(),
        ],
        output: {
            file: 'dist/cjs/index.js',
            format: 'cjs',
            sourcemap: true,
            exports: 'auto',
        },
    },
];
export default config;
