//
//  GNPViewController.swift
//  CoreMLTest
//
//  Created by zjy on 2017/6/14.
//  Copyright © 2017年 zjy. All rights reserved.
//

import UIKit
import Foundation
import CoreGraphics


class GNPViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let tableView : UITableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    var cameraPicker: UIImagePickerController!
    var photoPicker: UIImagePickerController!
    
    let model : GoogLeNetPlaces = GoogLeNetPlaces.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue:UIColor.black]  // Title's text color
        self.title = "GoogLeNetPlaces"
        self.view.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(self.tableView)
    }
    
    //MARK: 获取相机和相册
    func initCameraPicker(){
        cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        //在需要的地方present出来
        //self.present(cameraPicker, animated: true, completion: nil)
    }
    
    func initPhotoPicker(){
        photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        //在需要的地方present出来
        //self.present(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //获得照片
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaleImage = image.scaleToSize(size: CGSize.init(width: 224, height: 224))
        let buffer : CVPixelBuffer = image.pixelBufferFromCGImage(originImage: scaleImage)
        
        let input : GoogLeNetPlacesInput = GoogLeNetPlacesInput.init(sceneImage: buffer)
        var output : GoogLeNetPlacesOutput? = nil
        
        do {
            output = try model.prediction(input: input)
        } catch  {}
        let message : String = output!.sceneLabel + ":" + String(format:"%.2f",output!.sceneLabelProbs[output!.sceneLabel]!)
        let alertController = UIAlertController(title: "照片内容", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "确认", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }))
        picker.present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK: UITableViewDataSource/UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.initCameraPicker()
            self.present(cameraPicker, animated: true, completion: nil)
        } else {
            self.initPhotoPicker()
            self.present(photoPicker, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellid : String = "cellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellid as String)
        if cell == nil {
            cell=UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellid)
        }
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Take photos"
        } else {
            cell?.textLabel?.text = "Photo album"
        }
        return cell!
    }
    
}
//MARK: - UIImage extension
extension UIImage {
    func scaleToSize(size : CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size,false,UIScreen.main.scale);
        self.draw(in: CGRect.init (x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    
    func pixelBufferFromCGImage(originImage : UIImage) -> CVPixelBuffer {
        let image : CGImage = originImage.cgImage!
        
        let options : [CFString : NSNumber] = [kCVPixelBufferCGImageCompatibilityKey:NSNumber.init(value: true),
                                               kCVPixelBufferCGBitmapContextCompatibilityKey:NSNumber.init(value: true)]
        var pxbuffer : CVPixelBuffer? = nil
        
        let frameWidth = 224
        let frameHeight = 224
        
        let status : CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_32ARGB, options as CFDictionary, &pxbuffer)
        assert(pxbuffer != nil && status == kCVReturnSuccess, "nil value")
        
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace : CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
        let context : CGContext = CGContext(data: pxdata,
                                            width: frameWidth,
                                            height: frameHeight,
                                            bitsPerComponent: 8,
                                            bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!),
                                            space: rgbColorSpace,
                                            bitmapInfo: bitmapInfo.rawValue)!
        context.draw(image, in: CGRect.init(x: 0, y: 0, width: frameWidth, height: frameHeight))
        
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        return pxbuffer!;
    }
}
