/*Copyright (c) 2016, Andrew Walz.

Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


import UIKit
import AVFoundation

// MARK: View Controller Declaration

/// A UIViewController Camera View Subclass

open class SwiftyCamViewController: UIViewController {

	// MARK: Enumeration Declaration

	/// Enumeration for Camera Selection

	public enum CameraSelection {

		/// Camera on the back of the device
		case rear

		/// Camera on the front of the device
		case front
	}

	/// Enumeration for video quality of the capture session. Corresponds to a AVCaptureSessionPreset


	public enum VideoQuality {

		/// AVCaptureSessionPresetHigh
		case high

		/// AVCaptureSessionPresetMedium
		case medium

		/// AVCaptureSessionPresetLow
		case low

		/// AVCaptureSessionPreset352x288
		case resolution352x288

		/// AVCaptureSessionPreset640x480
		case resolution640x480

		/// AVCaptureSessionPreset1280x720
		case resolution1280x720

		/// AVCaptureSessionPreset1920x1080
		case resolution1920x1080

		/// AVCaptureSessionPreset3840x2160
		case resolution3840x2160

		/// AVCaptureSessionPresetiFrame960x540
		case iframe960x540

		/// AVCaptureSessionPresetiFrame1280x720
		case iframe1280x720
	}

	/**

	Result from the AVCaptureSession Setup

	- success: success
	- notAuthorized: User denied access to Camera of Microphone
	- configurationFailed: Unknown error
	*/

	fileprivate enum SessionSetupResult {
		case success
		case notAuthorized
		case configurationFailed
	}

	// MARK: Public Variable Declarations

	/// Public Camera Delegate for the Custom View Controller Subclass

	public var cameraDelegate: SwiftyCamViewControllerDelegate?

	/// Maxiumum video duration if SwiftyCamButton is used

	public var maximumVideoDuration : Double     = 0.0

	/// Video capture quality

	public var videoQuality : VideoQuality       = .high

	/// Sets whether flash is enabled for photo and video capture

	public var flashEnabled                      = false

	/// Sets whether Pinch to Zoom is enabled for the capture session

	public var pinchToZoom                       = true

	/// Sets the maximum zoom scale allowed during Pinch gesture

	public var maxZoomScale				         = CGFloat(4.0)
  
	/// Sets whether Tap to Focus and Tap to Adjust Exposure is enabled for the capture session

	public var tapToFocus                        = true

	/// Sets whether the capture session should adjust to low light conditions automatically
	///
	/// Only supported on iPhone 5 and 5C

	public var lowLightBoost                     = true

	/// Set whether SwiftyCam should allow background audio from other applications

	public var allowBackgroundAudio              = true

	/// Sets whether a double tap to switch cameras is supported

	public var doubleTapCameraSwitch            = true

	/// Set default launch camera

	public var defaultCamera                   = CameraSelection.rear

	/// Sets wether the taken photo or video should be oriented according to the device orientation

	public var shouldUseDeviceOrientation      = false


	// MARK: Public Get-only Variable Declarations

	/// Returns true if video is currently being recorded

	private(set) public var isVideoRecording      = false

	/// Returns true if the capture session is currently running

	private(set) public var isSessionRunning     = false

	/// Returns the CameraSelection corresponding to the currently utilized camera

	private(set) public var currentCamera        = CameraSelection.rear

	// MARK: Private Constant Declarations

	/// Current Capture Session

	fileprivate let session                      = AVCaptureSession()

	/// Serial queue used for setting up session

	fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])

	// MARK: Private Variable Declarations

	/// Variable for storing current zoom scale

	fileprivate var zoomScale                    = CGFloat(1.0)

	/// Variable for storing initial zoom scale before Pinch to Zoom begins

	fileprivate var beginZoomScale               = CGFloat(1.0)

	/// Returns true if the torch (flash) is currently enabled

	fileprivate var isCameraTorchOn              = false

	/// Variable to store result of capture session setup

	fileprivate var setupResult                  = SessionSetupResult.success

	/// BackgroundID variable for video recording

	fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil

	/// Video Input variable

	fileprivate var videoDeviceInput             : AVCaptureDeviceInput!

	/// Movie File Output variable

	fileprivate var movieFileOutput              : AVCaptureMovieFileOutput?

	/// Photo File Output variable

	fileprivate var photoFileOutput              : AVCaptureStillImageOutput?

	/// Video Device variable

	fileprivate var videoDevice                  : AVCaptureDevice?

	/// PreviewView for the capture session

	fileprivate var previewLayer                 : PreviewView!

	/// UIView for front facing flash

	fileprivate var flashView                    : UIView?

	/// Last changed orientation

	fileprivate var deviceOrientation            : UIDeviceOrientation?

	/// Disable view autorotation for forced portrait recorindg


	override open var shouldAutorotate: Bool {
		return false
	}

	// MARK: ViewDidLoad

	/// ViewDidLoad Implementation

	override open func viewDidLoad() {
		super.viewDidLoad()
		previewLayer = PreviewView(frame: self.view.frame)

		// Add Gesture Recognizers

		addGestureRecognizersTo(view: previewLayer)

		self.view.addSubview(previewLayer)
		previewLayer.session = session

		// Test authorization status for Camera and Micophone

		switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo){
		case .authorized:

			// already authorized
			break
		case .notDetermined:

			// not yet determined
			sessionQueue.suspend()
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
				if !granted {
					self.setupResult = .notAuthorized
				}
				self.sessionQueue.resume()
			})
		default:

			// already been asked. Denied access
			setupResult = .notAuthorized
		}
		sessionQueue.async { [unowned self] in
			self.configureSession()
		}
	}

    // MARK: ViewDidLayoutSubviews
    
    /// ViewDidLayoutSubviews() Implementation
    
    
    override open func viewDidLayoutSubviews() {
        previewLayer.frame = view.bounds
        
        super.viewDidLayoutSubviews()
    }
    
	// MARK: ViewDidAppear

	/// ViewDidAppear(_ animated:) Implementation


	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// Subscribe to device rotation notifications

		if shouldUseDeviceOrientation {
			subscribeToDeviceOrientationChangeNotifications()
		}

		// Set background audio preference

		setBackgroundAudioPreference()

		sessionQueue.async {
			switch self.setupResult {
			case .success:
				// Begin Session
				self.session.startRunning()
				self.isSessionRunning = self.session.isRunning
                
                // Preview layer video orientation can be set only after the connection is created
                DispatchQueue.main.async {
                    self.previewLayer.videoPreviewLayer.connection?.videoOrientation = self.getPreviewLayerOrientation()
                }
                
			case .notAuthorized:
				// Prompt to App Settings
				self.promptToAppSettings()
			case .configurationFailed:
				// Unknown Error
				DispatchQueue.main.async(execute: { [unowned self] in
					let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
					let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
					alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
					self.present(alertController, animated: true, completion: nil)
				})
			}
		}
	}

	// MARK: ViewDidDisappear

	/// ViewDidDisappear(_ animated:) Implementation


	override open func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		// If session is running, stop the session
		if self.isSessionRunning == true {
			self.session.stopRunning()
			self.isSessionRunning = false
		}

		//Disble flash if it is currently enabled
		disableFlash()

		// Unsubscribe from device rotation notifications
		if shouldUseDeviceOrientation {
			unsubscribeFromDeviceOrientationChangeNotifications()
		}
	}

	// MARK: Public Functions

	/**

	Capture photo from current session

	UIImage will be returned with the SwiftyCamViewControllerDelegate function SwiftyCamDidTakePhoto(photo:)

	*/

	public func takePhoto() {

		guard let device = videoDevice else {
			return
		}

		if device.hasFlash == true && flashEnabled == true /* TODO: Add Support for Retina Flash and add front flash */ {
			changeFlashSettings(device: device, mode: .on)
			capturePhotoAsyncronously(completionHandler: { (_) in })

		} else if device.hasFlash == false && flashEnabled == true && currentCamera == .front {
			flashView = UIView(frame: view.frame)
			flashView?.alpha = 0.0
			flashView?.backgroundColor = UIColor.white
			previewLayer.addSubview(flashView!)

			UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
				self.flashView?.alpha = 1.0

			}, completion: { (_) in
				self.capturePhotoAsyncronously(completionHandler: { (success) in
					UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
						self.flashView?.alpha = 0.0
					}, completion: { (_) in
						self.flashView?.removeFromSuperview()
					})
				})
			})
		} else {
			if device.isFlashActive == true {
				changeFlashSettings(device: device, mode: .off)
			}
			capturePhotoAsyncronously(completionHandler: { (_) in })
		}
	}

	/**

	Begin recording video of current session

	SwiftyCamViewControllerDelegate function SwiftyCamDidBeginRecordingVideo() will be called

	*/

	public func startVideoRecording() {
		guard let movieFileOutput = self.movieFileOutput else {
			return
		}

		if currentCamera == .rear && flashEnabled == true {
			enableFlash()
		}

		if currentCamera == .front && flashEnabled == true {
			flashView = UIView(frame: view.frame)
			flashView?.backgroundColor = UIColor.white
			flashView?.alpha = 0.85
			previewLayer.addSubview(flashView!)
		}

		sessionQueue.async { [unowned self] in
			if !movieFileOutput.isRecording {
				if UIDevice.current.isMultitaskingSupported {
					self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
				}

				// Update the orientation on the movie file output video connection before starting recording.
				let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)


				//flip video output if front facing camera is selected
				if self.currentCamera == .front {
					movieFileOutputConnection?.isVideoMirrored = true
				}

				movieFileOutputConnection?.videoOrientation = self.getVideoOrientation()

				// Start recording to a temporary file.
				let outputFileName = UUID().uuidString
				let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
				movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
				self.isVideoRecording = true
				DispatchQueue.main.async {
					self.cameraDelegate?.swiftyCam(self, didBeginRecordingVideo: self.currentCamera)
				}
			}
			else {
				movieFileOutput.stopRecording()
			}
		}
	}

	/**

	Stop video recording video of current session

	SwiftyCamViewControllerDelegate function SwiftyCamDidFinishRecordingVideo() will be called

	When video has finished processing, the URL to the video location will be returned by SwiftyCamDidFinishProcessingVideoAt(url:)

	*/

	public func stopVideoRecording() {
		if self.movieFileOutput?.isRecording == true {
			self.isVideoRecording = false
			movieFileOutput!.stopRecording()
			disableFlash()

			if currentCamera == .front && flashEnabled == true && flashView != nil {
				UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
					self.flashView?.alpha = 0.0
				}, completion: { (_) in
					self.flashView?.removeFromSuperview()
				})
			}
			DispatchQueue.main.async {
				self.cameraDelegate?.swiftyCam(self, didFinishRecordingVideo: self.currentCamera)
			}
		}
	}

	/**

	Switch between front and rear camera

	SwiftyCamViewControllerDelegate function SwiftyCamDidSwitchCameras(camera:  will be return the current camera selection

	*/


	public func switchCamera() {
		guard isVideoRecording != true else {
			//TODO: Look into switching camera during video recording
			print("[SwiftyCam]: Switching between cameras while recording video is not supported")
			return
		}
        
        guard session.isRunning == true else {
            return
        }
        
		switch currentCamera {
		case .front:
			currentCamera = .rear
		case .rear:
			currentCamera = .front
		}

		session.stopRunning()

		sessionQueue.async { [unowned self] in

			// remove and re-add inputs and outputs

			for input in self.session.inputs {
				self.session.removeInput(input as! AVCaptureInput)
			}

			self.addInputs()
			DispatchQueue.main.async {
				self.cameraDelegate?.swiftyCam(self, didSwitchCameras: self.currentCamera)
			}

			self.session.startRunning()
		}

		// If flash is enabled, disable it as the torch is needed for front facing camera
		disableFlash()
	}

	// MARK: Private Functions

	/// Configure session, add inputs and outputs

	fileprivate func configureSession() {
		guard setupResult == .success else {
			return
		}

		// Set default camera

		currentCamera = defaultCamera

		// begin configuring session

		session.beginConfiguration()
		configureVideoPreset()
		addVideoInput()
		addAudioInput()
		configureVideoOutput()
		configurePhotoOutput()

		session.commitConfiguration()
	}

	/// Add inputs after changing camera()

	fileprivate func addInputs() {
		session.beginConfiguration()
		configureVideoPreset()
		addVideoInput()
		addAudioInput()
		session.commitConfiguration()
	}


	// Front facing camera will always be set to VideoQuality.high
	// If set video quality is not supported, videoQuality variable will be set to VideoQuality.high
	/// Configure image quality preset

	fileprivate func configureVideoPreset() {

		if currentCamera == .front {
			session.sessionPreset = videoInputPresetFromVideoQuality(quality: .high)
		} else {
			if session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: videoQuality)) {
				session.sessionPreset = videoInputPresetFromVideoQuality(quality: videoQuality)
			} else {
				session.sessionPreset = videoInputPresetFromVideoQuality(quality: .high)
			}
		}
	}

	/// Add Video Inputs

	fileprivate func addVideoInput() {
		switch currentCamera {
		case .front:
			videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .front)
		case .rear:
			videoDevice = SwiftyCamViewController.deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .back)
		}

		if let device = videoDevice {
			do {
				try device.lockForConfiguration()
				if device.isFocusModeSupported(.continuousAutoFocus) {
					device.focusMode = .continuousAutoFocus
					if device.isSmoothAutoFocusSupported {
						device.isSmoothAutoFocusEnabled = true
					}
				}

				if device.isExposureModeSupported(.continuousAutoExposure) {
					device.exposureMode = .continuousAutoExposure
				}

				if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
					device.whiteBalanceMode = .continuousAutoWhiteBalance
				}

				if device.isLowLightBoostSupported && lowLightBoost == true {
					device.automaticallyEnablesLowLightBoostWhenAvailable = true
				}

				device.unlockForConfiguration()
			} catch {
				print("[SwiftyCam]: Error locking configuration")
			}
		}

		do {
			let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

			if session.canAddInput(videoDeviceInput) {
				session.addInput(videoDeviceInput)
				self.videoDeviceInput = videoDeviceInput
			} else {
				print("[SwiftyCam]: Could not add video device input to the session")
				print(session.canSetSessionPreset(videoInputPresetFromVideoQuality(quality: videoQuality)))
				setupResult = .configurationFailed
				session.commitConfiguration()
				return
			}
		} catch {
			print("[SwiftyCam]: Could not create video device input: \(error)")
			setupResult = .configurationFailed
			return
		}
	}

	/// Add Audio Inputs

	fileprivate func addAudioInput() {
		do {
			let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
			let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)

			if session.canAddInput(audioDeviceInput) {
				session.addInput(audioDeviceInput)
			}
			else {
				print("[SwiftyCam]: Could not add audio device input to the session")
			}
		}
		catch {
			print("[SwiftyCam]: Could not create audio device input: \(error)")
		}
	}

	/// Configure Movie Output

	fileprivate func configureVideoOutput() {
		let movieFileOutput = AVCaptureMovieFileOutput()

		if self.session.canAddOutput(movieFileOutput) {
			self.session.addOutput(movieFileOutput)
			if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
				if connection.isVideoStabilizationSupported {
					connection.preferredVideoStabilizationMode = .auto
				}
			}
			self.movieFileOutput = movieFileOutput
		}
	}

	/// Configure Photo Output

	fileprivate func configurePhotoOutput() {
		let photoFileOutput = AVCaptureStillImageOutput()

		if self.session.canAddOutput(photoFileOutput) {
			photoFileOutput.outputSettings  = [AVVideoCodecKey: AVVideoCodecJPEG]
			self.session.addOutput(photoFileOutput)
			self.photoFileOutput = photoFileOutput
		}
	}

	/// Orientation management

	fileprivate func subscribeToDeviceOrientationChangeNotifications() {
		self.deviceOrientation = UIDevice.current.orientation
		NotificationCenter.default.addObserver(self, selector: #selector(deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
	}

	fileprivate func unsubscribeFromDeviceOrientationChangeNotifications() {
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
		self.deviceOrientation = nil
	}

	@objc fileprivate func deviceDidRotate() {
		if !UIDevice.current.orientation.isFlat {
			self.deviceOrientation = UIDevice.current.orientation
		}
	}
    
    fileprivate func getPreviewLayerOrientation() -> AVCaptureVideoOrientation {
        // Depends on layout orientation, not device orientation
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .unknown:
            return AVCaptureVideoOrientation.portrait
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        }
    }

	fileprivate func getVideoOrientation() -> AVCaptureVideoOrientation {
		guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return previewLayer!.videoPreviewLayer.connection.videoOrientation }

		switch deviceOrientation {
		case .landscapeLeft:
			return .landscapeRight
		case .landscapeRight:
			return .landscapeLeft
		case .portraitUpsideDown:
			return .portraitUpsideDown
		default:
			return .portrait
		}
	}

	fileprivate func getImageOrientation(forCamera: CameraSelection) -> UIImageOrientation {
		guard shouldUseDeviceOrientation, let deviceOrientation = self.deviceOrientation else { return forCamera == .rear ? .right : .leftMirrored }

		switch deviceOrientation {
		case .landscapeLeft:
			return forCamera == .rear ? .up : .downMirrored
		case .landscapeRight:
			return forCamera == .rear ? .down : .upMirrored
		case .portraitUpsideDown:
			return forCamera == .rear ? .left : .rightMirrored
		default:
			return forCamera == .rear ? .right : .leftMirrored
		}
	}

	/**
	Returns a UIImage from Image Data.

	- Parameter imageData: Image Data returned from capturing photo from the capture session.

	- Returns: UIImage from the image data, adjusted for proper orientation.
	*/

	fileprivate func processPhoto(_ imageData: Data) -> UIImage {
		let dataProvider = CGDataProvider(data: imageData as CFData)
		let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)

		// Set proper orientation for photo
		// If camera is currently set to front camera, flip image

		let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: self.getImageOrientation(forCamera: self.currentCamera))

		return image
	}

	fileprivate func capturePhotoAsyncronously(completionHandler: @escaping(Bool) -> ()) {
		if let videoConnection = photoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {

			photoFileOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
				if (sampleBuffer != nil) {
					let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
					let image = self.processPhoto(imageData!)

					// Call delegate and return new image
					DispatchQueue.main.async {
						self.cameraDelegate?.swiftyCam(self, didTake: image)
					}
					completionHandler(true)
				} else {
					completionHandler(false)
				}
			})
		} else {
			completionHandler(false)
		}
	}

	/// Handle Denied App Privacy Settings

	fileprivate func promptToAppSettings() {
		// prompt User with UIAlertView

		DispatchQueue.main.async(execute: { [unowned self] in
			let message = NSLocalizedString("AVCam doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
			let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: { action in
				if #available(iOS 10.0, *) {
					UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
				} else {
					if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
						UIApplication.shared.openURL(appSettings)
					}
				}
			}))
			self.present(alertController, animated: true, completion: nil)
		})
	}

	/**
	Returns an AVCapturePreset from VideoQuality Enumeration

	- Parameter quality: ViewQuality enum

	- Returns: String representing a AVCapturePreset
	*/

	fileprivate func videoInputPresetFromVideoQuality(quality: VideoQuality) -> String {
		switch quality {
		case .high: return AVCaptureSessionPresetHigh
		case .medium: return AVCaptureSessionPresetMedium
		case .low: return AVCaptureSessionPresetLow
		case .resolution352x288: return AVCaptureSessionPreset352x288
		case .resolution640x480: return AVCaptureSessionPreset640x480
		case .resolution1280x720: return AVCaptureSessionPreset1280x720
		case .resolution1920x1080: return AVCaptureSessionPreset1920x1080
		case .iframe960x540: return AVCaptureSessionPresetiFrame960x540
		case .iframe1280x720: return AVCaptureSessionPresetiFrame1280x720
		case .resolution3840x2160:
			if #available(iOS 9.0, *) {
				return AVCaptureSessionPreset3840x2160
			}
			else {
				print("[SwiftyCam]: Resolution 3840x2160 not supported")
				return AVCaptureSessionPresetHigh
			}
		}
	}

	/// Get Devices

	fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
		if let devices = AVCaptureDevice.devices(withMediaType: mediaType) as? [AVCaptureDevice] {
			return devices.filter({ $0.position == position }).first
		}
		return nil
	}

	/// Enable or disable flash for photo

	fileprivate func changeFlashSettings(device: AVCaptureDevice, mode: AVCaptureFlashMode) {
		do {
			try device.lockForConfiguration()
			device.flashMode = mode
			device.unlockForConfiguration()
		} catch {
			print("[SwiftyCam]: \(error)")
		}
	}

	/// Enable flash

	fileprivate func enableFlash() {
		if self.isCameraTorchOn == false {
			toggleFlash()
		}
	}

	/// Disable flash

	fileprivate func disableFlash() {
		if self.isCameraTorchOn == true {
			toggleFlash()
		}
	}

	/// Toggles between enabling and disabling flash

	fileprivate func toggleFlash() {
		guard self.currentCamera == .rear else {
			// Flash is not supported for front facing camera
			return
		}

		let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
		// Check if device has a flash
		if (device?.hasTorch)! {
			do {
				try device?.lockForConfiguration()
				if (device?.torchMode == AVCaptureTorchMode.on) {
					device?.torchMode = AVCaptureTorchMode.off
					self.isCameraTorchOn = false
				} else {
					do {
						try device?.setTorchModeOnWithLevel(1.0)
						self.isCameraTorchOn = true
					} catch {
						print("[SwiftyCam]: \(error)")
					}
				}
				device?.unlockForConfiguration()
			} catch {
				print("[SwiftyCam]: \(error)")
			}
		}
	}

	/// Sets whether SwiftyCam should enable background audio from other applications or sources

	fileprivate func setBackgroundAudioPreference() {
		guard allowBackgroundAudio == true else {
			return
		}

		do{
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
			                                                with: [.duckOthers, .defaultToSpeaker])

			session.automaticallyConfiguresApplicationAudioSession = false
		}
		catch {
			print("[SwiftyCam]: Failed to set background audio preference")

		}
	}
}

