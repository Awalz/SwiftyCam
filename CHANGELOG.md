# CHANGELOG

## Version 2.3.0
- Added support to vertically swipt to zoom
- Added ```swipeToZoom``` property
- Added support for inverting zoom directions for swipeToZoom
- Added ```swipeToZoomInverted``` property

## Version 2.2.2
- Fixed issue with landscape orientation 
- Fixed issue with SwiftyCam crashing by multiple double-tap camera switching

## Version 2.2.1
- Added Carthage support

## Version 2.2.0
- Added support for landsacpe device orientations
- Added maximum zoom level property

## Version 2.1.0
- Added ability to change default camera orientation
- Added `defaultCamera` property
- Minor bug fixes

## Version 2.0.0
- Changed `SwiftyCamViewController` delegate function naming
- Changed `kMaximumVideoDuration` property to `maximumVideoDuration`
- Changed `endVideoRecording()` to `stopVideoRecording`
- Fixed issue with front flash not starting before video recording
- Removed ability to disable prompting to app settings if permissions are not approved
- Updated demo application
- Minor bug fixes

## Version 1.5.1
- Minor bug fixes
- Enhancemenents to demo project

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