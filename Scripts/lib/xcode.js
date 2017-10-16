// Local modules.
const app = require('./app');
const fs = require('./fs');
const Promise = require('./Promise');
const travis = require('./travis');

exports.run = (...types) => fs.mkdir(app.buildDir).then(() => Promise.reduce(types, type => {
  let [action, scheme] = type.split(':');
  return travis.wrapCommand(`xcodebuild`, `xcodebuild -derivedDataPath ${app.derivedDataDir} -workspace ${app.workspace} -scheme ${scheme} ${action} | tee ${app.buildDir}/xcodebuild-${scheme}-${action}.log | xcpretty -f $(xcpretty-travis-formatter)`);
}));
