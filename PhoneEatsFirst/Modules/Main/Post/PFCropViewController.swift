//
//  PFCropViewController.swift
//  PFCropViewController
//
//  Created by itsnk on 7/26/21.
//

import CropViewController
import UIKit
import SwiftUI

class PFCropViewController: CropViewController {
  private let imageView = UIImageView()
  var bgColor: UIColor!
  
  override init(croppingStyle: CropViewCroppingStyle, image: UIImage) {
    super.init(croppingStyle: croppingStyle, image: image)
    aspectRatioPreset = .presetSquare
    aspectRatioLockEnabled = true
    aspectRatioPickerButtonHidden = true
    resetButtonHidden = true
    hidesBottomBarWhenPushed = true
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
//    self.view.backgroundColor = .systemBackground
    self.cropView.translucencyAlwaysHidden = true
    self.toolbarPosition = .top
    self.cropView.foregroundContainerView.isOpaque = false
    bgColor = self.view.backgroundColor
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.cropView.croppingViewsHidden = true
//    self.cropView.isOpaque = false
    self.toolbar.isHidden = true
    self.cropView.backgroundColor = .systemBackground
    self.cropView.translucencyAlwaysHidden = true
    self.view.isHidden = true
  }

  override func viewDidDisappear(_ animated: Bool) {
    self.cropView.croppingViewsHidden = false
    self.cropView.isOpaque = true
    self.cropView.translucencyAlwaysHidden = false
    self.cropView.backgroundColor = bgColor
    self.toolbar.isHidden = false
    self.view.isHidden = false
  }
}

extension PFCropViewController: CropViewControllerDelegate {
  public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
    let tagViewController = TagViewController()
    tagViewController.image = image
    self.navigationController?.pushViewController(tagViewController, animated: false)
  }
}

