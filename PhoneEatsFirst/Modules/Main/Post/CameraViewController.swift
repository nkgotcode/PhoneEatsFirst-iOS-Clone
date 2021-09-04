//
//  CameraViewController.swift
//  EventTicketing
//
//  Created by Quan Tran on 6/14/20.
//  Copyright © 2020 Quan Tran. All rights reserved.
//
//  Based on Apple's sample code called AVCam: Building a Camera App

import AVFoundation
import CoreLocation
import CropViewController
import os
import Photos
import TOCropViewController
import UIKit
import JGProgressHUD

class CameraPreviewView: UIView {
  var videoPreviewLayer: AVCaptureVideoPreviewLayer {
    guard let layer = layer as? AVCaptureVideoPreviewLayer else {
      fatalError("[Camera] videoPreviewLayer is not AVCaptureVideoPreviewLayer")
    }
    return layer
  }

  var session: AVCaptureSession? {
    get { videoPreviewLayer.session }
    set { videoPreviewLayer.session = newValue }
  }

  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }
}

class CameraViewController: UIViewController {
//  private var spinner: UIActivityIndicatorView!
  private var loadingHud: JGProgressHUD!
  private var croppingStyle = CropViewCroppingStyle.default

  var windowOrientation: UIInterfaceOrientation {
    view.window?.windowScene?.interfaceOrientation ?? .unknown
  }

  let locationManager = CLLocationManager()

  let logger = Logger(subsystem: "com.itsnk.PhoneEatsFirst", category: "Camera")

  // MARK: - View Controller Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    // Set up the video preview view
    previewView = CameraPreviewView()
    previewView.session = session
    previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
    previewView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(previewView)

