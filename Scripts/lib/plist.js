const simplePlist = require('simple-plist');

exports.read = file => new Promise((resolve, reject) => {
  simplePlist.readFile(file, (err, data) => {
    if (err) reject(err);
    resolve(data);
  });
});

exports.write = (file, data) => new Promise((resolve, reject) => {
  simplePlist.writeFile(file, data, err => {
    if (err) reject(err);
    resolve();
  });
});
