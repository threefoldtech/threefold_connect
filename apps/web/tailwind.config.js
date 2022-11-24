const defaultTheme = require('tailwindcss/defaultTheme');
const colors = require('tailwindcss/colors');
// eslint-disable-next-line
const plugin = require('tailwindcss/plugin');

/** @type {import("@types/tailwindcss/tailwind-config").TailwindConfig } */
module.exports = {
    content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
    theme: {
        extend: {
            colors: {
                primary: colors.blue,
                secondary: colors.gray,
                threefoldPink: '#7E0A89',
                threefoldBlue: '#047967',
            },
            screens: {
                landscape: {
                    raw: '(orientation: landscape) and (max-height: 480px)',
                },
            },
        },
        fontFamily: {
            sans: [...defaultTheme.fontFamily.sans],
            serif: [...defaultTheme.fontFamily.serif],
            mono: [...defaultTheme.fontFamily.mono],
        },
    },
    plugins: [
        require('@tailwindcss/forms'),
        require('@tailwindcss/typography'),
        require('@tailwindcss/line-clamp'),
        require('@tailwindcss/aspect-ratio'),
        require('tailwindcss-debug-screens'),
    ],
};
