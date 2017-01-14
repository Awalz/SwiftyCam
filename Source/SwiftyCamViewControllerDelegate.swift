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
     SwiftyCamViewControllerDelegate function called when the takePhoto() function is called.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter photo: UIImage captured from the current session
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController begins recording video.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter camera: Current camera orientation
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController finishes recording video.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter camera: Current camera orientation
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController is done processing video.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter url: URL location of video in temporary directory
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController switches between front or rear camera.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter camera: Current camera selection
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection)
    
    /**
     SwiftyCamViewControllerDelegate function called when SwiftyCamViewController view is tapped and begins focusing at that point.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter point: Location in view where camera focused
     
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint)
    
    /**
     SwiftyCamViewControllerDelegate function called when when SwiftyCamViewController view changes zoom level.
     
     - Parameter swiftyCam: Current SwiftyCamViewController session
     - Parameter zoom: Current zoom level
     */
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat)
}

public extension SwiftyCamViewControllerDelegate {
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        // Optional
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Optional
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        // Optional
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        // Optional
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        // Optional
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        // Optional
    }

    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        // Optional
    }
}



