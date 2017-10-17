#!/usr/bin/env node

process.on('uncaughtException', (err) => console.error(err.message));
require('commitizen/bin/git-cz');
