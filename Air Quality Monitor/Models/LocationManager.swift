//
//  LocationManager.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/18/21.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    var receivedLocationCompletion: ((CLLocationCoordinate2D?, Error?) -> Void)?
    
    lazy private var manager: CLLocationManager = {
       let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    static var shared = LocationManager()
    
    override init() {
        
    }
    
    public func getLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        receivedLocationCompletion?(locations.first?.coordinate, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        receivedLocationCompletion?(nil, error)
    }
    
}
