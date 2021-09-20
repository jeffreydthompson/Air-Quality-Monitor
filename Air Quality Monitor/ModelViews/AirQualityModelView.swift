//
//  AirQualityModelView.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/18/21.
//

import Foundation
import CoreLocation
import SwiftUI

class AirQualityModelView: NSObject, ObservableObject {
    
    enum AirQualityError: Error {
        case searchDataNotValid
        
        var localizedDescription: String {
            switch self {
            case .searchDataNotValid:
                return "Must enter valid country and city names"
            }
        }
    }
    
    private let indicatorColors: Dictionary<ClosedRange<Int>,Color> = [
        (0...50) : .green,
        (51...100) : .yellow,
        (101...150) : .orange,
        (151...200) : .red,
        (201...300) : .purple,
        (301...400) : .purple
    ]
    
    @Published var modelViewError: Error?
    @Published var cityName: String?
    @Published var stationName: String?
    @Published var coordinates: CLLocationCoordinate2D?
    
    @Published var todayAqi: Int? {
        willSet {
            indicatorColors.forEach { if $0.key.contains(newValue ?? -1) { self.indicatorColor = $0.value }}
        }
    }
    @Published var yesterdayAqi: Int?
    @Published var tomorrowAqi: Int?
    
    @Published var indicatorColor: Color
    
    @Published var searchCountry: String = ""
    @Published var searchCity: String = ""
    
    lazy private var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        return locationManager
    }()
    
    override init() {
        indicatorColor = .green
    }
    
    public func fetchLocalData() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    public func geocoderSearch() {
        guard !searchCity.isEmpty, !searchCountry.isEmpty else {
            self.modelViewError = AirQualityError.searchDataNotValid
            return
        }
        
        CLGeocoder().geocodeAddressString("\(searchCity) \(searchCountry)") { [weak self] clPlacemark, error in
            if let error = error {
                self?.modelViewError = error
                return
            }
            
            if let location = clPlacemark?.first?.location?.coordinate {
                self?.fetchAPIData(location: location)
            }
        }
    }
    
    func fetchAPIData(location: CLLocationCoordinate2D) {
        // fetch today's value from openAQ

        NetworkManager.fetchOpenAQMeasurements(location: location, searchRadiusInMeters: 10000, daysIntoThePast: 0) { [weak self] in
            switch $0 {
            case .failure(let error):
                self?.modelViewError = error
            case .success(let value):
                print("today value recieved: \(value.aqi.value)")
                DispatchQueue.main.async {
                    self?.todayAqi = value.aqi.value
                    self?.cityName = value.city
                    self?.coordinates = location
                }
            }
            self?.fetchYesterdayAqi(location: location)
        }
    }
    
    private func fetchYesterdayAqi(location: CLLocationCoordinate2D) {
        // fetch yesterday's value from openAQ. sequential to not overload shared urlsession
        NetworkManager.fetchOpenAQMeasurements(location: location, searchRadiusInMeters: 10000, daysIntoThePast: 1) { [weak self] in
            switch $0 {
            case .failure(let error):
                self?.modelViewError = error
            case .success(let value):
                print("yesterday value received: \(value.aqi.value)")
                DispatchQueue.main.async {
                    self?.yesterdayAqi = value.aqi.value
                }
            }
            
            self?.fetchTomorrowAqi(location: location)
        }
    }
    
    private func fetchTomorrowAqi(location: CLLocationCoordinate2D) {
        // fetch tomorrow's value from AqiCN. sequential to not overload shared urlsession
        NetworkManager.fetchAqiCNMeasurements(location: location) { [weak self] in
            switch $0 {
            case .failure(let error):
                self?.modelViewError = error
            case .success(let value):
                print("tomorrow value received: \(value.tomorrowForecast)")
                DispatchQueue.main.async {
                    self?.tomorrowAqi = value.tomorrowForecast
                    self?.stationName = value.data?.city?.name ?? "No station data"
                }
            }
        }
    }
    
}

extension AirQualityModelView: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager receive: \(locations)")
        guard let location = locations.first else { return }
        fetchAPIData(location: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager error: \(error.localizedDescription)")
        DispatchQueue.main.async { [weak self] in
            self?.modelViewError = error
        }
    }
    
}
