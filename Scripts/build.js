#!/usr/bin/env node
const xcode = require('./lib/xcode');

module.exports = xcode.run('build:Release', 'analyze:Release');
