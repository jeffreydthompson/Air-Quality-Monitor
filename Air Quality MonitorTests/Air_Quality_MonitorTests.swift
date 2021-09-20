//
//  Air_Quality_MonitorTests.swift
//  Air Quality MonitorTests
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import XCTest
import CoreLocation
@testable import Air_Quality_Monitor


class Air_Quality_MonitorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAqiCN() {
        let exp = expectation(description: #function)
        
        let coordinate = CLLocationCoordinate2D(latitude: 37.376, longitude: -121.803)
        NetworkManager.fetchAqiCNMeasurements(location: coordinate) {
            switch $0 {
            case .failure(let error):
                print(error as Any)
            case .success(let value):
                print("~~~~~~~~~~~~~~TODAY~~~~~~~~~~~~`")
                print("Calculated aqi from pm25: \(value.data?.forecast?.daily?.todayPm25Aqi as Any)")
                print("Calculated aqi from o3: \(value.data?.forecast?.daily?.todayO3Aqi as Any)")
                print("Calculated aqi from pm10: \(value.data?.forecast?.daily?.todayPm10Aqi as Any)")
                print("Calculated aqi from uvi: \(value.data?.forecast?.daily?.todayUviAqi as Any)")
                
                
                print("~~~~~~~~~~~~~~TOMORROW~~~~~~~~~~~~`")
                print("tomorrow o3: \(value.data?.forecast?.daily?.tomorrowO3Aqi as Any)")
                print("tomorrow pm25: \(value.data?.forecast?.daily?.tomorrowPm25Aqi as Any)")
                print("tomorrow pm10: \(value.data?.forecast?.daily?.tomorrowPm10Aqi as Any)")
                print("tomorrow uvi: \(value.data?.forecast?.daily?.tomorrowUviAqi as Any)")
                print(value as Any)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 2)
        
        XCTAssert(true)
    }

    func testOpenAQApi() {
        
        let exp = expectation(description: #function)
        //37.376052, -121.803207
        let coordinate = CLLocationCoordinate2D(latitude: 37.376, longitude: -121.803)
        NetworkManager.fetchOpenAQMeasurements(location: coordinate, searchRadiusInMeters: 10000, daysIntoThePast: 0) {
            switch $0 {
            case .failure(let error):
                print(error as Any)
            case .success(let value):
                print("city: \(value.city)")
                print("gps: \(value.coordinates)")
                print(value.aqi)
                
                
                print("Calculated aqi from pm25: \(value.pm25Aqi)")
                print("Calculated aqi from o3: \(value.o3Aqi)")
                print("Calculated aqi from no2: \(value.no2Aqi)")
                print("Calculated aqi from co: \(value.coAqi)")
                //print(value.results)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 2)
        
        XCTAssert(true)
    }
    
}
