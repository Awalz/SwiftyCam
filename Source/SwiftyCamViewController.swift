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

open class SwiftyCamViewController: UIViewController {

   public enum CameraSelection {
        case rear
        case front
    }
    
    public enum VideoQuality {
        case high
        case medium
        case low
        case resolution352x288
        case resolution640x480
        case resolution1280x720
        case resolution1920x1080
        case resolution3840x2160
        case iframe960x540
        case iframe1280x720
    }
    
    fileprivate enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    public var cameraDelegate: SwiftyCamViewControllerDelegate?
    
    public var kMaximumVideoDuration : Double     = 0.0
    public var videoQuality : VideoQuality       = .high
    public var pinchToZoom                       = true
    public var tapToFocus                        = true
    public var promptToAppPrivacySettings        = true
    private(set) public var isCameraFlashOn      = false
    private(set) public var isVideRecording      = false
    private(set) public var isSessionRunning     = false
    private(set) public var currentCamera        = CameraSelection.rear
    fileprivate let session                      = AVCaptureSession()
    fileprivate let sessionQueue                 = DispatchQueue(label: "session queue", attributes: [])
    fileprivate var zoomScale                    = CGFloat(1.0)
    fileprivate var beginZoomScale               = CGFloat(1.0)
    fileprivate var setupResult                  = SessionSetupResult.success
    fileprivate var backgroundRecordingID        : UIBackgroundTaskIdentifier? = nil
    fileprivate var videoDeviceInput             : AVCaptureDeviceInput!
    fileprivate var movieFileOutput              : AVCaptureMovieFileOutput?
    fileprivate var photoFileOutput              : AVCaptureStillImageOutput?
    fileprivate var videoDevice                  : AVCaptureDevice?
    fileprivate var previewLayer                 : PreviewView!
    
