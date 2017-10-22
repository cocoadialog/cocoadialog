const execa = require('execa');

// Helper Promise functions based on above modules.
exports.execSync = command => execa.shellSync(command, {shell: '/bin/bash'}).stdout.toString().trim();

exports.pipe = (command, printCommand = false) => {
  if (printCommand) {
    console.log(`$ ${command}\n`);
  }
  // Piped commands should always exit on error.
  return execa(command, {shell: '/bin/bash', stderr: 'inherit', stdout: 'inherit'})
    .catch(err => process.exit(err.code && /\d+/.test(err.code) && err.code || 1));
};

exports.echo = string => this.pipe(`echo -e "${string}"`);

exports.echon = string => this.pipe(`echo -en "${string}"`);

exports.spawn = command => execa(command, {shell: '/bin/bash'}).then(result => result.stdout.toString().trim());