    // Set up the camera interface
    let switchCameraSymbol = UIImage(
      systemName: "arrow.triangle.2.circlepath.camera",
      withConfiguration: UIImage.SymbolConfiguration(scale: .large)
    )
    switchCameraButton = UIButton()
    switchCameraButton.setImage(switchCameraSymbol, for: .normal)
    switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
    switchCameraButton.addTarget(self, action: #selector(changeCamera), for: .touchUpInside)
    view.addSubview(switchCameraButton)

    let flashOffSymbol = UIImage(
      systemName: "bolt.slash.fill",
      withConfiguration: UIImage.SymbolConfiguration(scale: .large)
    ) // flash is off by default
    flashButton = UIButton()
    flashButton.setImage(flashOffSymbol, for: .normal)
    flashButton.translatesAutoresizingMaskIntoConstraints = false
    flashButton.addTarget(self, action: #selector(changeFlashMode), for: .touchUpInside)
    view.addSubview(flashButton)

    let photoLibrarySymbol = UIImage(
      systemName: "photo.on.rectangle.angled",
      withConfiguration: UIImage.SymbolConfiguration(scale: .large)
    )
    photoLibraryButton = UIButton()
    photoLibraryButton.setImage(photoLibrarySymbol, for: .normal)
    photoLibraryButton.translatesAutoresizingMaskIntoConstraints = false
    photoLibraryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
    view.addSubview(photoLibraryButton)

    captureButton = UIButton()
    captureButton.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    captureButton.layer.cornerRadius = 0.5 * captureButton.bounds.size.width
    captureButton.clipsToBounds = true
    captureButton.layer.borderColor = UIColor.systemPink.cgColor
    captureButton.layer.borderWidth = 8
    captureButton.translatesAutoresizingMaskIntoConstraints = false
    captureButton.alpha = captureButton.isSelected ? 0.5 : 1.0
    captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
    captureButton.addTarget(self, action: #selector(captureButtonTouchDown), for: .touchDown)
    captureButton.addTarget(
      self,
      action: #selector(captureButtonTouchDragExit),
      for: .touchDragExit
    )
    view.addSubview(captureButton)

    enableCameraButtons(false)

    // layout constraints
    NSLayoutConstraint.activate([
      previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      previewView.topAnchor.constraint(equalTo: view.topAnchor),
      previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      captureButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      captureButton.bottomAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.bottomAnchor,
        constant: -24
      ),
      captureButton.widthAnchor.constraint(equalToConstant: 80),
      captureButton.heightAnchor.constraint(equalToConstant: 80),

      flashButton.leadingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.leadingAnchor,
        constant: 24
      ),
      flashButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),

      switchCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
      switchCameraButton.trailingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.trailingAnchor,
        constant: -24
      ),

      photoLibraryButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
      photoLibraryButton.leadingAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.leadingAnchor,
        constant: 24
      ),
    ])

    imagePicker = UIImagePickerController()

    // Request location authorization so photos and videos can be tagged with their location.
    if locationManager.authorizationStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }

    /*
     Check the video authorization status. Video access is required and audio
     access is optional. If the user denies audio access, AVCam won't
     record audio during movie recording.
     */
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      // The user has previously granted access to the camera.
      break

    case .notDetermined:
      /*
       The user has not yet been presented with the option to grant
       video access. Suspend the session queue to delay session
       setup until the access request has completed.

       Note that audio access will be implicitly requested when we
       create an AVCaptureDeviceInput for audio during session setup.
       */
      sessionQueue.suspend()
      AVCaptureDevice.requestAccess(for: .video) { granted in
        if !granted {
          self.setupResult = .notAuthorizedCamera
        }
      }

    default:
      // The user has previously denied access.
      setupResult = .notAuthorizedCamera
    }

    /*
     Request for Photo Library authorization status.
     Photo access is required to save the captured photos.
     */
    switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
    case .notDetermined:
      sessionQueue.suspend()
      PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        if status != .authorized, status != .limited {
          self.setupResult = .notAuthorizedPhotoLibrary
        }
      }
    case .restricted:
      setupResult = .notAuthorizedPhotoLibrary
    case .denied:
      setupResult = .notAuthorizedPhotoLibrary
    case .authorized:
      // The user has previously granted access to the photo library.
      break
    case .limited:
      // The user has granted limited access to the photo library.
      break
    @unknown default:
      // Default to not authorized
      setupResult = .notAuthorizedPhotoLibrary
    }

    /*
     Setup the capture session.
     In general, it's not safe to mutate an AVCaptureSession or any of its
     inputs, outputs, or connections from multiple threads at the same time.

     Don't perform these tasks on the main queue because
     AVCaptureSession.startRunning() is a blocking call, which can
     take a long time. Dispatch session setup to the sessionQueue, so
     that the main queue isn't blocked, which keeps the UI responsive.
     */
    sessionQueue.async {
      self.configureSession()
    }

    DispatchQueue.main.async {
//      self.spinner = UIActivityIndicatorView(style: .large)
//      self.previewView.addSubview(self.spinner)
      self.loadingHud = JGProgressHUD()
      self.loadingHud.textLabel.text = "Loading..."
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.isHidden = true
    
    // Check the setup result and start the session
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      switch self.setupResult {
      case .success:
        // Only setup observers, add focus tap and start the session if setup succeeded.
        self.addObservers()
        DispatchQueue.main.async {
          let focusTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.focusAndExposeTap)
          )
          focusTapGestureRecognizer.delegate = self
          self.view.addGestureRecognizer(focusTapGestureRecognizer)

          let changeCameraTapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.changeCamera)
          )
          changeCameraTapGestureRecognizer.delegate = self
          changeCameraTapGestureRecognizer.numberOfTapsRequired = 2
          self.view.addGestureRecognizer(changeCameraTapGestureRecognizer)
        }
        self.session.startRunning()
        self.isSessionRunning = self.session.isRunning

      case .notAuthorizedCamera:
        DispatchQueue.main.async {
          let usageDescription = Bundle.main
            .object(forInfoDictionaryKey: "NSCameraUsageDescription") as! String
          let alert = UIAlertController(
            title: usageDescription,
            message: "To give app permissions tap on \"Change Settings\" button",
            preferredStyle: .alert
          )
          let okAction = UIAlertAction(title: "Change Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
          alert.addAction(okAction)
          alert.addAction(cancelAction)
          self.present(alert, animated: true)
        }

      case .notAuthorizedPhotoLibrary:
        DispatchQueue.main.async {
          let usageDescription = Bundle.main
            .object(forInfoDictionaryKey: "NSPhotoLibraryUsageDescription") as! String
          let alert = UIAlertController(
            title: usageDescription,
            message: "To give app permissions tap on \"Change Settings\" button",
            preferredStyle: .alert
          )
          let okAction = UIAlertAction(title: "Change Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
          alert.addAction(okAction)
          alert.addAction(cancelAction)
          self.present(alert, animated: true)
        }

      case .configurationFailed:
        DispatchQueue.main.async {
          let alert = UIAlertController(
            title: "Error",
            message: "Failed to initialize the camera session",
            preferredStyle: .alert
          )
          let okAction = UIAlertAction(title: "OK", style: .default)
          alert.addAction(okAction)
          self.present(alert, animated: true)
        }
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      if self.setupResult == .success {
        self.session.stopRunning()
        self.isSessionRunning = self.session.isRunning
        DispatchQueue.main.async {
          self.enableCameraButtons(self.isSessionRunning)
        }
        self.removeObservers()
      }
    }
    super.viewWillDisappear(animated)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }

  override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)

    if let videoPreviewLayerConnection = previewView?.videoPreviewLayer.connection {
      let deviceOrientation = UIDevice.current.orientation
      guard let newVideoOrientation =
        AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue),
        deviceOrientation.isPortrait || deviceOrientation.isLandscape
      else {
        return
      }
      videoPreviewLayerConnection.videoOrientation = newVideoOrientation
    }
  }

  // MARK: - Session Management

  private enum SessionSetupResult {
    case success
    case notAuthorizedCamera
    case notAuthorizedPhotoLibrary
    case configurationFailed
  }

  private let session = AVCaptureSession()

  private var isSessionRunning = false

  // Communicate with the session and other session objects on this queue.
  private let sessionQueue = DispatchQueue(label: "com.quanshousio.capturesession")

  private var setupResult: SessionSetupResult = .success

  @objc private dynamic var videoDeviceInput: AVCaptureDeviceInput!

  private var previewView: CameraPreviewView!

  private var photoOutputView: UIImageView!

  private var imagePicker: UIImagePickerController!

