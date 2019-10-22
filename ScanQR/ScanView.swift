//
//  ScanView.swift
//  ScanQR
//
//  Created by Omran on 2018-10-16.
//  Copyright © 2018 Guarana. All rights reserved.
//

import UIKit
import AVFoundation

enum ScanError: Error {
    case noCameraAvailable
    case noScannedValue
    case noSessionConfigured
    case custom(String)
}

extension ScanError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noCameraAvailable: return "No camera available"
        case .noScannedValue: return "Error getting code value"
        case .noSessionConfigured: return "There is no session, you should call configureVedioSession befor start capturing"
        case .custom(let text): return text
        }
    }
}


enum FlashStatus {
    case on
    case off
}

protocol ScanDelegate: class {
    func didScanCode(value: String)
    func didStartCapture(start: Bool,error: Error?)
    func didStopCapture(stop: Bool,error: Error?)
    func didChangeFlashStatus(status: FlashStatus)
    func scanError(error: Error)
}

@IBDesignable open class ScanView: UIView {

    private var captureSession:AVCaptureSession?
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    private var device:AVCaptureDevice?
    private(set) var isScanning : Bool = false
    private(set) var flashStatus: FlashStatus = .off

    var overlayView: UIView?
    weak var delegate: ScanDelegate?
    var types: [AVMetadataObject.ObjectType] = [.qr]
    
    func configureVedioSession(with types: [AVMetadataObject.ObjectType]) {
        
        self.types = types
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            device = captureDevice
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = self.types
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
                isScanning = true
            } catch let error {
                delegate?.scanError(error: error)
                return
            }
        }else{
            delegate?.scanError(error: ScanError.noCameraAvailable)
        }
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate
extension ScanView: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // No code found
        if metadataObjects.count == 0 {
            return
        }
        
        // code found but maybe isn't the same type
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
        self.types.contains(metadataObj.type) else {
            return
        }
        
        // Code found and with the same type
        if self.types.contains(metadataObj.type) {
            guard let value = metadataObj.stringValue else {
                delegate?.scanError(error: ScanError.noScannedValue)
                return
            }
            
            delegate?.didScanCode(value: value)
        }
    }
}

// MARK: Public methods
extension ScanView {
    
    func startRunning() {
        changeRunningStatus(to: true)
    }
    
    func stopRunning()  {
       changeRunningStatus(to: false)
    }
    
    func flashOn() {
        changeFlashStatus(to: .on)
    }
    
     func flashOff() {
        changeFlashStatus(to: .off)
    }
}

// MARK: Helpers
private extension ScanView {
    
    func changeRunningStatus(to status: Bool) {
        
        isScanning = status
        
        guard let delegate  = self.delegate else {
            print("delegate object is nil")
            return
        }
        
        guard let session = captureSession else {
            let err = ScanError.custom("you should call configureVedioSession befor run")
            status ? delegate.didStartCapture(start: false, error: err) : delegate.didStopCapture(stop: false, error: err)
            return
        }
        
        if status {
            session.startRunning()
            delegate.didStartCapture(start: true, error: nil)
        } else {
            flashOff()
            session.stopRunning()
            delegate.didStopCapture(stop: true, error: nil)
        }
    }
    
    func changeFlashStatus(to status: FlashStatus) {
        
        guard let device = self.device, device.hasTorch else {
            return
        }
        
        do{
            try device.lockForConfiguration()
            device.torchMode = status == .on ? .on : .off
            device.flashMode = status == .on ? .on : .off
            device.unlockForConfiguration()
            flashStatus = status
            delegate?.didChangeFlashStatus(status: status)
        } catch {
            delegate?.scanError(error: error)
        }
    }
}