extension SwiftyCamViewController : SwiftyCamButtonDelegate {

	/// Sets the maximum duration of the SwiftyCamButton

	public func setMaxiumVideoDuration() -> Double {
		return maximumVideoDuration
	}

	/// Set UITapGesture to take photo

	public func buttonWasTapped() {
		takePhoto()
	}

	/// Set UILongPressGesture start to begin video

	public func buttonDidBeginLongPress() {
		startVideoRecording()
	}

	/// Set UILongPressGesture begin to begin end video


	public func buttonDidEndLongPress() {
		stopVideoRecording()
	}

	/// Called if maximum duration is reached

	public func longPressDidReachMaximumDuration() {
		stopVideoRecording()
	}
}

// MARK: AVCaptureFileOutputRecordingDelegate

extension SwiftyCamViewController : AVCaptureFileOutputRecordingDelegate {

	/// Process newly captured video and write it to temporary directory

	public func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
		if let currentBackgroundRecordingID = backgroundRecordingID {
			backgroundRecordingID = UIBackgroundTaskInvalid

			if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
				UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
			}
		}
		if error != nil {
			print("[SwiftyCam]: Movie file finishing error: \(error)")
		} else {
			//Call delegate function with the URL of the outputfile
			DispatchQueue.main.async {
				self.cameraDelegate?.swiftyCam(self, didFinishProcessVideoAt: outputFileURL)
			}
		}
	}
}

