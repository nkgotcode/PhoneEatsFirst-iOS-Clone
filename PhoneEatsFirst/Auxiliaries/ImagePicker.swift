//
//  ImagePicker.swift
//  ImagePicker
//
//  Created by itsnk on 7/26/21.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
  @Environment(\.presentationMode) private var presentationMode
  
  @Binding var selectedImage: UIImage
  
  var sourceType: UIImagePickerController.SourceType = .photoLibrary

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = false
    imagePicker.sourceType = sourceType
    imagePicker.delegate = context.coordinator

    return imagePicker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

  final class Coordinator:
    NSObject,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
  {
    var parent: ImagePicker

    init(_ parent: ImagePicker) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let image = info[.originalImage] as? UIImage {
        parent.selectedImage = image
      }

      parent.presentationMode.wrappedValue.dismiss()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

