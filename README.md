[![CircleCI](https://circleci.com/gh/taylorjg/hangman-elm/tree/master.svg?style=svg)](https://circleci.com/gh/taylorjg/hangman-elm/tree/master)

# Description

This is my first foray into Elm programming.
This is (or will be) an Elm version of a [hangman React app](https://github.com/taylorjg/hangman) that I wrote recently.

# TODO

* ~~correctly chosen letters should have disabled green buttons~~
* ~~incorrectly chosen letters should have disabled red buttons~~
* ~~show letter buttons in three rows~~
* ~~add GameState type (InProgress / GameOver)~~
* ~~only process ChooseLetter msg when InProgress~~
* ~~when GameOver, display a NewGame button~~
* ~~set focus to NewGame button when displaying it~~
* ~~add ChooseWord msg and send it on NewGame button click~~
* ~~handle ChooseWord msg resetting game state~~
* ~~enhance ChooseWord msg to choose a random word from local dictionary~~
* ~~choose random word on startup~~
* ~~add remaining lives count~~
* ~~display remaining lives count~~
* ~~add Outcome type (Won | Lost) and model field of type Maybe Outcome~~
* ~~add keyboard support for A-Z buttons~~
* ~~ignore non A-Z keyboard input~~
* ~~display SVG drawing of gallows~~
* ~~get a random word via an AJAX call~~
* ~~handle AJAX errors by falling back to local dictionary again~~
* ~~display spinner whilst AJAX call is outstanding~~
* ~~display error panel for AJAX errors~~
* add view-related unit tests
* add an update-related fuzz test
* split Main.elm into modules

# Elm Features Used

Even though this is only a small app, it covers a lot of Elm features:

* Passing in data via flags
* Detecting DOM body keypress events via a port
* Effects: DOM.focus, Random, Http
* Task
* SVG
* Unit tests

And also:

* CI/CD on CircleCI
* Deployment to Heroku

# Links

* [Elm Manchester Meetup](https://www.meetup.com/elm-manchester)
* https://github.com/totallymoney/circleci-elm-compile/blob/master/Dockerfile
* https://semaphoreci.com/community/tutorials/building-and-testing-web-applications-with-elm
* https://stackoverflow.com/questions/39652083/how-can-i-add-event-handlers-to-the-body-element-in-elm
* https://stackoverflow.com/questions/31901397/how-to-set-focus-on-an-element-in-elm
* https://github.com/elm-lang/core/issues/924

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
