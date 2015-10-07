#!/usr/bin/env python

"""ProgressBar -- for use with CocoaDialog (http://cocoadialog.sourceforge.net/)"""

__author__ = "Paul Bissex <pb@e-scribe.com>"
__version__ = "0.2.1"
__license__ = "MIT"

import os, sys

class ProgressBar:
    """Simple class for displaying progress bars using CocoaDialog"""

# Change CD_BASE to reflect the location of Cocoadialog on your system
#   CD_BASE = "${BUILT_PRODUCTS_DIR}"
#   CD_PATH =os.path.join(CD_BASE, "${PROJECT_NAME}.app/Contents/MacOS/${PROJECT_NAME}")
    CD_PATH = "usr/local/bin/cocoadialog"
    CD_PATH = sys.argv[1]

    def __init__(self, title="Progress", message="", percent=0):
        """Create progress bar dialog"""
        template = "%s progressbar --title '%s' --text '%s' --percent %d --stoppable"
        self.percent = percent
        self.pipe = os.popen(template % (ProgressBar.CD_PATH, title, message, percent), "w")
        self.message = message
            
    def update(self, percent, message=False):
        """Update progress bar (and message if desired)"""
        if message:
            self.message = message  # store message for persistence
        self.pipe.write("%d %s\n" % (percent, self.message))
        self.pipe.flush()
        
    def finish(self):
        """Close progress bar window"""
        self.pipe.close()


if __name__ == "__main__":
    # Sample usage
    import time
    bar = ProgressBar(title="ProgressBar.py Test")
    
    for percent in range(25):
        time.sleep(.01)
        bar.update(percent*2, "Test Starting...")
        
    for percent in range(25,50):
        time.sleep(.01)
        bar.update(percent*2, "Test Finishing...")
     
    time.sleep(.5)
    bar.finish()