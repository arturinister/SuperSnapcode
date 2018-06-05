//
//  CropWallpaperViewController.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/15/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import UIKit
import CropViewController

class CropWallpaperViewController: UIViewController, CropViewControllerDelegate {
    
    var imageToCrop: UIImage! = UIImage()
    var toolbarInstructionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.snapBlack
        
        let cropViewController = CropViewController(image: imageToCrop)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.customAspectRatio = UIScreen.main.bounds.size
        cropViewController.toolbar.clampButtonHidden = true
        cropViewController.toolbar.rotateClockwiseButtonHidden = true
        cropViewController.toolbar.rotateCounterclockwiseButtonHidden = true
        cropViewController.toolbar.resetButton.isHidden = true
        cropViewController.toolbar.subviews[0].backgroundColor = UIColor.snapBlack
        cropViewController.cropView.subviews[1].backgroundColor = UIColor.snapBlack
        cropViewController.toolbar.cancelTextButton.setTitleColor(UIColor.snapYellow, for: .normal)
        cropViewController.toolbar.doneTextButton.setTitleColor(UIColor.snapYellow, for: .normal)
        cropViewController.view.backgroundColor = UIColor.snapBlack
        cropViewController.cropView.backgroundColor = UIColor.snapBlack
        
        toolbarInstructionsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width * 0.5, height: 45))
        toolbarInstructionsLabel.center = cropViewController.toolbar.center
        toolbarInstructionsLabel.text = "Crop Image"
        toolbarInstructionsLabel.textColor = .white
        toolbarInstructionsLabel.textAlignment = .center
        
        addChildViewController(cropViewController)
        cropViewController.view.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 20)
        if view.isIPhoneX() {
            cropViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            toolbarInstructionsLabel.frame.origin.y -= 34.0
        }
        
        view.addSubview(cropViewController.view)
        view.addSubview(toolbarInstructionsLabel)
        cropViewController.didMove(toParentViewController: self)
    }


    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        let selectPhotoViewController = SelectPhotoViewController()
        
        System.shared.appDelegate().pageViewController?.setViewControllers([selectPhotoViewController], direction: .reverse, animated: true, completion: nil)

        cropViewController.delegate = nil
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        let resizedImage = image.resized(size: CGSize(width: UIScreen.main.bounds.size.width * 4.0, height: UIScreen.main.bounds.size.height * 4.0))
        
        System.shared.wallpaper = resizedImage
        System.shared.snapcode = System.shared.snapcode?.resized(size: CGSize(width: resizedImage.size.width * 0.6, height: resizedImage.size.width * 0.6))
        
        let exportWallpaperViewController = ExportWallpaperViewController()
        System.shared.appDelegate().pageViewController?.setViewControllers([exportWallpaperViewController], direction: .forward, animated: true, completion: nil)
        
        cropViewController.delegate = nil
    }

}

