//
//  PhotoCaptureProcessor.swift
//  PhotoCaptureProcessor
//
//  Created by itsnk on 7/24/21.
//

import AVFoundation
import os
import Photos

class PhotoCaptureProcessor: NSObject {
  private(set) var requestedPhotoSettings: AVCapturePhotoSettings

  private let willCapturePhotoAnimation: () -> Void

  lazy var context = CIContext()

  private let completionHandler: (PhotoCaptureProcessor, Data?) -> Void

  private let photoProcessingHandler: (Bool) -> Void

  private var photoData: Data?

  // Save the location of captured photos
  var location: CLLocation?

  let logger = Logger(subsystem: "com.itsnk.PhoneEatsFirst", category: "Camera")

  init(
    with requestedPhotoSettings: AVCapturePhotoSettings,
    willCapturePhotoAnimation: @escaping () -> Void,
    photoProcessingHandler: @escaping (Bool) -> Void,
    completionHandler: @escaping (PhotoCaptureProcessor, Data?) -> Void
  ) {
    self.requestedPhotoSettings = requestedPhotoSettings
    self.willCapturePhotoAnimation = willCapturePhotoAnimation
    self.photoProcessingHandler = photoProcessingHandler
    self.completionHandler = completionHandler
  }
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
  ) {
    willCapturePhotoAnimation()
    
    photoProcessingHandler(true)
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    photoProcessingHandler(false)

    if let error = error {
      logger.error("An error occurred while processing photo: \(error.localizedDescription)")
      return
    }

    photoData = photo.fileDataRepresentation()
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
    error: Error?
  ) {
    if let error = error {
      logger.error("An error occurred while capturing photo: \(error.localizedDescription)")
      completionHandler(self, nil)
      return
    }

    guard let photoData = photoData else {
      logger.error("Data representation for photo is not available")
      completionHandler(self, photoData)
      return
    }
    
    completionHandler(self, photoData)

    /*
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
      if status == .authorized {
        PHPhotoLibrary.shared().performChanges {
          let options = PHAssetResourceCreationOptions()
          let creationRequest = PHAssetCreationRequest.forAsset()
          options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType
            .map(\.rawValue)

          // Specify the location the photo was taken
          creationRequest.location = self.location

          creationRequest.addResource(with: .photo, data: photoData, options: options)
        } completionHandler: { _, error in
          if let error = error {
            self.logger
              .error(
                "An error occurred while saving photo to photo library: \(error.localizedDescription)"
              )
          }

          self.completionHandler(self, photoData)
        }
      } else {
        self.completionHandler(self, photoData)
      }
    }
     */
  }
}
