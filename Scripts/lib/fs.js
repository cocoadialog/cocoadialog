const fs = require('fs');

exports.exists = path => new Promise((resolve, reject) => {
  fs.stat(path, err => {
    if (err) reject(err);
    resolve();
  });
});

exports.mkdir = path => this.exists(path).catch(() => new Promise((resolve, reject) => {
  fs.mkdir(path, err => {
    if (err) reject(err);
    resolve()
  });
}));
