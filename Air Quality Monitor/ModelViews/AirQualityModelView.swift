//
//  AirQualityModelView.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/18/21.
//

import Foundation
import CoreLocation

class AirQualityModelView: ObservableObject {
    
    @Published var airQualityMetrics = Dictionary<Date,AirQuality>()
    @Published var fetchError: Error?
    @Published var cityName: String?
    @Published var stationName: String?
    
    init() {
        
    }
    
    public func fetchData() {
        
        // get location first
        LocationManager.shared.receivedLocationCompletion = { [weak self] location, error in
            if let error = error {
                self?.fetchError = error
                return
            }
            
            // then fetch data from APIs
            if let location = location {
                self?.fetchAPIData(location: location)
            }
        }
        LocationManager.shared.getLocation()
        
    }
    
    private func fetchAPIData(location: CLLocationCoordinate2D) {
        // fetch current and historical data from openAQ
        NetworkManager.fetchOpenAQMeasurements(location: location, radius: 5000) { [weak self] in
            switch $0 {
            case .failure(let error):
                self?.fetchError = error
                break
            case .success(let measurements):
                
                break
            }
        }
    }
}

struct AirQuality {
    let aqi: Int
    let pm25: Double?
    let o3: Double?
    let co: Double?
    let no2: Double?
}
