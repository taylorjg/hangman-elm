# Description

This is my first foray into Elm programming.
This is (or will be) an Elm version of a [hangman React app](https://github.com/taylorjg/hangman) that I wrote recently.

# Installation

I encountered a problem trying to install `create-elm-app` globally:

```
$ sudo npm install -g create-elm-app
Password:
npm WARN deprecated node-uuid@1.4.8: Use uuid module instead
/usr/local/bin/elm-app -> /usr/local/lib/node_modules/create-elm-app/bin/elm-app-cli.js
/usr/local/bin/create-elm-app -> /usr/local/lib/node_modules/create-elm-app/bin/create-elm-app-cli.js

> fsevents@1.1.2 install /usr/local/lib/node_modules/create-elm-app/node_modules/elm-test/node_modules/fsevents
> node install

[fsevents] Success: "/usr/local/lib/node_modules/create-elm-app/node_modules/elm-test/node_modules/fsevents/lib/binding/Release/node-v57-darwin-x64/fse.node" already installed
Pass --update-binary to reinstall or --build-from-source to recompile

> fsevents@1.1.3 install /usr/local/lib/node_modules/create-elm-app/node_modules/fsevents
> node install

[fsevents] Success: "/usr/local/lib/node_modules/create-elm-app/node_modules/fsevents/lib/binding/Release/node-v57-darwin-x64/fse.node" already installed
Pass --update-binary to reinstall or --build-from-source to recompile

> elm@0.18.0 install /usr/local/lib/node_modules/create-elm-app/node_modules/elm
> node install.js

Error extracting darwin-x64.tar.gz - Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/create-elm-app/node_modules/elm/Elm-Platform'
npm ERR! code ELIFECYCLE
npm ERR! errno 1
npm ERR! elm@0.18.0 install: `node install.js`
npm ERR! Exit status 1
npm ERR!
npm ERR! Failed at the elm@0.18.0 install script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     /Users/jontaylor/.npm/_logs/2018-02-07T14_32_34_739Z-debug.log
$ 
```

After reading [this](https://github.com/gdotdesign/elm-github-install/issues/21), I got it working by running:

```
sudo npm install -g create-elm-app --unsafe-perm=true --allow-root
```
