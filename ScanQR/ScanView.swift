//
//  ScanView.swift
//  ScanQR
//
//  Created by Omran on 2018-10-16.
//  Copyright © 2018 Guarana. All rights reserved.
//

import UIKit
import AVFoundation

enum FlashStatus{
    case on
    case off
}

protocol ScanDelegate: class {
    func didScanedBarCode(value:String)
    func didStartCapture(start:Bool,error:String?)
    func didStopCapture(stop:Bool,error:String?)
    func didChangeFlashStatus(status:FlashStatus)
}

@IBDesignable open class ScanView: UIView,AVCaptureMetadataOutputObjectsDelegate {

    private var captureSession:AVCaptureSession?
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    private var device:AVCaptureDevice?
    var overlayView:UIView?
    weak var delegate:ScanDelegate?
    var isFlashOn = false
    var isScanning : Bool = false
    var type:AVMetadataObject.ObjectType = .qr
//
//    init(frame:CGRect,overlayView:UIView?,scanObjectType:AVMetadataObject.ObjectType = .qr) {
//        super.init(frame: frame)
//        self.overlayView = overlayView
//        self.type = scanObjectType
//    }
//
  

    
    func configureVedioSession(onSuccess:()-> Void,onFailur:(String)->Void)  {
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            device = captureDevice
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = [self.type]
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = self.layer.bounds
                self.layer.addSublayer(videoPreviewLayer!)
                captureSession?.startRunning()
                delegate?.didStartCapture(start: true, error: nil)
                if self.overlayView != nil {
                    self.addSubview(overlayView!)
                    overlayView?.center = self.center
                    self.bringSubviewToFront(overlayView!)
                }
                onSuccess()
                isScanning = true
            } catch let error{
                onFailur(error.localizedDescription)
                return
            }
        }else{
            onFailur("no camera available")
        }
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == self.type {
            if metadataObj.stringValue != nil {
                let value = metadataObj.stringValue
                if let objectId = value {
                    delegate?.didScanedBarCode(value: objectId)
                }else{
                    print("error getting value")
                }
                return
            }
        }
    }

    
    func startRunning() {
        isScanning = true
        guard let delegate  = self.delegate else {
            print("delegate object is nil")
            return
        }
        if captureSession != nil {
            captureSession?.startRunning()
            delegate.didStartCapture(start: true,error:nil)
        }else{
            delegate.didStartCapture(start: false,error:"you should call configureVedioSession befor run")
        }
    }
    
    func stopRunning()  {
        isScanning = false
        guard let delegate  = self.delegate else {
            print("delegate object is nil")
            return
        }
        flashOff()
        if captureSession != nil {
            captureSession?.stopRunning()
            delegate.didStopCapture(stop: true, error: nil)
        }else{
            delegate.didStopCapture(stop: false,error:"you should call configureVedioSession befor")
        }
    }
    
     func flashOn(){
        guard let device = self.device else {
            return
        }
        do{
            if (device.hasTorch){
                try device.lockForConfiguration()
                device.torchMode = .on
                device.flashMode = .on
                device.unlockForConfiguration()
                isFlashOn = true
                delegate?.didChangeFlashStatus(status: .on)
            }
        }catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
            print("Device tourch Flash Error ")
        }
    }
    
     func flashOff(){
        guard let device = self.device else {
            return
        }
        do{
            if (device.hasTorch){
                try device.lockForConfiguration()
                device.torchMode = .off
                device.flashMode = .off
                device.unlockForConfiguration()
                isFlashOn = false
                delegate?.didChangeFlashStatus(status: .off)
            }
        }catch{
            //DISABEL FLASH BUTTON HERE IF ERROR
            print("Device tourch Flash Error ")
        }
    }
}
