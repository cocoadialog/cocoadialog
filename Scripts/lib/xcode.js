// Local modules.
const app = require('./app');
const fs = require('./fs');
const travis = require('./travis');

exports.run = (...types) => {
  return types.reduce((chain, type) => {
    let [action, scheme] = type.split(':');
    return chain.then(() => travis.wrapCommand(`xcodebuild`, `xcodebuild -derivedDataPath ${app.derivedDataDir} -workspace ${app.workspace} -scheme ${scheme} ${action} | tee ${app.buildDir}/xcodebuild-${scheme}-${action}.log | xcpretty -f $(xcpretty-travis-formatter)`)).catch(err => console.error(err) && process.exit(1));
  }, fs.mkdir(app.buildDir));
};
