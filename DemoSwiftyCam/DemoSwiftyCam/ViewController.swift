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

class ViewController: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        cameraDelegate = self
        kMaximumVideoDuration = 10.0
        tapToFocus = true
        pinchToZoom = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let button : SwiftyCamButton = SwiftyCamButton(frame: CGRect(x: (self.view.frame.width / 2) - 35, y: self.view.frame.height - 85, width: 70, height: 70))
        button.delegate = self
        button.setImage(UIImage(named: "Camera"), for: UIControlState())
        self.view.addSubview(button)
        self.view.bringSubview(toFront: flipCameraButton)
        self.view.bringSubview(toFront: toggleFlashButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SwiftyCamDidTakePhoto(_ photo: UIImage) {
        print(photo)
    }
    
    func SwiftyCamDidBeginRecordingVideo() {
        print("Did Begin Recording")
    }
    
    func SwiftyCamDidFinishRecordingVideo() {
        print("Did finish Recording")
    }
    
    func SwiftyCamDidFinishProcessingVideoAt(_ url: String) {
        print(url)
    }
    
    func SwiftyCamDidFocusAtPoint(focusPoint: CGPoint) {
        print(focusPoint)
    }
    
    func SwiftyCamDidChangeZoomLevel(zoomLevel: CGFloat) {
        print(zoomLevel)
    }
    
    func SwiftyCamDidSwitchCameras(camera: SwiftyCamViewController.CameraSelection) {
        print(camera)
    }
    
    @IBAction func cameraSwitchAction(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashAction(_ sender: Any) {
        toggleFlash()
    }
}

