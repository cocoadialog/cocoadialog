#!/usr/bin/env node

// NPM modules.
const semver = require('semver-utils');

// Local modules.
const app = require('./lib/app');
const plist = require('./lib/plist');
const travis = require('./lib/travis');

// Initialize the application data.
module.exports = app.initData()
  // Update the version based on data.
  .then(() => {
    // Parse the existing CFBundleVersion from the app.
    let version = semver.parse(app.data.plist.CFBundleVersion) || semver.parse('0.0.0');

    // Merge in the last tag values.
    if (app.data.lastTag) {
      let lastTagVersion = semver.parse(app.data.lastTag);
      version.version = lastTagVersion.version || version.version;
      version.major = lastTagVersion.major || version.major;
      version.minor = lastTagVersion.minor || version.minor;
      version.patch = lastTagVersion.patch || version.patch;
      version.release = lastTagVersion.release || app.data.head;
      version.build = lastTagVersion.build || version.build;
    }
    else {
      version.release = app.data.head;
    }

    let count = 0;
    let hash;

    // If the current hash is the same as master and the last tag, then this is a release.
    if (!app.data.lastTag || !app.data.hash.lastTag || (app.data.hash._current !== app.data.hash.lastTag && app.data.hash.master !== app.data.hash.lastTag)) {
      hash = app.data.hash._current.substr(0, 7);
    }

    // Determine the proper number of commits ahead.
    if (travis.pullRequest) {
      count = app.data.commitsAhead.dev;
      version.release = `pr${travis.pullRequest}`;
    }
    else if (app.data.lastTag) {
      count = app.data.commitsAhead.latestTag;
    }
    else if (app.data.head === 'dev') {
      count = app.data.commitsAhead.master;
    }
    else {
      count = app.data.commitsAhead.total || 0;
    }

    count = parseInt(count);

    // Add the count and hash to as the build identifier.
    if (count && hash) {
      version.build = `${count}-${hash}`;
    }
    else if (hash) {
      version.build = hash;
    }
    else {
      version.build = null;
    }

    return version;
  })
  .then(version => {
    app.data.version = semver.stringify(version);
    app.data.plist.CFBundleVersion = app.data.version;
    app.data.plist.CFBundleShortVersionString = app.data.version;
    return plist.write(app.infoPlist, app.data.plist);
  })
  .then(() => {
    delete app.data.plist;
    return travis.wrap('info.plist', `Info.plist version: ${app.data.version}`, JSON.stringify(app.data, null, 2));
  })
  .catch(err => console.error(err) && process.exit(1))
;
