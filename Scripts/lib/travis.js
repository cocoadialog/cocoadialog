// NPM modules.
const nano = require('nanoseconds');
const shortid = require('shortid');

// Local modules.
const io = require('./io');

/**
 * @type {string}
 */
exports.branch = process.env.TRAVIS_PULL_REQUEST_BRANCH || process.env.TRAVIS_BRANCH || io.execSync('git rev-parse --abbrev-ref HEAD') || 'unknown';

/**
 * @type {string}
 */
exports.currentTimerId = null;

/**
 * @type {Object}
 */
exports.timers = {};

/**
 * @type {boolean}
 */
exports.running = process.env.TRAVIS === 'true';

/**
 * @type {number|boolean}
 */
exports.pullRequest = process.env.TRAVIS_PULL_REQUEST !== 'false' && parseInt(process.env.TRAVIS_PULL_REQUEST) || false;

/**
 * @type {Object}
 */
exports.seenGroups = {};

/**
 * @param {string} group
 * @param {boolean} [track=true]
 * @return {string}
 */
exports.encode = (group, track = true) => {
  group = group.toLowerCase().replace(/[^a-z\d\-_.]+/g, '-').replace(/-$/, '');
  let i = 1;
  let parts = group.split('.');

  // Get the current count number.
  if (/^\d+$/.test(parts[parts.length - 1])) {
    i = parseInt(parts.pop());
    group = parts.join('.');
  }

  if (track && this.seenGroups[group]) {
    i = this.seenGroups[group] + 1;
  }
  this.seenGroups[group] = i;
  return `${group}.${i}`;
};

exports.end = group => this.running ? io.echo(`travis_fold:end:${this.encode(group, false)}\n`) : Promise.resolve();

/**
 * @param {string} group
 * @param {string} [description]
 * @param {boolean} [track=true]
 * @return {Promise.<T>}
 */
exports.start = (group, description = '', track = true) => {
  description = description && `\\033[33;1m${description}\\033[0m`;
  if (!this.running) {
    return description ? io.echo(`${description}`) : Promise.resolve();
  }
  return io.echo(`travis_fold:start:${this.encode(group, track)}${description}`);
};

/**
 * @param {string} group
 * @param {string} description
 * @param {boolean} [content]
 * @return {Promise.<T>}
 */
exports.wrap = (group, description, content) => {
  group = this.encode(group);
  return this.start(group, description, false)
    .then(() => io.echo(content))
    .then(() => this.end(group));
};

/**
 * @param {string} group
 * @param {string} command
 * @return {Promise.<T>}
 */
exports.wrapCommand = (group, command) => {
  group = this.encode(group);
  return this.start(group, command, false)
    .then(() => io.pipe(command))
    .then(() => this.end(group));
};

/**
 * @return {Promise.<T>}
 */
exports.timeStart = () => {
  if (!this.running) return Promise.resolve();
  let id = shortid.generate();
  if (!this.timers[id]) this.timers[id] = {};
  this.timers[id].start = nano(process.hrtime());
  this.currentTimerId = id;
  return io.echon(`travis_time:start:${id}\n\\033[0m`);
};

/**
 * @return {Promise.<T>}
 */
exports.timeFinish = () => {
  let id = this.currentTimerId;
  this.currentTimerId = null;
  if (!this.running || !this.timers[id]) return Promise.resolve();
  this.timers[id].end = nano(process.hrtime());
  let duration = this.timers[id].end - this.timers[id].start;
  return io.echon(`\ntravis_time:end:${id}:start=${this.timers[id].start},finish=${this.timers[id].end},duration=${duration}\n\\033[0m`);
};
