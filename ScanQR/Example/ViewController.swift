//
//  ViewController.swift
//  ScanQR
//
//  Created by Omran on 2018-10-16.
//  Copyright © 2018 Guarana. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var vedioView: UIView!
    
    @IBOutlet weak var scanView: ScanView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // make sure that you add (Privacy - Camera Usage Description) to info.plist file
        // create object from view
//        scanView = ScanView(frame: vedioView.frame, overlayView: vedioView,scanObjectType:.qr)
        scanView.types = [.qr,.ean13,.ean8]
        scanView?.delegate = self
        // add it to man view
        self.view.addSubview(scanView!)
        scanView?.center = self.view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //this function will create the vedio session and start scanning
        scanView?.configureVedioSession(with: [.qr])
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        if scanView!.flashStatus == .on {
            scanView!.flashOff()
        }else{
            scanView!.flashOn()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scanView?.stopRunning()
    }
}

extension ViewController: ScanDelegate{
    func scanError(error: Error) {
        print(error.localizedDescription)
    }
    
    func didScanCode(value: String) {
        // called when the camera takes the value from barcode
        scanView?.stopRunning()
        self.view.backgroundColor = UIColor(hex:"21D364")
        self.makeAlert(title: "QRCode found!", message: "\(value) , continue scanning?") {
            self.scanView?.startRunning()
        }
    }
    func didStopCapture(stop: Bool, error: Error?) {
        // called when stop running
        print("stop running")
        print(stop)
    }
    func didStartCapture(start: Bool, error: Error?) {
        // called when start running
        print("start running")
        print(start)
    }
    func didChangeFlashStatus(status: FlashStatus) {
        // called when flash changed status ( "status" gives the new status)
        if status == .off {
            self.flashBtn.setTitle("on", for: .normal)
        }else{
            self.flashBtn.setTitle("off", for: .normal)
        }
    }
}