    open override var shouldAutorotate: Bool {
        return false
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        previewLayer = PreviewView(frame: self.view.frame)
        addGestureRecognizers(toView: previewLayer)
        self.view.addSubview(previewLayer)
        previewLayer.session = session
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo){
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
                })
        default:
            setupResult = .notAuthorized
        }
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            case .notAuthorized:
                self.promptToAppSettings()
            case .configurationFailed:
                DispatchQueue.main.async(execute: { [unowned self] in
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isSessionRunning == true {
            self.session.stopRunning()
            self.isSessionRunning = false
        }
        disableFlash()
    }
    
    public func takePhoto() {
        if let videoConnection = photoFileOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            photoFileOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let image = self.processPhoto(imageData!)
                    self.cameraDelegate?.SwiftyCamDidTakePhoto(image)
                }
            })
        }
    }
    
    public func startVideoRecording() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        let videoPreviewLayerOrientation = previewLayer!.videoPreviewLayer.connection.videoOrientation
        
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
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation
                
                // Start recording to a temporary file.
                let outputFileName = UUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                self.isVideRecording = true
                self.cameraDelegate?.SwiftyCamDidBeginRecordingVideo()
            }
            else {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    public func endVideoRecording() {
        if self.movieFileOutput?.isRecording == true {
            self.isVideRecording = false
            movieFileOutput!.stopRecording()
            self.cameraDelegate?.SwiftyCamDidFinishRecordingVideo()
        }
    }
    
    public func switchCamera() {
        guard isVideRecording != true else {
            print("[SwiftyCam]: Switching between cameras while recording video is not supported")
            return
        }
        switch currentCamera {
        case .front:
            currentCamera = .rear
        case .rear:
            currentCamera = .front
        }
        
        self.session.stopRunning()

        sessionQueue.async { [unowned self] in
            
            for input in self.session.inputs {
                self.session.removeInput(input as! AVCaptureInput)
            }
            for output in self.session.outputs {
                self.session.removeOutput(output as! AVCaptureOutput)
            }
            
            self.configureSession()
            self.cameraDelegate?.SwiftyCamDidSwitchCameras(camera: self.currentCamera)
            self.session.startRunning()
        }
        disableFlash()
    }
    
    public func toggleFlash() {
        guard self.currentCamera == .rear else {
            return
        }
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                    self.isCameraFlashOn = false
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                        self.isCameraFlashOn = true
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
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard tapToFocus == true, currentCamera ==  .rear else {
            return
        }
        
        let screenSize = previewLayer!.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: previewLayer!).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: previewLayer!).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = videoDevice {
                do {
                    try device.lockForConfiguration()
                    
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                    self.cameraDelegate?.SwiftyCamDidFocusAtPoint(focusPoint: touchPoint.location(in: previewLayer))
                }
                catch {
                // just ignore
                }
            }
        }
    }
    
    /**************************************** Private Functions ****************************************/

    fileprivate func configureSession() {
        guard setupResult == .success else {
            return
        }
        session.beginConfiguration()
        configureVideoPreset()
        addVideoInput()
        addAudioInput()
        configureVideoOutput()
        configurePhotoOutput()
        
        session.commitConfiguration()
    }
    
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
    
    fileprivate func configurePhotoOutput() {
        let photoFileOutput = AVCaptureStillImageOutput()
        
        if self.session.canAddOutput(photoFileOutput) {
            photoFileOutput.outputSettings  = [AVVideoCodecKey: AVVideoCodecJPEG]
            self.session.addOutput(photoFileOutput)
            self.photoFileOutput = photoFileOutput
        }
    }
    
    fileprivate func processPhoto(_ imageData: Data) -> UIImage {
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        var image: UIImage!
        
        switch self.currentCamera {
            case .front:
                image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored)
            case .rear:
                image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
        }
        return image
    }
    
    @objc fileprivate func zoomGesture(pinch: UIPinchGestureRecognizer) {
        guard pinchToZoom == true else {
            return
        }
            do {
                let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
                try captureDevice?.lockForConfiguration()
            
                zoomScale = max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor))
            
                captureDevice?.videoZoomFactor = zoomScale
                
                self.cameraDelegate?.SwiftyCamDidChangeZoomLevel(zoomLevel: zoomScale)
            
                captureDevice?.unlockForConfiguration()
            
            } catch {
                print("[SwiftyCam]: Error locking configuration")
        }
    }
    
    fileprivate func addGestureRecognizers(toView: UIView) {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(pinch:)))
        pinchGesture.delegate = self
        toView.addGestureRecognizer(pinchGesture)
    }
    
    fileprivate func promptToAppSettings() {
        guard promptToAppPrivacySettings == true else {
            self.cameraDelegate?.SwiftyCamDidFailCameraPermissionSettings()
            return
        }
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
                    return AVCaptureSessionPresetPhoto
                }
        }
    }
    
    fileprivate class func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let devices = AVCaptureDevice.devices(withMediaType: mediaType) as? [AVCaptureDevice] {
            return devices.filter({ $0.position == position }).first
        }
        return nil
    }
    
    fileprivate func enableFlash() {
        if self.isCameraFlashOn == false {
            toggleFlash()
        }
    }
    
    fileprivate func disableFlash() {
        if self.isCameraFlashOn == true {
            toggleFlash()
        }
    }
}

extension SwiftyCamViewController : SwiftyCamButtonDelegate {
    
    public func setMaxiumVideoDuration() -> Double {
        return kMaximumVideoDuration
    }
    
    public func buttonWasTapped() {
        takePhoto()
    }
    
    public func buttonDidBeginLongPress() {
        startVideoRecording()
    }
    
    public func buttonDidEndLongPress() {
        endVideoRecording()
    }
    
    public func longPressDidReachMaximumDuration() {
        endVideoRecording()
    }
}

extension SwiftyCamViewController : AVCaptureFileOutputRecordingDelegate {
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
            self.cameraDelegate?.SwiftyCamDidFinishProcessingVideoAt(outputFileURL)
        }
    }
}

extension SwiftyCamViewController : UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            beginZoomScale = zoomScale;
        }
        return true
    }
}




