#!/usr/bin/env node

const travis = require('./lib/travis');
const Promise = require('./lib/Promise');

if (!travis.running) {
  console.error('This script should only be executed inside a Travis CI instance.');
  process.exit(1);
}

module.exports = Promise.reduce(['./build', './analyze', './test', './update-version'], require);
