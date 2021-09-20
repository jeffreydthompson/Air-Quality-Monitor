//
//  IntegrationTests.swift
//  Air Quality MonitorTests
//
//  Created by Jeffrey Thompson on 9/19/21.
//

import XCTest
@testable import Air_Quality_Monitor

class IntegrationTests: XCTestCase {
    
    let sut = AirQualityModelView()

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testAPICalls() {
        
        let exp = expectation(description: #function)
        
        sut.fetchLocalData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) { [weak self] in
            guard self?.sut.todayAqi != nil,self?.sut.tomorrowAqi != nil,self?.sut.yesterdayAqi != nil else { return }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
        XCTAssert(true)
        
    }

    func testNYC() {
        
        let exp = expectation(description: #function)
        
        sut.searchCity = "New York City"
        sut.searchCountry = "USA"
        sut.geocoderSearch()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) { [weak self] in
            guard self?.sut.todayAqi != nil,self?.sut.tomorrowAqi != nil,self?.sut.yesterdayAqi != nil else { return }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
        XCTAssert(true)
        
    }
}
