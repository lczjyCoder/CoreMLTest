//
//  InceptionV3.swift
//  CoreMLTest
//
//  Created by zjy on 2017/6/26.
//  Copyright © 2017年 zjy. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class IVViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    // vision request
    var visionRequests = [VNRequest]()
    //MARK: 创建 Vision Model
    let vnModel : VNCoreMLModel? = {
        guard let vncModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("can't load Places ML model")
        }
        return vncModel
    }()
    private lazy var resultView: UILabel! = {
        var label = UILabel.init(frame: CGRect.init(x: 10, y: 150, width: UIScreen.main.bounds.size.width, height: 0))
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    //MARK: - Method
    override func viewDidLoad() {
        self.startScan()
        // set up the vision model
        self.view.addSubview(self.resultView)
        guard let visionModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Could not load model")
        }
        // set up the request using our vision model
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop
        visionRequests = [classificationRequest]
    }
    
    func handleClassifications(request: VNRequest, error: Error?) {
        if let theError = error {
            print("Error: \(theError.localizedDescription)")
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        let classifications = observations[0...4] // top 4 results
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(($0.confidence * 100.0).rounded())" })
            .joined(separator: "\n")
        
        DispatchQueue.main.async {
            let height = self.autoLabelHeight(with: classifications, labelWidth: UIScreen.main.bounds.size.width)
            self.resultView.bounds = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: height + 5)
            self.resultView.text = classifications
        }
    }
    
    func autoLabelHeight(with text:String , labelWidth: CGFloat) -> CGFloat{
        var size = CGRect()
        let size2 = CGSize(width: labelWidth, height: 0)//设置label的最大宽度
        size = text.boundingRect(with: size2, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:self.resultView.font] , context: nil);
        return size.size.height
    }
    
    //只要解析到数据,就会调用
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        connection.videoOrientation = .portrait
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: 1, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
//MARK: ----------- 创建 视频流输入输出 ----------
    private lazy var  session : AVCaptureSession = AVCaptureSession() // 会话
    private lazy var previewLayer : AVCaptureVideoPreviewLayer = { // 预览层
        let layer = AVCaptureVideoPreviewLayer.init(session: self.session)
        layer.frame = UIScreen.main.bounds
        return layer
    }()
    // queue for processing video frames
    let captureQueue = DispatchQueue(label: "captureQueue")
    private lazy var deviceInput : AVCaptureInput? = { // 输入对象
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { //获取摄像头
            fatalError("No video camera available")
        }
        do {
            let input = try AVCaptureDeviceInput.init(device: device)
            return input
        }catch{
            print(error)
            return nil
        }
    }()
    private lazy var deviceOutPut : AVCaptureVideoDataOutput? = {
        let outPut = AVCaptureVideoDataOutput.init()
        outPut.setSampleBufferDelegate(self, queue: self.captureQueue)
        outPut.alwaysDiscardsLateVideoFrames = true
        outPut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        return outPut
    }() //输出对象
    
    private func startScan(){
        // 判断能否将输入/输出添加到会话中
        if !session.canAddInput(deviceInput!) {
            return
        }
        if !session.canAddOutput(deviceOutPut!) {
            return
        }
        session.sessionPreset = .high
        // 添加到会话中
        session.addInput(deviceInput!)
        session.addOutput(deviceOutPut!)
        // 添加预览图层到底层
        view.layer.insertSublayer(previewLayer, at: 0)
        var gradientLayer: CAGradientLayer!
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor,
            UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.0).cgColor,
        ]
        gradientLayer.locations = [0.0, 0.3]
        gradientLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(gradientLayer)
        // 开始扫描
        session.startRunning()
    }
}

