const fs = require('fs');

exports.exists = path => new Promise((resolve, reject) => {
  fs.stat(path, err => {
    if (err) return reject(err);
    resolve();
  });
});

exports.mkdir = path => this.exists(path).catch(() => new Promise((resolve, reject) => {
  fs.mkdir(path, err => {
    if (err) return reject(err);
    resolve()
  });
}));

exports.readFile = (path, options = 'utf8') => new Promise((resolve, reject) => {
  fs.readFile(path, options, (err, data) => {
    if (err) return reject(err);
    resolve(data);
  });
});

exports.writeFile = (path, data, options = 'utf8') => new Promise((resolve, reject) => {
  fs.writeFile(path, data, options, err => {
    if (err) return reject(err);
    resolve();
  });
});
