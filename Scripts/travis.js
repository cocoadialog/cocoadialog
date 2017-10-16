#!/usr/bin/env node

['./test', './build', './update-version'].reduce((chain, script) => chain
    .then(() => require(script))
    .catch(err => console.error(err) && process.exit(1))
    , Promise.resolve());
