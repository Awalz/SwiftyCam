/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */


import UIKit

// MARK: Public Protocol Declaration

public protocol SwiftyCamViewControllerDelegate {
    
    // Called when SwiftyCamViewController takes a photo. Returns a UIImage
    
    func SwiftyCamDidTakePhoto(_ photo:UIImage)
    
    // Called when SwiftyCamViewController begins recording video
    
    func SwiftyCamDidBeginRecordingVideo()
    
    // Called when SwiftyCamViewController finishes recording video
    
    func SwiftyCamDidFinishRecordingVideo()
    
    // Called when SwiftyCamViewController is done processing video. Returns the URL of the video location
    
    func SwiftyCamDidFinishProcessingVideoAt(_ url: URL)
    
    // Called when SwiftyCamViewController switches between front or rear camera. Return the current CameraSelection
    
    func SwiftyCamDidSwitchCameras(camera: SwiftyCamViewController.CameraSelection)
    
    // Called when SwiftyCamViewController view is tapped and begins focusing at that point
    // Will only be called if tapToFocus is set to true
    // Not supported on front facing camera
    // Returns the CGPoint tap location
    
    func SwiftyCamDidFocusAtPoint(focusPoint: CGPoint)
    
    // Called when SwiftyCamViewController view changes zoom level
    // Will only be called if pinchToZoom is set to true
    // Not supported on front facing camera
    // Returns the current zoomLevel
    
    func SwiftyCamDidChangeZoomLevel(zoomLevel: CGFloat)
    
    // Called if app permissions are denied for either Camera or Microphone
    // Only called if promptToAppPrivacySettings is set to false
    
    func SwiftyCamDidFailCameraPermissionSettings()
}

public extension SwiftyCamViewControllerDelegate {
    func SwiftyCamDidTakePhoto(_ photo:UIImage) {
        // Optional
    }
    
    func SwiftyCamDidBeginRecordingVideo() {
        // Optional
    }
    
    func SwiftyCamDidFinishRecordingVideo() {
        // Optional
    }
    
    func SwiftyCamDidFinishProcessingVideoAt(_ url: URL) {
        // Optional
    }
    
    func SwiftyCamDidSwitchCameras(camera: SwiftyCamViewController.CameraSelection) {
        // Optional
    }
    
    func SwiftyCamDidFocusAtPoint(focusPoint: CGPoint) {
        // Optional
    }
    
    func SwiftyCamDidChangeZoomLevel(zoomLevel: CGFloat) {
        // Optional
    }
    
    func SwiftyCamDidFailCameraPermissionSettings() {
        // Optional
    }
}



