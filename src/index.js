import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import { version } from '../elm-package.json';

console.log(`version from elm-package.json: ${version}`);

Main.embed(document.getElementById('root'), { version });

registerServiceWorker();
