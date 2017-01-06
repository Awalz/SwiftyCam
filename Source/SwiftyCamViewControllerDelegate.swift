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

/// Delegate for SwiftyCamViewController

public protocol SwiftyCamViewControllerDelegate {
    
    /**
     SwiftyCamViewControllerDelegate function called when the takePhoto() function is called
     
     - Parameter photo: UIImage captured from the current session
     
     */
    
    
    func SwiftyCamDidTakePhoto(_ photo:UIImage)
    
    /// SwiftyCamViewControllerDelegate function called when SwiftyCamViewController begins recording video
    
    func SwiftyCamDidBeginRecordingVideo()
    
    /// SwiftyCamViewControllerDelegate function called when SwiftyCamViewController finishes recording video
    
    func SwiftyCamDidFinishRecordingVideo()
    
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController is done processing video
     
     - Parameter url: URL location of video in temporary directory
     
     */
    
    func SwiftyCamDidFinishProcessingVideoAt(_ url: URL)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController switches between front or rear camera
     
     - Parameter camera: Current camera selection
     
     */
    
    func SwiftyCamDidSwitchCameras(camera: SwiftyCamViewController.CameraSelection)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController view is tapped and begins focusing at that point
     
     - Parameter focusPoint: Location in view where camera focused
     
     */
    
    func SwiftyCamDidFocusAtPoint(focusPoint: CGPoint)
    
    /**
     SwiftyCamViewControllerDelegate function called when when SwiftyCamViewController view changes zoom level
     
     - Parameter zoomLevel: Current zoom level
     
     */

    func SwiftyCamDidChangeZoomLevel(zoomLevel: CGFloat)
    
    
    /// SwiftyCamViewControllerDelegate function called if app permissions are denied for either Camera or Microphone
    
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



