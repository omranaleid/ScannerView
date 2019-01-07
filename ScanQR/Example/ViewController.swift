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
        scanView.type = .qr
        scanView?.delegate = self
        // add it to man view
        self.view.addSubview(scanView!)
        scanView?.center = self.view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //this function will create the vedio session and start scanning
        scanView?.configureVedioSession(onSuccess: {
            // successfully session created
            print("success configure")
        }, onFailur: { (err) in
            // [camera permissions] or [error detect vedio device (simulater)]
            print(err)
        })
    }
    
    @IBAction func toggleFlash(_ sender: Any) {
        if scanView!.isFlashOn {
            scanView!.flashOff()
        }else{
            scanView!.flashOn()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scanView?.stopRunning()
    }
}

extension ViewController:ScanDelegate{
    func didScanedBarCode(value: String) {
        // called when the camera takes the value from barcode
        scanView?.stopRunning()
        self.view.backgroundColor = UIColor(hex:"21D364")
        self.makeAlert(title: "QRCode found!", message: "\(value) , continue scanning?") {
            self.scanView?.startRunning()
        }
    }
    func didStopCapture(stop: Bool, error: String?) {
        // called when stop running
        print("stop running")
        print(stop)
    }
    func didStartCapture(start: Bool, error: String?) {
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
