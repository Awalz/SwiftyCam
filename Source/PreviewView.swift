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
import AVFoundation

/// A function to specifty the Preview Layer's videoGravity. Indicates how the video is displayed within a player layer’s bounds rect.
public enum SwiftyCamVideoGravity {

    /**
     - Specifies that the video should be stretched to fill the layer’s bounds
     - Corrsponds to `AVLayerVideoGravityResize`
    */
    case resize
    /**
     - Specifies that the player should preserve the video’s aspect ratio and fit the video within the layer’s bounds.
     - Corresponds to `AVLayerVideoGravityResizeAspect`
     */
    case resizeAspect
    /**
     - Specifies that the player should preserve the video’s aspect ratio and fill the layer’s bounds.
     - Correponds to `AVLayerVideoGravityResizeAspectFill`
    */
    case resizeAspectFill
}

class PreviewView: UIView {
    
    private var gravity: SwiftyCamVideoGravity = .resizeAspect
    
    init(frame: CGRect, videoGravity: SwiftyCamVideoGravity) {
        gravity = videoGravity
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        switch gravity {
        case .resize:
            previewlayer.videoGravity = AVLayerVideoGravityResize
        case .resizeAspect:
            previewlayer.videoGravity = AVLayerVideoGravityResizeAspect
        case .resizeAspectFill:
            previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        }
		return previewlayer
	}
	
	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
		}
	}
	
	// MARK: UIView
	
	override class var layerClass : AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
}
