//
//  EPAData.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/19/21.
//

import Foundation

struct EPAData {
    
    enum PollutantValue {
        case ppm(Double)
        case ppb(Int)
    }
    
    static let uom: Dictionary<String,String> = [
        "pm10":"ug/m3",
        "pm25":"ug/m3",
        "o3":"ppm",
        "no2":"ppm",
        "co":"ppm"
    ]
    
    // all data provided by EPA.  source: https://en.wikipedia.org/wiki/Air_quality_index
    static let pollutantRanges: Dictionary<String,Dictionary<ClosedRange<Double>, ClosedRange<Int>>> = [
        "pm10": [
            (0.0...54.9):(0...50),
            (55.0...154.9):(51...100),
            (155.0...254.9):(101...150),
            (255.0...354.9):(151...200),
            (355.0...424.9):(201...300),
            (425.0...504.9):(301...400),
            (505.0...604.0):(401...500)
        ],
        "pm25": [
            (0.0...12.0):(0...50),
            (12.1...35.4):(51...100),
            (35.5...55.4):(101...150),
            (55.5...150.4):(151...200),
            (150.5...250.4):(201...300),
            (250.5...350.4):(301...400),
            (350.5...500.4):(401...500)
        ],
        "o3": [
            (0.000...0.054):(0...50),
            (0.055...0.070):(51...100),
            (0.071...0.085):(101...150),
            (0.086...0.105):(151...200),
            (0.106...0.200):(201...300),
            (0.201...0.400):(301...400),
            (0.401...0.600):(401...500)
        ],
        "no2": [
            (0.000...0.053):(0...50),
            (0.054...0.100):(51...100),
            (0.101...0.360):(101...150),
            (0.361...0.649):(151...200),
            (0.650...1.249):(201...300),
            (1.250...1.649):(301...400),
            (1.650...2.049):(401...500)
        ],
        "co": [
            (0.0...4.4):(0...50),
            (4.5...9.4):(51...100),
            (9.5...12.4):(101...150),
            (12.5...15.4):(151...200),
            (15.5...30.4):(201...300),
            (30.5...40.4):(301...400),
            (40.5...50.4):(401...500)
        ]
    ]

    static func getAqi(for pollutant: String, min: PollutantValue, max: PollutantValue, avg: PollutantValue) -> (name: String, value: Int) {

        var localMax = 0.0
        var localMin = 0.0
        var localAverage = 0.0
        
        // convert PPB to PPM all values.
        switch max {
        case .ppm(let value):
            localMax = value
        case .ppb(let value):
            localMax = Double(value)/1000.0
        }
        
        switch min {
        case .ppm(let value):
            localMin = value
        case .ppb(let value):
            localMin = Double(value)/1000.0
        }
        
        switch avg {
        case .ppm(let value):
            localAverage = value
        case .ppb(let value):
            localAverage = Double(value)/1000.0
        }
        
        guard let range = EPAData.pollutantRanges[pollutant] else { return (name: pollutant, value: -1) }
        
        guard let aqiRange = range.compactMap({ ranges -> ClosedRange<Int>? in
            ranges.key.contains(localAverage) ? ranges.value : nil
        }).first else { return (name: pollutant, value: -1)}
        
        //HACK: - Error handling when all values same over time.  Equation below tries to divide by zero.
        if(localMax-localMin) == 0 {
            let scalarRange = range.filter({ $0.key.contains(localAverage)}).first!
            let scaler = (scalarRange.key.upperBound - scalarRange.key.lowerBound) / (localAverage - scalarRange.key.lowerBound)
            let scale = (Double(scalarRange.value.upperBound - scalarRange.value.lowerBound) * scaler) + Double(scalarRange.value.lowerBound)
            return (name: pollutant, value: Int(scale))
        }
        
        // equation provided by EPA.  source: https://en.wikipedia.org/wiki/Air_quality_index
        let equationStepOne = Double(aqiRange.max()! - aqiRange.min()!) / (localMax - localMin)
        let equationStepTwo = equationStepOne * (localAverage - localMin)
        return (name: pollutant, value: Int(equationStepTwo) + aqiRange.min()!)
    }
    
    static func getAqi(for pollutant: String, min: Int, max: Int, avg: Int, convertPPBtoPPM: Bool) -> (name: String, value: Int)  {
        EPAData.getAqi(for: pollutant, min: Double(min), max: Double(max), avg: Double(avg), convertPPBtoPPM: convertPPBtoPPM)
    }
    
    static func getAqi(for pollutant: String, min: Double, max: Double, avg: Double, convertPPBtoPPM: Bool) -> (name: String, value: Int) {

        let localMax = convertPPBtoPPM ? max/1000.0 : max
        let localMin = convertPPBtoPPM ? min/1000.0 : min
        let localAvg = convertPPBtoPPM ? avg/1000.0 : avg
        
        guard let range = EPAData.pollutantRanges[pollutant] else { return (name: pollutant, value: -1) }
        
        guard let aqiRange = range.compactMap({ ranges -> ClosedRange<Int>? in
            ranges.key.contains(localAvg) ? ranges.value : nil
        }).first else { return (name: pollutant, value: -1)}
        
        // equation provided by EPA.  source: https://en.wikipedia.org/wiki/Air_quality_index
        let equationStepOne = Double(aqiRange.max()! - aqiRange.min()!) / (localMax - localMin)
        let equationStepTwo = equationStepOne * (localAvg - localMin)
        return (name: pollutant, value: Int(equationStepTwo) + aqiRange.min()!)
    }
}
