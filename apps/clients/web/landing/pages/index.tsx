// import next config in any page file to somehow make next aware of correct folder structure... MAGIC
// see https://github.com/nrwl/nx/issues/9017#issuecomment-1284740346
import path from 'path';
path.resolve('./next.config.js');
import { initializeApp } from 'firebase/app';
import { log } from '@utils';
import { A, H1, P, View } from '@shared';
const devConfig = {
    apiKey: 'AIzaSyCdvFCH43ZS_30Lovqr3KjS77vCN_eIARc',
    authDomain: 'landing-development.firebaseapp.com',
    projectId: 'landing-development',
    storageBucket: 'landing-development.appspot.com',
    messagingSenderId: '199081405669',
    appId: '1:199081405669:web:17551acbb212b822fc780c',
    measurementId: 'G-FR41SE2YMD',
};

const prodConfig = {
    apiKey: 'AIzaSyC0s0wGP-hOWs8j8918DXLhdI_al9aR-oo',
    authDomain: 'landing-production-375914.firebaseapp.com',
    projectId: 'landing-production-375914',
    storageBucket: 'landing-production-375914.appspot.com',
    messagingSenderId: '219710367033',
    appId: '1:219710367033:web:cd0911791d87d9e76174e8',
    measurementId: 'G-BTVBN6NCWV',
};
const firebaseConfig = process.env.NODE_ENV === 'production' ? prodConfig : devConfig;

export function Index() {
    const app = initializeApp(firebaseConfig);
    log(app);
    return (
        <View className="flex-1 items-center justify-center p-3">
            <H1>Welcome to LifeMastery!👋</H1>
            <P>This site is a work in progress.</P>
            <A href="https://finance.lifemastery.tech">Visit Finance App</A>
        </View>
    );
}

export default Index;
