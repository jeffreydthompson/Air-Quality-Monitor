//
//  OpenAQ.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import Foundation

struct OpenAQMeasurements: Codable {
    
    private static let uom: Dictionary<String,String> = [
        "pm25":"ug/m3",
        "o3":"ppm",
        "no2":"ppm",
        "co":"ppm"
    ]

    //let meta: OpenAQMeta // uneeded.
    private let results: [OpenAQResult]
    
    var city: String {
        var cities = Dictionary<String, Int>()
        results.forEach {
            if let city = $0.city {
                cities[city, default: 0] += 1
            }
        }
        let maxCity = cities.max { $0.value < $1.value }?.key ?? ""
        return maxCity
    }
    
    var coordinates: String {
        var coordinates = Dictionary<String, Int>()
        results.forEach {
            if let coordinate = $0.coordinates {
                if let lat = coordinate.latitude, let long = coordinate.longitude {
                    coordinates["\(lat),\(long)", default: 0] += 1
                }
            }
        }
        let maxCoordinate = coordinates.max { $0.value < $1.value }?.key ?? ""
        return maxCoordinate
    }
    
    var aqi: (majorPollutant: String, value: Int) {
        let maxPollutant = [pm25Aqi, o3Aqi, no2Aqi, coAqi].sorted { $0.value > $1.value }.first!
        return (majorPollutant: maxPollutant.name, value: maxPollutant.value)
    }
    var pm25Aqi: (name: String, value: Int) { getAqi(for: "pm25") }
    var o3Aqi: (name: String, value: Int) { getAqi(for: "o3") }
    var no2Aqi: (name: String, value: Int) { getAqi(for: "no2") }
    var coAqi: (name: String, value: Int) { getAqi(for: "co") }

    private var pm25History: [(name: String, value: Double, date: Date, uom: String)] { getHistory(for: "pm25") }
    private var o3History: [(name: String, value: Double, date: Date, uom: String)] { getHistory(for: "o3") }
    private var no2History: [(name: String, value: Double, date: Date, uom: String)] { getHistory(for: "no2") }
    private var coHistory: [(name: String, value: Double, date: Date, uom: String)] { getHistory(for: "co") }
    
    private func getHistory(for pollutant: String) -> [(name: String, value: Double, date: Date, uom: String)] {
        let pollutantHistory = results.filter { $0.parameter == pollutant }
        return pollutantHistory.compactMap { pollutantName -> (name: String, value: Double, date: Date, uom: String)? in
            guard let date = pollutantName.date?.localDate else { return nil }
            guard let value = pollutantName.value else { return nil }
            return (name: pollutantName.parameter!, value: value, date: date, uom: OpenAQMeasurements.uom[pollutant]!)
        }.sorted { $0.date > $1.date }
    }
    
    private func getAqi(for pollutant: String) -> (name: String, value: Int) {
        let sourceDictionary: Dictionary<String, [(name: String, value: Double, date: Date, uom: String)]> = [
            "pm25":pm25History,
            "co":coHistory,
            "no2":no2History,
            "o3":o3History
        ]
        
        guard let source = sourceDictionary[pollutant] else { return (name: pollutant, value: -1) }
        let values = source.map { $0.value }
        let average = values.reduce(0) { $0 + $1 } / Double(source.count)
        guard let max = values.max() else { return (name: pollutant, value: -1) }
        guard let min = values.min() else { return (name: pollutant, value: -1) }
        
        return EPAData.getAqi(for: pollutant, min: .ppm(min), max: .ppm(max), avg: .ppm(average))
    }
}

/*
 
Meta data available from API but unused.
 
struct OpenAQMeta: Codable {
    let name: String?
    let license: String?
    let website: String?
    let page: Int?
    let limit: Int?
    let found: Int?
}
 */

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
    
    // commented out are available from API, but unused.
    
    //let locationId: Int?
    //let location: String?
    let parameter: String?
    let value: Double?
    let date: OpenAQDate?
    let unit: String? // unit of measure for pollutant
    let coordinates: Coordinate?
    let country: String?
    let city: String?
    //let isMobile: Bool?
    //let isAnalysis: Bool?
    //let entity: String?
    //let sensorType: String?
    
}

struct OpenAQDate: Codable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ssZZZZ"
        dateFormatter.locale = .current
        return dateFormatter
    }()
    
    let utc: String?
    let local: String?
    
    var localDate: Date? {
        guard let localDate = local else { return nil }
        return OpenAQDate.dateFormatter.date(from: localDate.replacingOccurrences(of: "T", with: " "))
    }
    
    var utcDate: Date? {
        guard let utcDate = utc else { return nil }
        return OpenAQDate.dateFormatter.date(from: utcDate.replacingOccurrences(of: "T", with: " "))
    }
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
