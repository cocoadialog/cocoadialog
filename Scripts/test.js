#!/usr/bin/env node
const xcode = require('./lib/xcode');

module.exports = xcode.run('test:Tests', 'clean build:Debug');
