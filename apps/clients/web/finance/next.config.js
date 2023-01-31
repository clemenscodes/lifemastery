const { join } = require('path');
const { withNx } = require('@nrwl/next/plugins/with-nx');
const { withExpo } = require('@expo/next-adapter');
const withPlugins = require('next-compose-plugins');
const withTM = require('next-transpile-modules')(['solito', 'nativewind', 'moti']);

module.exports = async (phase, { defaultConfig }) => {
    /**
     * @type {import('@nrwl/next/plugins/with-nx').WithNxOptions}
     **/
    const nextConfig = {
        // reanimated (and thus, Moti) doesn't work with strict mode currently...
        // https://github.com/nandorojo/moti/issues/224
        // https://github.com/necolas/react-native-web/pull/2330
        // https://github.com/nandorojo/moti/issues/224
        // once that gets fixed, set this back to true
        images: {
            unoptimized: true,
        },
        reactStrictMode: true,
        swcMinify: true,
        output: 'standalone',
        experimental: {
            outputFileTracingRoot: join(__dirname, '../../../../'),
            forceSwcTransforms: true, // set this to true to use reanimated + swc experimentally
        },
        nx: {
            // Set this to true if you would like to to use SVGR
            // See: https://github.com/gregberge/svgr
            svgr: true,
        },
        // reduces bundle size and tree shaking issues a little bit
        // see https://github.com/vercel/next.js/issues/12557#issuecomment-1351639046
        webpack(config) {
            config.module.rules.push({
                test: /index\.(js|mjs|jsx|ts|tsx)$/,
                sideEffects: false,
            });
            return config;
        },
    };

    const plugins = [withTM, withExpo];
    const updated = withPlugins(plugins, withNx(nextConfig));
    const config = updated(phase, {
        ...defaultConfig,
        ...nextConfig,
    });
    return config;
};
