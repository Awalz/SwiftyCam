# CHANGELOG

## Version 1.5.0
- Added support for front-facing camera tap to adjust exposure
- Added support for double tap gesture to switch cameras
- Added doubleTapCameraSwitch property
- Updated demo application with tap animation

## Version 1.4.0
- Added support for background audio during video capture
- Added allowBackgroundAudio property
- Fixed issue where delegate calls where occuring off the main thread
- Demo application has new, polished look to show off new features
- Minor bug fixed
- Updated README

## Version 1.3.1
- Minor bug fixes

## Version 1.3.0
- Added support for front facing flash
- Added support for front facing Retina Flash (on supported models)
- Added support for front facing torch mode for video capture

## Version 1.2.3
- Added support for Swift Package Manager

## Version 1.2.2
- Added support for low light boost in supported models
- Minor bug fixes
- Updated documentation

## Version 1.2.1
- Minor bug fixes
- Updated Documentation

## Version 1.2.0

- Enabling flash is now a boolean property rather than a function
- Flash for photos only flashes when photo is taken.
- Flash for videos enables the torch when video begins recording and disables flash when video finishes
- Fixed issue where **SwiftyCamDidChangeZoomLevel(zoomLevel:)** would be called from pinch gestures from front camera
- Minor bug fixes and enhancements