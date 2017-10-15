#!/usr/bin/env node

// Node.js
const fs = require('fs');
const path = require('path');

// Modules.
const dot = require('dot-prop');
const execa = require('execa');
const semver = require('semver-utils');
const simplePlist = require('simple-plist');

// Project.
const appName = 'cocoadialog';
const workspace = `${appName}.xcworkspace`;

const baseDir = path.resolve(`${__dirname}/../`);
const buildDir = path.join(baseDir, 'Build');
const derivedDataDir = path.join(baseDir, 'DerivedData');
const releaseDir = path.resolve(path.join(derivedDataDir, 'Build', 'Products', 'Release'));
const releaseApp = path.join(releaseDir, 'cocoadialog.app');
const infoPlist = path.join(releaseApp, 'Contents', 'Info.plist');

const isTravis = () => {
  return process.env.TRAVIS === 'true';
};

const pipe = command => execa.shell(command, {stderr: 'inherit', stdout: 'inherit'}).catch(result => {
  console.error(result.message);
  process.exit(result.code || 1);
});

const readPlist = file => new Promise((resolve, reject) => {
  simplePlist.readFile(file, (err, data) => {
    if (err) reject(err);
    resolve(data);
  });
});

const writePlist = (file, data) => new Promise((resolve, reject) => {
  simplePlist.writeFile(file, data, err => {
    if (err) reject(err);
    resolve();
  });
});

const spawn = command => execa.shell(command)
  .then(result => result.stdout.trim())
  .catch(result => {
    console.error(result.message);
    process.exit(result.code || 1);
  })
;

const exists = path => new Promise((resolve, reject) => {
  fs.stat(path, err => {
    if (err) reject(err);
    resolve();
  });
});

const mkdir = path => exists(path).catch(() => new Promise((resolve, reject) => {
  fs.mkdir(path, err => {
    if (err) reject(err);
    resolve()
  });
}));

const fold = {
  encode(group) {
    return group.replace(/[^A-Za-z\d]+/g, '-').replace(/-$/, '');
  },

  format(type, group) {
    return isTravis() ? `echo "\ntravis_fold:${type}:${this.encode(group)}\r"` : '';
  },

  write(type, group) {
    let fold = this.format(type, group);
    return fold !== '' ? pipe(fold) : Promise.resolve();
  },

  end(group) {
    return this.write('end', group);
  },

  start(group) {
    return this.write('start', group);
  },

  wrap(group, command) {
    return this.start(group)
      .then(() => pipe(command))
      .then(() => this.end(group));
  }
};

let data = {
  commitsAhead: {
    dev: 0,
    latestTag: 0,
    master: 0
  },
  hash: {
    _current: '',
    dev: '',
    latestTag: false,
    master: ''
  },
  hashLength: 7,
  head: 'master',
  lastTag: false,
  plist: {},
  pullRequest: isTravis() && process.env.TRAVIS_PULL_REQUEST !== 'false' && parseInt(process.env.TRAVIS_PULL_REQUEST) || false
};

// Helper function for easily adding values from the CLI to the data object.
const addData = (name, command, convert = v => v) => spawn(command).then(value => dot.set(data, name, convert(value)));

const xcodebuild = (...types) => {
  types = Array.from(types);
  return types.reduce((chain, type) => {
    let [scheme, action] = type.split(':');
    return chain.then(() => fold.wrap(`xcodebuild.${scheme}.${action}`, `xcodebuild -derivedDataPath ${derivedDataDir} -workspace ${workspace} -scheme ${scheme} ${action} | tee ${buildDir}/xcodebuild-${scheme}-${action}.log | xcpretty -f $(xcpretty-travis-formatter)`));
  }, Promise.resolve());
};

// Ensure our custom Build directory exists.
mkdir(buildDir)

  // Xcode Test & Build.
  .then(() => xcodebuild('Debug:test', 'Release:build'))

  // Retrieve built Info.plist.
  .then(() => exists(infoPlist))
  .then(() => readPlist(infoPlist))
  .then(plist => (data.plist = plist))

  // Determine current HEAD.
  .then(() => addData('head', `git rev-parse --abbrev-ref HEAD`, value => value.replace(/^(tags|heads)\//, '')))

  // Determine last tag.
  .then(() => addData('lastTag', `git describe --tags --abbrev=0 2>/dev/null || echo`, value => value || false))

  // Determine hashes.
  .then(() => addData('hash._current', `git rev-parse --short=${data.hashLength} HEAD`))
  .then(() => addData('hash.master', `git show-ref --abbrev=${data.hashLength} -s master | head -1`))
  .then(() => addData('hash.dev', `git show-ref --abbrev=${data.hashLength} -s dev | head -1`))
  .then(() => data.lastTag && addData('hash.latestTag', `git show-ref --abbrev=${data.hashLength} -s ${data.lastTag} | head -1`))

  // Determine commits ahead.
  .then(() => addData('commitsAhead.master', `git rev-list --left-right --count master...HEAD | cut -f2 2>/dev/null`), value => parseInt(value) || 0)
  .then(() => addData('commitsAhead.dev', `git rev-list --left-right --count dev...HEAD | cut -f2 2>/dev/null`, value => parseInt(value) || 0))
  .then(() => data.lastTag && addData('commitsAhead.latestTag', `git rev-list --left-right --count ${data.lastTag}...master | cut -f2 2>/dev/null`, value => parseInt(value) || 0))
  .then(() => (data.commitsAhead.total = parseInt(data.pullRequest ? data.commitsAhead.dev : data.commitsAhead.master)))

  .then(() => {
    // Parse the existing CFBundleVersion from the app.
    let version = semver.parse(data.plist.CFBundleVersion) || semver.parse('0.0.0');

    // Merge in the last tag values.
    if (data.lastTag) {
      let lastTagVersion = semver.parse(data.lastTag);
      version.version = lastTagVersion.version || version.version;
      version.major = lastTagVersion.major || version.major;
      version.minor = lastTagVersion.minor || version.minor;
      version.patch = lastTagVersion.patch || version.patch;
      version.release = lastTagVersion.release || data.head;
      version.build = lastTagVersion.build || version.build;
    }
    else {
      version.release = data.head;
    }

    let count = 0;
    let hash;

    // If the current hash is the same as master and the last tag, then this is a release.
    if (!data.lastTag || !data.hash.lastTag || (data.hash._current !== data.hash.lastTag && data.hash.master !== data.hash.lastTag)) {
      hash = data.hash._current;
    }

    // Determine the proper number of commits ahead.
    if (data.pullRequest) {
      count = data.commitsAhead.dev;
      version.release = `pr${data.pullRequest}`;
    }
    else if (data.lastTag) {
      count = data.commitsAhead.latestTag;
    }
    else if (data.head === 'dev') {
      count = data.commitsAhead.master;
    }
    else {
      count = data.commitsAhead.total || 0;
    }

    count = parseInt(count);

    // Add the count and hash to as the build identifier.
    version.build = count ? `${count}-${hash}` : hash;

    return version;
  })

  .then(version => {
    data.version = semver.stringify(version);
    data.plist.CFBundleVersion = data.version;
    data.plist.CFBundleShortVersionString = data.version;
    return writePlist(infoPlist, data.plist);
  })
  .then(() => {
    delete data.plist;
    console.log(`Successfully updated ./${path.relative(baseDir, infoPlist)} to ${data.version}`);
    return data;
  })
  .then(console.log)
  .catch(err => console.error(err) && process.exit(1))
;
