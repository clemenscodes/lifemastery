import { AppProps } from 'next/app';
import Head from 'next/head';
import '../global.css';
import 'raf/polyfill';

// FIXME remove this once this reanimated fix gets released
// https://github.com/software-mansion/react-native-reanimated/issues/3355
if (process.browser) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    window._frameTimestamp = null;
}

import { enableSwcHack } from 'moti';
enableSwcHack();

const apexDomain = 'lifemastery.tech';
const appName = 'finance';
const prodCDN = `https://static.${appName}.${apexDomain}/public`;
const devCDN = `https://dev.static.${appName}.${apexDomain}/public`;

const isCloudRunProd = process.env.PROJECT_TYPE === 'production';
const isCloudRunDev = process.env.PROJECT_TYPE === 'development';
const isCloudRun = isCloudRunDev || isCloudRunProd;

const cloudRunAssetPrefix = isCloudRunProd ? prodCDN : devCDN;

const assetPrefix = isCloudRun ? cloudRunAssetPrefix : '';

function CustomApp({ Component, pageProps }: AppProps) {
    return (
        <>
            <Head>
                <title>Capital Tracker</title>
                <meta name="description" content="Capital Tracker" />
                <link rel="icon" href={`${assetPrefix}/favicon.ico`} />
            </Head>
            <main className="app">
                <Component {...pageProps} />
            </main>
        </>
    );
}

export default CustomApp;
