//
//  LocationManager.swift
//  ScanQR
//
//  Created by Omran on 2018-10-31.
//  Copyright © 2018 Guarana. All rights reserved.
//


import Foundation
import CoreLocation

protocol LocationDelegate {
    func didDetectCurrentLocation(currentLocation:CLLocation)
}

class LocationManager: CLLocationManager,CLLocationManagerDelegate {
    var locationDelegate : LocationDelegate?
    var currentLocation:CLLocation?
    var stopWhenDetectLocation = true
    
    init(locationDelegate:LocationDelegate) {
        super.init()
        self.locationDelegate = locationDelegate
        if (CLLocationManager.locationServicesEnabled()){
            self.delegate = self
            self.desiredAccuracy = kCLLocationAccuracyBest
            self.requestAlwaysAuthorization()
            self.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            self.currentLocation = location
            self.locationDelegate?.didDetectCurrentLocation(currentLocation: self.currentLocation!)
            if stopWhenDetectLocation{
                manager.stopUpdatingLocation()
            }
        }
    }
}
