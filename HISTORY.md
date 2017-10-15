# History of cocoadialog

## Mailing lists

https://sourceforge.net/p/cocoadialog/mailman/cocoadialog-announce/
https://sourceforge.net/p/cocoadialog/mailman/cocoadialog-users/

## Version 3

See current [CHANGELOG.md](CHANGELOG.md)

## Version 2.3 == "3.0.0-betaX"

**Developer**: [Mark Carver](https://github.com/markcarver)
**Minimum OS X**:  10.4
**Maximum OS X**:  Unknown, probably somewhere around 10.8

> **NOTE:**
> Technically, yes, there are `3.0.0-betaX` releases floating out there in the world that start with the major version `3`.
>
> Realistically, however, these releases never made their way into any sort of "official stable release" and were truly just alpha level experimentation. The code, features, and options were based entirely on cocoadialog 2 and do not reflect cocoadialog 3 in any way.
>
> So for brevity and to avoid a "What happened to cocoadialog 3?" fiasco, we're simply going to ignore these betas and treat them like a couple minor version bump releases of cocoadialog 2 (e.g. 2.3.x, where "x" represents the "beta version").

### 2.3.7 == "3.0.0-beta7" (May 17, 2012 - last known release)
- Fixed Bug [#45 - notify not working in cocoaDialog beta 3.0.0 beta6 on 10.6](https://github.com/cocoadialog/cocoadialog/issues/45)

### 2.3.6 == "3.0.0-beta6" (April 16, 2012)
- Fixed Bug [#34: Select dropdown not auto-selected / impossible to access with keyboard](https://github.com/cocoadialog/cocoadialog/issues/34)
- Fixed Bug [#37: Using standard-dropdown without specifying button1?](https://github.com/cocoadialog/cocoadialog/issues/37)
- Fixed Bug [#39: --with-directory not working for fileselect/filesave](https://github.com/cocoadialog/cocoadialog/issues/39)
- Fixed Bug [#40: timeout w/ ok-msgbox](https://github.com/cocoadialog/cocoadialog/issues/40)
- Fixed Bug [#41: fileselect --select-multiple only returns one file](https://github.com/cocoadialog/cocoadialog/issues/41)

### 2.3.5 == "3.0.0-beta5" (October 29, 2011)
- Fixed Bug [#20 Controls should float by default](https://github.com/cocoadialog/cocoadialog/issues/20)
- Fixed Bug [#27 textbox control isn't working](https://github.com/cocoadialog/cocoadialog/issues/27)
- Fixed Bug [#28 Proper exit status and run loop restructuring](https://github.com/cocoadialog/cocoadialog/issues/28)
- Added Feature [#8 Timeout label in three button controls](https://github.com/cocoadialog/cocoadialog/issues/8)
- Added Feature [#17 Allow TBCs to display an empty value alert sheet](https://github.com/cocoadialog/cocoadialog/issues/17)

### 2.3.4 == "3.0.0-beta4" (October 21, 2011)
- Fixed Bug [#24 CDBubbleControl does not respond to --click-path or --click-arg](https://github.com/cocoadialog/cocoadialog/issues/24)
- Fixed Bug [#26 Fix FileSelect and FileOpen dialogs](https://github.com/cocoadialog/cocoadialog/issues/26)
- Added Feature [#21 Place a CocoaDialog window somewhere else](https://github.com/cocoadialog/cocoadialog/issues/21)
- Added Feature [#25 Add global option to specify --icon-type](https://github.com/cocoadialog/cocoadialog/issues/25)
- Added Feature - New runModes `update` and `update-automatic` for [#18 Sparkle Updater Integration](https://github.com/cocoadialog/cocoadialog/issues/18) to be used to update to beta5

### 2.3.3 == "3.0.0-beta3" (Unknown)
- History lost through time.

### 2.3.2 == "3.0.0-beta2" (Unknown)
- History lost through time.

### 2.3.1 == "3.0.0-beta1" (Unknown)
- History lost through time.

## Version 2

**Developer**: [Mark A. Stratman](https://github.com/mstratman)
**Minimum OS X**:  10.4
**Maximum OS X**:  Unknown, probably somewhere around 10.6

### 2.1.1  (April 26, 2006 - last known release)
- Implemented --packages-as-directories in fileselect.

### 2.1.0 (February 26, 2006)
- Compiled as a Universal Binary
- Intelligent resizing to accommodate --informative-text in all inputbox dialogs, all msgbox dialogs, and textbox. Same for --text in all dropdown dialogs.
- New "filesave" dialogs
- Added --packages-as-directories option to fileselect.
- Added --x-placement and --y-placement to bubble.

### 2.0.0 (January 2, 2006)
- Added bubble dialog.
- Added secure modes for inputbox and standard-inputbox.
- The application now runs as a background app. This means no more annoying menu or dock icon!
- Some dialogs can be floated above all other applications.
- Timeouts on several dialogs.
- Intelligent button resizing
- Added custom icon support to msgbox, ok-msgbox, and standard-msgbox.
- Added --help options (still needs improvement).
- Added --select-only-directories to fileselect.
- Restructured project directory, code hierarchy, and refactored much of the code.
- Cleaned up the look of several dialogs.
- Progressbar won't be displayed right away, to prevent showing for very short operations.
- Bug fixes (string-input on inputboxes, missing deallocs).
- New application icon.

## Version 1

**Developer**: [Mark A. Stratman](https://github.com/mstratman)
**Minimum OS X**:  Unknown
**Maximum OS X**:  Unknown

### 1.2.2 (Unknown, didn't release)
- Allan's patch

### 1.2.1  (January 2005 - last known release)
- (Did I even release this?).
- Wout's patch: added --no-show, --float, --timeout and --help options turned into a background app so that the dialog icon does not show up in the menu bar. This, together with float, is very useful for loginhooks.

### 1.2.0  (December 28, 2004)
- added dropdown and standard-dropdown controls.

### 1.1.3  (May 11, 2004)
- fixed handling of multi-line input to progressbar.

### 1.1.2 (May 10, 2004)
- fixed crash that would occur when printing return values containing non-Roman characters. Thanks to Nobumi Iyanaga for finding this.
- added "debug" class method to CDControl and got rid of those printf()s.

### 1.1.1 (April 26, 2004)
- starting to use x.y.z versioning (instead of x.y)
- progressbar incorrectly printed error with --debug (runControlFromOptions: always returned nil, which should only happen on error).  This has been fixed.
- progressbar character encoding bug fixed. should now properly handle UTF8 labels read from stdin. see bug 942012 on sf.net page.  thanks to J-F Boquillard for finding and fixing this.

### 1.1 (April 22, 2004)
- added inputbox, standard-inputbox
- textbox window no longer closes on escape unless there's a "Cancel" button
- fixed error handling for textbox when --text-from-file file is invalid.

### 1.0 (April 11, 2004)
- initial release on [SourceForge](https://sourceforge.net/projects/cocoadialog/)