//  weak var delegate: CameraView.Coordinator?

  // Call this on the session queue.
  private func configureSession() {
    if setupResult != .success {
      return
    }

    session.beginConfiguration()

    /*
     Do not create an AVCaptureMovieFileOutput when setting up the session because
     Live Photo is not supported when AVCaptureMovieFileOutput is added to the session.
     */
    session.sessionPreset = .photo

    // Add video input.
    do {
      var defaultVideoDevice: AVCaptureDevice?

      if let backCameraDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: .video,
        position: .back
      ) {
        // Default to the rear wide angle camera.
        defaultVideoDevice = backCameraDevice
      } else if let frontCameraDevice = AVCaptureDevice.default(
        .builtInWideAngleCamera,
        for: .video,
        position: .front
      ) {
        // If the rear wide angle camera isn't available, default to the front wide angle camera.
        defaultVideoDevice = frontCameraDevice
      }

      guard let videoDevice = defaultVideoDevice else {
        logger.info("Default video device is unavailable")
        setupResult = .configurationFailed
        session.commitConfiguration()
        return
      }

      let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

      if session.canAddInput(videoDeviceInput) {
        session.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput

        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          /*
           Dispatch video streaming to the main queue because
           AVCaptureVideopreviewView.videoPreviewLayer is the backing layer for PreviewView.
           You can manipulate UIView only on the main thread.
           Note: As an exception to the above rule, it's not necessary to serialize video
           orientation changes on the AVCaptureVideopreviewView.videoPreviewLayer’s connection with
           other session manipulation.

           Use the window scene's orientation as the initial video orientation. Subsequent
           orientation changes are handled by CameraViewController.viewWillTransition(to:with:).
           */
          var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
          if self.windowOrientation != .unknown {
            if let videoOrientation =
              AVCaptureVideoOrientation(rawValue: self.windowOrientation.rawValue)
            {
              initialVideoOrientation = videoOrientation
            }
          }
          self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
        }
      } else {
        logger.info("Couldn't add video device input to the session")
        setupResult = .configurationFailed
        session.commitConfiguration()
        return
      }
    } catch {
      logger.info("Couldn't create video device input: \(error.localizedDescription)")
      setupResult = .configurationFailed
      session.commitConfiguration()
      return
    }

    // Add an audio input device.
    do {
      let audioDevice = AVCaptureDevice.default(for: .audio)
      let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)

      if session.canAddInput(audioDeviceInput) {
        session.addInput(audioDeviceInput)
      } else {
        logger.info("Could not add audio device input to the session")
      }
    } catch {
      logger.info("Could not create audio device input: \(error.localizedDescription)")
    }

    // Add the photo output.
    if session.canAddOutput(photoOutput) {
      session.addOutput(photoOutput)

      photoOutput.isHighResolutionCaptureEnabled = true
      photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
      photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
      photoOutput.isPortraitEffectsMatteDeliveryEnabled =
        photoOutput.isPortraitEffectsMatteDeliverySupported
      photoOutput.enabledSemanticSegmentationMatteTypes =
        photoOutput.availableSemanticSegmentationMatteTypes
      photoOutput.maxPhotoQualityPrioritization = .balanced
      photoQualityPrioritizationMode = .balanced
    } else {
      logger.info("Could not add photo output to the session")
      setupResult = .configurationFailed
      session.commitConfiguration()
      return
    }

    session.commitConfiguration()
  }

  @objc private func resumeInterruptedSession() {
    sessionQueue.async {
      /*
       The session might fail to start running, for example, if a phone or FaceTime call is still
       using audio or video. This failure is communicated by the session posting a runtime error
       notification. To avoid repeatedly failing to start the session, only try to restart the
       session in the error handler if you aren't trying to resume the session.
       */
      self.session.startRunning()
      self.isSessionRunning = self.session.isRunning

      if !self.session.isRunning {
        DispatchQueue.main.async {
          let alert = UIAlertController(
            title: "Error",
            message: "Failed to resume the camera session",
            preferredStyle: .alert
          )
          let cancelAction = UIAlertAction(title: "OK", style: .default)
          alert.addAction(cancelAction)
          self.present(alert, animated: true)
        }
      }
    }
  }

  private func initializePhotoCaptureMode() {
    sessionQueue.async {
      self.session.beginConfiguration()
      self.session.sessionPreset = .photo
      self.session.commitConfiguration()
    }
  }

  // MARK: - Device Configuration

  private var captureButton: UIButton!

  private var switchCameraButton: UIButton!

  private var flashButton: UIButton!

  private var photoLibraryButton: UIButton!

  private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
    deviceTypes: [
      .builtInWideAngleCamera,
//      .builtInDualCamera,
//      .builtInTrueDepthCamera,
//      .builtInDualWideCamera,
    ],
    mediaType: .video, position: .unspecified
  )

  @objc private func changeFlashMode() {
    // off -> on -> auto
    switch flashMode {
    case .off:
      flashMode = .on
      let flashOffSymbol = UIImage(
        systemName: "bolt.fill",
        withConfiguration: UIImage.SymbolConfiguration(scale: .large)
      )
      flashButton.setImage(flashOffSymbol, for: .normal)
    case .on:
      flashMode = .auto
      let flashOffSymbol = UIImage(
        systemName: "bolt.badge.a.fill",
        withConfiguration: UIImage.SymbolConfiguration(scale: .large)
      )
      flashButton.setImage(flashOffSymbol, for: .normal)
    case .auto:
      flashMode = .off
      let flashOffSymbol = UIImage(
        systemName: "bolt.slash.fill",
        withConfiguration: UIImage.SymbolConfiguration(scale: .large)
      )
      flashButton.setImage(flashOffSymbol, for: .normal)
    @unknown default:
      break
    }
  }

  @objc private func openPhotoLibrary() {
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
      imagePicker.delegate = self
      imagePicker.sourceType = .savedPhotosAlbum
      imagePicker.allowsEditing = false

      present(imagePicker, animated: true, completion: nil)
    }
  }

  @objc private func changeCamera() {
    // Temporarily disable buttons
    enableCameraButtons(false)

    // Add blur view when changing camera
    let blurView = UIVisualEffectView()
    blurView.frame = previewView.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    previewView.addSubview(blurView)

    let currentVideoDevice = videoDeviceInput.device
    let currentPosition = currentVideoDevice.position

    let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: .video, position: .back
    )
    let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [.builtInWideAngleCamera],
      mediaType: .video, position: .front
    )
    var newVideoDevice: AVCaptureDevice?

    switch currentPosition {
    case .unspecified, .front:
      newVideoDevice = backVideoDeviceDiscoverySession.devices.first
      UIView.transition(with: previewView, duration: 0.5, options: .transitionFlipFromLeft) {
        blurView.effect = UIBlurEffect(style: .systemThinMaterial)
      }

    case .back:
      newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
      UIView.transition(with: previewView, duration: 0.5, options: .transitionFlipFromRight) {
        blurView.effect = UIBlurEffect(style: .systemThinMaterial)
      }

    default:
      newVideoDevice = currentVideoDevice
    }

    sessionQueue.async { [self] in
      if let videoDevice = newVideoDevice {
        do {
          let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

          self.session.beginConfiguration()

          // Remove the existing device input first, because AVCaptureSession doesn't support
          // simultaneous use of the rear and front cameras.
          self.session.removeInput(self.videoDeviceInput)

          if self.session.canAddInput(videoDeviceInput) {
            NotificationCenter.default.removeObserver(
              self,
              name: .AVCaptureDeviceSubjectAreaDidChange,
              object: currentVideoDevice
            )
            NotificationCenter.default.addObserver(
              self,
              selector: #selector(self.subjectAreaDidChange),
              name: .AVCaptureDeviceSubjectAreaDidChange,
              object: videoDeviceInput.device
            )

            self.session.addInput(videoDeviceInput)
            self.videoDeviceInput = videoDeviceInput
          } else {
            self.session.addInput(self.videoDeviceInput)
          }

          self.session.commitConfiguration()
        } catch {
          self.logger
            .info("Error occurred while creating video device input: \(error.localizedDescription)")
        }
      }

      DispatchQueue.main.async {
        self.enableCameraButtons(true)
        blurView.removeFromSuperview()
        self.focus(
          with: .autoFocus,
          exposureMode: .autoExpose,
          at: CGPoint(x: 0.5, y: 0.5),
          monitorSubjectAreaChange: true
        )
      }
    }
  }

  @objc private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
    let devicePoint = previewView.videoPreviewLayer
      .captureDevicePointConverted(fromLayerPoint: gestureRecognizer
        .location(in: gestureRecognizer.view))
    focus(
      with: .autoFocus,
      exposureMode: .autoExpose,
      at: devicePoint,
      monitorSubjectAreaChange: true
    )
  }

  private func focus(
    with focusMode: AVCaptureDevice.FocusMode,
    exposureMode: AVCaptureDevice.ExposureMode,
    at devicePoint: CGPoint,
    monitorSubjectAreaChange: Bool
  ) {
    sessionQueue.async { [weak self] in
      guard let self = self else { return }
      let device = self.videoDeviceInput.device
      do {
        try device.lockForConfiguration()

        /*
         Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
         Call set(Focus/Exposure)Mode() to apply the new point of interest.
         */
        if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(focusMode) {
          device.focusPointOfInterest = devicePoint
          device.focusMode = focusMode
        }

        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(exposureMode) {
          device.exposurePointOfInterest = devicePoint
          device.exposureMode = exposureMode
        }

        device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
        device.unlockForConfiguration()
      } catch {
        self.logger.info("Could not lock device for configuration: \(error.localizedDescription)")
      }
    }
  }

  private func enableCameraButtons(_ enable: Bool) {
    switchCameraButton.isEnabled =
      enable && videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
    captureButton.isEnabled = enable
    captureButton.alpha = captureButton.isEnabled ? 1.0 : 0.6
    flashButton.isEnabled = enable && videoDeviceInput.device.isFlashAvailable
    photoLibraryButton.isEnabled = enable
  }

  @objc private func captureButtonTouchDown() {
    captureButton.alpha = 0.6
  }

  @objc private func captureButtonTouchDragExit() {
    captureButton.alpha = 1.0
  }

  // MARK: - Capturing Photos

  private let photoOutput = AVCapturePhotoOutput()

  private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()

  private var photoQualityPrioritizationMode: AVCapturePhotoOutput.QualityPrioritization = .balanced

  private var flashMode: AVCaptureDevice.FlashMode = .off

  @objc private func capturePhoto() {
    enableCameraButtons(false)

    /*
     Retrieve the video preview layer's video orientation on the main queue before
     entering the session queue. Do this to ensure that UI elements are accessed on
     the main thread and session configuration is done on the session queue.
     */
    let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation

    sessionQueue.async {
      if let photoOutputConnection = self.photoOutput.connection(with: .video) {
        photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
      }
      var photoSettings = AVCapturePhotoSettings()

      // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
      if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
      }

      photoSettings.flashMode = self.flashMode

      photoSettings.isHighResolutionPhotoEnabled = true
      if let previewPhotoPixelFormatType =
        photoSettings.availablePreviewPhotoPixelFormatTypes.first
      {
        photoSettings.previewPhotoFormat =
          [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
      }

      photoSettings.photoQualityPrioritization = self.photoQualityPrioritizationMode
      


      let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings) {
        // Flash the screen to signal that we took a photo.
        DispatchQueue.main.async {
          self.previewView.videoPreviewLayer.opacity = 0
          UIView.animate(withDuration: 0.25) {
            self.previewView.videoPreviewLayer.opacity = 1
          }
        }
      } photoProcessingHandler: { animate in
        if animate {
          self.loadingHud.show(in: self.view)
        } else {
          self.loadingHud.dismiss(animated: true)
        }
//        DispatchQueue.main.async {
//          if animate {
//            self.spinner.hidesWhenStopped = true
//            self.spinner.center = CGPoint(
//              x: self.previewView.frame.size.width / 2.0,
//              y: self.previewView.frame.size.height / 2.0
//            )
//            self.spinner.startAnimating()
//          } else {
//            self.spinner.stopAnimating()
//          }
//        }
      } completionHandler: { photoCaptureProcessor, data in
        // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
        self.sessionQueue.async {
          self.inProgressPhotoCaptureDelegates[
            photoCaptureProcessor.requestedPhotoSettings.uniqueID
          ] = nil
        }
        if let data = data, let image = UIImage(data: data) {
          DispatchQueue.main.async {
            let cropViewController = PFCropViewController(croppingStyle: self.croppingStyle, image: image)
            self.navigationController?.pushViewController(cropViewController, animated: true)
          }
        }
      }

      // Specify the location the photo was taken
      photoCaptureProcessor.location = self.locationManager.location

      // The photo output holds a weak reference to the photo capture delegate
      // and stores it in an array to maintain a strong reference.
      self.inProgressPhotoCaptureDelegates[
        photoCaptureProcessor.requestedPhotoSettings.uniqueID
      ] = photoCaptureProcessor

      self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
    }
  }

  // MARK: - KVO and Notifications

  private var keyValueObservations = [NSKeyValueObservation]()

  private func addObservers() {
    let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
      guard let isSessionRunning = change.newValue else { return }

      DispatchQueue.main.async {
        self.enableCameraButtons(isSessionRunning)
      }
    }
    keyValueObservations.append(keyValueObservation)

    let systemPressureStateObservation = observe(
      \.videoDeviceInput.device.systemPressureState,
      options: .new
    ) { _, change in
      guard let systemPressureState = change.newValue else { return }
      self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
    }
    keyValueObservations.append(systemPressureStateObservation)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(subjectAreaDidChange),
      name: .AVCaptureDeviceSubjectAreaDidChange,
      object: videoDeviceInput.device
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionRuntimeError),
      name: .AVCaptureSessionRuntimeError,
      object: session
    )

    /*
     A session can only run when the app is full screen. It will be interrupted
     in a multi-app layout, introduced in iOS 9, see also the documentation of
     AVCaptureSessionInterruptionReason. Add observers to handle these session
     interruptions and show a preview is paused message. See the documentation
     of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
     */
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionWasInterrupted),
      name: .AVCaptureSessionWasInterrupted,
      object: session
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionInterruptionEnded),
      name: .AVCaptureSessionInterruptionEnded,
      object: session
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(sessionDidStartRunning),
      name: .AVCaptureSessionDidStartRunning,
      object: session
    )
  }

  private func removeObservers() {
    NotificationCenter.default.removeObserver(self)

    for keyValueObservation in keyValueObservations {
      keyValueObservation.invalidate()
    }
    keyValueObservations.removeAll()
  }

  @objc func subjectAreaDidChange(notification _: NSNotification) {
    let devicePoint = CGPoint(x: 0.5, y: 0.5)
    focus(
      with: .continuousAutoFocus,
      exposureMode: .continuousAutoExposure,
      at: devicePoint,
      monitorSubjectAreaChange: false
    )
  }

  @objc func sessionRuntimeError(notification: NSNotification) {
    guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }

    logger.info("Capture session runtime error: \(error.localizedDescription)")
    // If media services were reset, and the last start succeeded, restart the session.
    if error.code == .mediaServicesWereReset {
      sessionQueue.async {
        if self.isSessionRunning {
          self.session.startRunning()
          self.isSessionRunning = self.session.isRunning
        } else {
//          DispatchQueue.main.async {
//            self.resumeButton.isHidden = false
//          }
        }
      }
    } else {
//      resumeButton.isHidden = false
    }
  }

  private func setRecommendedFrameRateRangeForPressureState(
    systemPressureState: AVCaptureDevice.SystemPressureState
  ) {
    /*
     The frame rates used here are only for demonstration purposes.
     Your frame rate throttling may be different depending on your app's camera configuration.
     */
    let pressureLevel = systemPressureState.level
    if pressureLevel == .serious || pressureLevel == .critical {
      do {
        try videoDeviceInput.device.lockForConfiguration()
        logger.warning(
          "WARNING: Reached elevated system pressure level: \(pressureLevel.rawValue). Throttling frame rate."
        )
        videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
        videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
        videoDeviceInput.device.unlockForConfiguration()
      } catch {
        logger.info("Could not lock device for configuration: \(error.localizedDescription)")
      }
    } else if pressureLevel == .shutdown {
      logger.info("Session stopped running due to shutdown system pressure level.")
    }
  }

  @objc func sessionWasInterrupted(notification _: NSNotification) {
    /*
     In some scenarios you want to enable the user to resume the session.
     For example, if music playback is initiated from Control Center while
     using AVCam, then the user can let AVCam resume
     the session running, which will stop music playback. Note that stopping
     music playback in Control Center will not automatically resume the session.
     Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
     */
    /*
     if let userInfoValue = notification
       .userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
       let reasonIntegerValue = userInfoValue.integerValue,
       let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue)
     {
       logger.info("Capture session was interrupted with reason \(reason)")

       var showResumeButton = false
       if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
         showResumeButton = true
       } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
         // Fade-in a label to inform the user that the camera is unavailable.
         cameraUnavailableLabel.alpha = 0
         cameraUnavailableLabel.isHidden = false
         UIView.animate(withDuration: 0.25) {
           self.cameraUnavailableLabel.alpha = 1
         }
       } else if reason == .videoDeviceNotAvailableDueToSystemPressure {
         logger.info("Session stopped running due to shutdown system pressure level.")
       }
       if showResumeButton {
         // Fade-in a button to enable the user to try to resume the session running.
         resumeButton.alpha = 0
         resumeButton.isHidden = false
         UIView.animate(withDuration: 0.25) {
           self.resumeButton.alpha = 1
         }
       }
     }
      */
  }

  @objc func sessionInterruptionEnded(notification _: NSNotification) {
    logger.info("Capture session interruption ended")
    /*
     if !resumeButton.isHidden {
       UIView.animate(
         withDuration: 0.25,
         animations: {
           self.resumeButton.alpha = 0
         }, completion: { _ in
           self.resumeButton.isHidden = true
         }
       )
     }
     if !cameraUnavailableLabel.isHidden {
       UIView.animate(
         withDuration: 0.25,
         animations: {
           self.cameraUnavailableLabel.alpha = 0
         }, completion: { _ in
           self.cameraUnavailableLabel.isHidden = true
         }
       )
     }
     */
  }

  @objc func sessionDidStartRunning(notifcation _: Notification) {
    focus(
      with: .autoFocus,
      exposureMode: .autoExpose,
      at: CGPoint(x: 0.5, y: 0.5),
      monitorSubjectAreaChange: true
    )
  }
}

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    picker.dismiss(animated: true) {
      if let image = info[.originalImage] as? UIImage {
        let cropViewController = PFCropViewController(croppingStyle: self.croppingStyle, image: image)
        cropViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(cropViewController, animated: true)
      } else {
        print("Failed to get the image from the user")
      }
    }
  }
}

extension CameraViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldReceive touch: UITouch
  ) -> Bool {
    // ignore gesture tap in subviews
    touch.view == previewView
  }
}

extension AVCaptureVideoOrientation {
  init?(deviceOrientation: UIDeviceOrientation) {
    switch deviceOrientation {
    case .portrait: self = .portrait
    case .portraitUpsideDown: self = .portraitUpsideDown
    case .landscapeLeft: self = .landscapeRight
    case .landscapeRight: self = .landscapeLeft
    default: return nil
    }
  }

  init?(interfaceOrientation: UIInterfaceOrientation) {
    switch interfaceOrientation {
    case .portrait: self = .portrait
    case .portraitUpsideDown: self = .portraitUpsideDown
    case .landscapeLeft: self = .landscapeLeft
    case .landscapeRight: self = .landscapeRight
    default: return nil
    }
  }
}

extension AVCaptureDevice.DiscoverySession {
  var uniqueDevicePositionsCount: Int {
    var uniqueDevicePositions = [AVCaptureDevice.Position]()

    for device in devices where !uniqueDevicePositions.contains(device.position) {
      uniqueDevicePositions.append(device.position)
    }

    return uniqueDevicePositions.count
  }
}
