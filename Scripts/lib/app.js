// Handle rejections and exceptions.
const errorHandler = err => {
  console.error(err instanceof Error && err.message || err);
  process.exit(err.code && /\d+/.test(err.code) && err.code || 1);
};
process.on('unhandledRejection', errorHandler);
process.on('unhandledRejection', errorHandler);

// Node.js
const path = require('path');

// NPM modules.
const dot = require('dot-prop');

// Local modules.
const fs = require('./fs');
const io = require('./io');
const plist = require('./plist');
const travis = require('./travis');

exports.name = 'cocoadialog';
exports.workspace = `${this.name}.xcworkspace`;

exports.baseDir = path.resolve(`${__dirname}/../../`);
exports.buildDir = path.join(this.baseDir, 'Build');
exports.derivedDataDir = path.join(this.baseDir, 'DerivedData');
exports.releaseDir = path.resolve(path.join(this.derivedDataDir, 'Build', 'Products', 'Release'));
exports.releaseApp = path.join(this.releaseDir, 'cocoadialog.app');
exports.infoPlist = path.join(this.releaseApp, 'Contents', 'Info.plist');

exports.data = {
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
  head: travis.running && travis.branch || io.execSync('git rev-parse --abbrev-ref HEAD') || 'unknown',
  lastTag: false,
  plist: {},
};

// Helper function for easily adding values from the CLI to the data object.
exports.addDataFromCommand = (name, command, convert = v => v) => io.spawn(command).then(value => dot.set(this.data, name, convert(value)));

exports.initData = () => Promise.resolve()
  // Retrieve built Info.plist.
  .then(() => fs.exists(this.infoPlist))
  .then(() => plist.read(this.infoPlist))
  .then(plist => (this.data.plist = plist))

  // Make sure we retrieve the whole repo's history (travis does a shallow clone of only 50 for the current branch).
  .then(() => travis.wrapCommand('git.fetch', 'git fetch --all --verbose --unshallow 2>/dev/null || git fetch --all --verbose'))

  // Determine current HEAD if Travis is not running.
  .then(() => travis.running || this.addDataFromCommand('head', `git rev-parse --abbrev-ref HEAD`, value => value.replace(/^(tags|heads)\//, '')))

  // Determine last tag.
  .then(() => this.addDataFromCommand('lastTag', `git describe --tags --abbrev=0 2>/dev/null || echo`, value => value || false))

  // Determine hashes.
  .then(() => this.addDataFromCommand('hash._current', `git rev-parse HEAD`))
  .then(() => this.addDataFromCommand('hash.master', `git show-ref -s master | head -1`))
  .then(() => this.addDataFromCommand('hash.dev', `git show-ref -s dev | head -1`))
  .then(() => this.data.lastTag && this.addDataFromCommand('hash.latestTag', `git show-ref -s ${this.data.lastTag} | head -1`))

  // Determine commits ahead.
  .then(() => this.addDataFromCommand('commitsAhead.master', `git rev-list --left-right --count master...HEAD | cut -f2 2>/dev/null`, value => parseInt(value) || 0))
  .then(() => this.addDataFromCommand('commitsAhead.dev', `git rev-list --left-right --count dev...HEAD | cut -f2 2>/dev/null`, value => parseInt(value) || 0))
  .then(() => this.data.lastTag && this.addDataFromCommand('commitsAhead.latestTag', `git rev-list --left-right --count ${this.data.lastTag}...master | cut -f2 2>/dev/null`, value => parseInt(value) || 0))
  .then(() => (this.data.commitsAhead.total = parseInt(travis.pullRequest ? this.data.commitsAhead.dev : this.data.commitsAhead.master)))
;
