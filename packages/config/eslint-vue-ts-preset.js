module.exports = {
    env: {
        node: true,
    },
    plugins: ['@typescript-eslint'],
    globals: {
        defineProps: 'readonly',
        defineEmits: 'readonly',
        withDefaults: 'readonly',
    },
    extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/eslint-recommended',
        'plugin:@typescript-eslint/recommended',
        '@vue/typescript/recommended',
        'plugin:vue/vue3-recommended',
        'prettier',
        'plugin:typescript-enum/recommended',
    ],
    ignorePatterns: ['dist', '**/assets/*'],
    rules: {
        'vue/multi-word-component-names': 'off',
        'vue/no-setup-props-destructure': 'off',
        '@typescript-eslint/interface-name-prefix': 'off',
        '@typescript-eslint/explicit-function-return-type': 'off',
        '@typescript-eslint/explicit-module-boundary-types': 'off',
        '@typescript-eslint/no-explicit-any': 'off',
        '@typescript-eslint/ban-ts-ignore': 'off',
        '@typescript-eslint/ban-ts-comment': 'off',
    },
};
