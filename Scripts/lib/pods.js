// Node.js
const path = require('path');

// Local modules.
const app = require('./app');

class Pods {

  constructor() {
    // Static names.
    this.name = 'Pods';
    this.workspace = `${this.name}.xcworkspace`;
    this.project = `${this.name}.xcodeproj`;
    this.projectConfig = path.join(this.project, 'project.pbxproj');

    // Directories.
    this.projectConfigPath = path.join(app.baseDir, this.name, this.projectConfig);
  }

}

module.exports = new Pods();