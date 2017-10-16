const execa = require('execa');

// Helper Promise functions based on above modules.
exports.execSync = command => execa.shellSync(command, {shell: '/bin/bash'}).stdout.toString().trim();

exports.pipe = command => execa(command, {shell: '/bin/bash', stderr: 'inherit', stdout: 'inherit'});

exports.echo = string => this.pipe(`echo -e "${string}"`);

exports.echon = string => this.pipe(`echo -en "${string}"`);

exports.spawn = command => execa(command, {shell: '/bin/bash'}).then(result => result.stdout.toString().trim());
