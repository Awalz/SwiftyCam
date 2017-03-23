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

	var flipCameraButton: UIButton!
	var flashButton: UIButton!
	var captureButton: SwiftyRecordButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		cameraDelegate = self
		maximumVideoDuration = 10.0
        shouldUseDeviceOrientation = true
		addButtons()
	}

	override var prefersStatusBarHidden: Bool {
		return true
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
		let newVC = PhotoViewController(image: photo)
		self.present(newVC, animated: true, completion: nil)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
		print("Did Begin Recording")
		captureButton.growButton()
		UIView.animate(withDuration: 0.25, animations: {
			self.flashButton.alpha = 0.0
			self.flipCameraButton.alpha = 0.0
		})
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
		print("Did finish Recording")
		captureButton.shrinkButton()
		UIView.animate(withDuration: 0.25, animations: {
			self.flashButton.alpha = 1.0
			self.flipCameraButton.alpha = 1.0
		})
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
		let newVC = VideoViewController(videoURL: url)
		self.present(newVC, animated: true, completion: nil)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
		let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
		focusView.center = point
		focusView.alpha = 0.0
		view.addSubview(focusView)

		UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
			focusView.alpha = 1.0
			focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
		}, completion: { (success) in
			UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
				focusView.alpha = 0.0
				focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
			}, completion: { (success) in
				focusView.removeFromSuperview()
			})
		})
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
		print(zoom)
	}

	func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
		print(camera)
	}

	@objc private func cameraSwitchAction(_ sender: Any) {
		switchCamera()
	}

	@objc private func toggleFlashAction(_ sender: Any) {
		flashEnabled = !flashEnabled

		if flashEnabled == true {
			flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState())
		} else {
			flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
		}
	}

	private func addButtons() {
		captureButton = SwiftyRecordButton(frame: CGRect(x: view.frame.midX - 37.5, y: view.frame.height - 100.0, width: 75.0, height: 75.0))
		self.view.addSubview(captureButton)
		captureButton.delegate = self

		flipCameraButton = UIButton(frame: CGRect(x: (((view.frame.width / 2 - 37.5) / 2) - 15.0), y: view.frame.height - 74.0, width: 30.0, height: 23.0))
		flipCameraButton.setImage(#imageLiteral(resourceName: "flipCamera"), for: UIControlState())
		flipCameraButton.addTarget(self, action: #selector(cameraSwitchAction(_:)), for: .touchUpInside)
		self.view.addSubview(flipCameraButton)

		let test = CGFloat((view.frame.width - (view.frame.width / 2 + 37.5)) + ((view.frame.width / 2) - 37.5) - 9.0)

		flashButton = UIButton(frame: CGRect(x: test, y: view.frame.height - 77.5, width: 18.0, height: 30.0))
		flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControlState())
		flashButton.addTarget(self, action: #selector(toggleFlashAction(_:)), for: .touchUpInside)
		self.view.addSubview(flashButton)
	}
}

