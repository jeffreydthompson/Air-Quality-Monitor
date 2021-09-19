//
//  OpenAQ.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import Foundation

struct OpenAQMeasurements: Codable {
    
    let meta: OpenAQMeta
    let results: [OpenAQResult]
    
}

struct OpenAQMeta: Codable {
    let name: String?
    let license: String?
    let website: String?
    let page: Int?
    let limit: Int?
    let found: Int?
}

/*
 
 Schema
 
 "meta": {
     "name": "openaq-api",
     "license": "CC BY 4.0d",
     "website": "https://u50g7n0cbj.execute-api.us-east-1.amazonaws.com/",
     "page": 1,
     "limit": 100,
     "found": 632374
   },
 */

struct OpenAQResult: Codable {
    
    let locationId: Int?
    let location: String?
    let parameter: String?
    let value: Double?
    let date: OpenAQDate?
    let unit: String?
    let coordinates: Coordinate?
    let country: String?
    let city: String?
    let isMobile: Bool?
    let isAnalysis: Bool?
    let entity: String?
    let sensorType: String?
    
}

struct OpenAQDate: Codable {
    
    //TODO: - computed var returning Date()
    
    let utc: String?
    let local: String?
}

struct Coordinate: Codable {
    
    let latitude: Double?
    let longitude: Double?
    
}


/*
 
 Schema
 
 "results": [
    {
      "locationId": 2007,
      "location": "San Jose - Knox Ave",
      "parameter": "no2",
      "value": 0.011,
      "date": {
        "utc": "2021-09-18T00:00:00+00:00",
        "local": "2021-09-17T17:00:00-07:00"
      },
      "unit": "ppm",
      "coordinates": {
        "latitude": 37.338202,
        "longitude": -121.849892
      },
      "country": "US",
      "city": "San Jose-Sunnyvale-Santa Clara",
      "isMobile": false,
      "isAnalysis": false,
      "entity": "government",
      "sensorType": "reference grade"
    }
 
 */
