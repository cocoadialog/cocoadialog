const path = require('path');

// Local modules.
const app = require('./app');
const fs = require('./fs');
const io = require('./io');
const Promise = require('./Promise');
const travis = require('./travis');
const xcpretty = io.execSync('which xcpretty || echo');

exports.run = (...types) => fs.mkdir(app.buildDir)
  .then(() => Promise.reduce(types, type => {
    let [action, scheme] = type.split(':');
    let command = `xcodebuild -verbose -derivedDataPath ${app.derivedDataDir} -workspace ${app.workspace} -scheme ${scheme} ${action} | tee ${app.buildDir}/xcodebuild-${action}-${scheme}.log`;
    if (xcpretty) {
      command += ` | ${xcpretty} --formatter '${path.join(__dirname, 'xcprettyTravisFormatter.rb')}'`;
    }
    return travis.wrapCommand('xcodebuild', command, `xcodebuild ${action}:${scheme}`);
  }))
;
