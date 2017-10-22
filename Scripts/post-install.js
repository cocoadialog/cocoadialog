#!/usr/bin/env node

// Node.js modules.
const path = require('path');

// Local modules.
const fs = require('./lib/fs');
const Promise = require('./lib/Promise');
const app = require('./lib/app');
const pods = require('./lib/pods');

// Replace specific MacOSX SDK versions with the latest/current one installed.
// This helps avoid any warnings about unable to link frameworks for pods.
Promise.reduce([app, pods], project => {
  let sdks = [];
  return fs.readFile(project.projectConfigPath)
    .then(data => {
      data = data.replace(/MacOSX\d+\.\d+\.sdk/g, match => {
        if (sdks.indexOf(match) === -1) {
          sdks.push(match);
        }
        return 'MacOSX.sdk';
      });
      if (!sdks.length) {
        console.log(`${project.name}: SDKs up to date.`);
        return Promise.resolve();
      }
      return fs.writeFile(project.projectConfigPath, data);
    })
    .then(() => {
      if (sdks.length) {
        console.log(`${project.name}: ${sdks.join(',')} => MacOSX.sdk`);
      }
    })
  }
);
