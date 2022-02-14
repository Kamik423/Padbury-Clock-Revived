# Padbury Clock Revived

![macOS](https://img.shields.io/badge/macOS-10.15-informational)
![swift](https://img.shields.io/badge/language-Swift-orange)
![license](https://img.shields.io/github/license/Kamik423/Padbury-Clock-Revived)

<img src="screenshots/screenshot-0.png" width=100%>

The [Padbury Clock](https://padbury.app) is a minimalist screensaver created by [Robert Padbury](https://twitter.com/Padbury).
It has not been updated in ages and actually broke for me during the Big Sur beta cycle (although that issue resolved itself).
At that point I decided to recreate it.

This new version retains most of the settings from the original (I honestly don't get what the alternate theme was supposed to do) and adds a new font family and font weight selection system.
The original screensaver used Neue Helvetica Ultra Light.
With the new version you will also be able to select San Francisco, Apple's new system font as the font used.
The night time mode from the original is also supported.

<img src="screenshots/screenshot-1.png" width=32%> <img src="screenshots/screenshot-2.png" width=32%> <img src="screenshots/screenshot-3.png" width=32%>
<img src="screenshots/screenshot-4.png" width=32%> <img src="screenshots/screenshot-5.png" width=32%> <img src="screenshots/screenshot-6.png" width=32%>

![settings](screenshots/settings.png)
## Installation

Download [the latest version](https://github.com/Kamik423/Padbury-Clock-Revived/releases/latest/download/Padbury.Clock.Revived.saver.zip) from [the releases page](https://github.com/Kamik423/Padbury-Clock-Revived/releases).

## Changelog

### 1.1.2 (2022-02-14)

* Dynamically load font weights and display them in the dropdown
* Compute font size dynamically based on enabled and disabled features
* Compute correct vertical centering instead of guesstimating it

### 1.1.1 (2022-02-10)

* Added option for main screen only
* Matched shade of red to original Padbury Clock
* Neue Helvetica now uses rounded, raised colons (TrueType Stylistic Sets 6 and 17). Not available for *Ultra Thin* and *Thin*
* Reduced deployment target to macOS 10.15
* Made SF Mono slightly smaller as not to cut it off with am/pm

### 1.1.0 (2022-02-10)

* Added more font options
* Added GitHub button
* Added version number to settings screen

### 1.0.2 (2022-02-09)

* Added night time mode
* Fixed settings not saving correctly

### 1.0.1 (2022-02-09)

* Rebuilt as Universal Binary

### 1.0.0 (2022-02-08)

* Initial Release

## License

This project is licensed under the [MIT license](LICENSE.md).

I could not get in touch with Robert Padbury about the intellectual property rights for his original screensaver.