// Mark: UIGestureRecognizer Declarations

extension SwiftyCamViewController {

	/// Handle pinch gesture

	@objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
		guard pinchToZoom == true && self.currentCamera == .rear else {
			//ignore pinch if pinchToZoom is set to false
			return
		}
		do {
			let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
			try captureDevice?.lockForConfiguration()

			zoomScale = min(maxZoomScale, max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor)))

			captureDevice?.videoZoomFactor = zoomScale

			// Call Delegate function with current zoom scale
			DispatchQueue.main.async {
				self.cameraDelegate?.swiftyCam(self, didChangeZoomLevel: self.zoomScale)
			}

			captureDevice?.unlockForConfiguration()

		} catch {
			print("[SwiftyCam]: Error locking configuration")
		}
	}

	/// Handle single tap gesture

	@objc fileprivate func singleTapGesture(tap: UITapGestureRecognizer) {
		guard tapToFocus == true else {
			// Ignore taps
			return
		}

		let screenSize = previewLayer!.bounds.size
		let tapPoint = tap.location(in: previewLayer!)
		let x = tapPoint.y / screenSize.height
		let y = 1.0 - tapPoint.x / screenSize.width
		let focusPoint = CGPoint(x: x, y: y)

		if let device = videoDevice {
			do {
				try device.lockForConfiguration()

				if device.isFocusPointOfInterestSupported == true {
					device.focusPointOfInterest = focusPoint
					device.focusMode = .autoFocus
				}
				device.exposurePointOfInterest = focusPoint
				device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
				device.unlockForConfiguration()
				//Call delegate function and pass in the location of the touch

				DispatchQueue.main.async {
					self.cameraDelegate?.swiftyCam(self, didFocusAtPoint: tapPoint)
				}
			}
			catch {
				// just ignore
			}
		}
	}

	/// Handle double tap gesture

	@objc fileprivate func doubleTapGesture(tap: UITapGestureRecognizer) {
		guard doubleTapCameraSwitch == true else {
			return
		}
		switchCamera()
	}

	/**
	Add pinch gesture recognizer and double tap gesture recognizer to currentView

	- Parameter view: View to add gesture recognzier

	*/

	fileprivate func addGestureRecognizersTo(view: UIView) {
		let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
		pinchGesture.delegate = self
		view.addGestureRecognizer(pinchGesture)

		let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapGesture(tap:)))
		singleTapGesture.numberOfTapsRequired = 1
		singleTapGesture.delegate = self
		view.addGestureRecognizer(singleTapGesture)

		let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture(tap:)))
		doubleTapGesture.numberOfTapsRequired = 2
		doubleTapGesture.delegate = self
		view.addGestureRecognizer(doubleTapGesture)
	}
}


// MARK: UIGestureRecognizerDelegate

extension SwiftyCamViewController : UIGestureRecognizerDelegate {

	/// Set beginZoomScale when pinch begins

	public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
			beginZoomScale = zoomScale;
		}
		return true
	}
}




