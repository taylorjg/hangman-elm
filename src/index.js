import './main.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import { version } from '../app-version.json';

const app = Main.embed(document.getElementById('root'), { version });

document.body.onkeypress = e =>
  app.ports.bodyKeyPress.send(e.keyCode);

registerServiceWorker();
