//
//  AqiCN.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/18/21.
//

import Foundation

struct AqiCNMeasurements: Codable {
    let status: String?
    let data: AqiData?
    
    var tomorrowForecast: Int {
        data?.forecast?.daily?.tomorrowForecast ?? -1
    }
}


struct AqiData: Codable {
    // commented out available from API but not used in app
    let aqi: Int?
    //let idx: Int?
    let attributions: [AqiAttribution]?
    let city: AqiCity?
    //let dominentpol: String?
    //let iaqi: Aqiiaqi?
    let forecast: AqiForecast?
}

struct AqiForecast: Codable {
    let daily: AqiDailyForecast?
}

struct AqiDailyForecast: Codable {
    let o3: [AqiForecastData?]
    let pm25: [AqiForecastData?]
    let pm10: [AqiForecastData?]
    let uvi: [AqiForecastData?]
    
    var tomorrowForecast: Int {
        guard let maxVal = [tomorrowO3Aqi,tomorrowPm10Aqi,tomorrowPm25Aqi].sorted(by: { $0.value > $1.value }).first else { return -1 }
        return maxVal.value
    }
    
    var todayUviAqi: (name: String, value: Int) { getTodayAqi(for: "uvi")}
    var todayPm10Aqi: (name: String, value: Int) { getTodayAqi(for: "pm10")}
    var todayPm25Aqi: (name: String, value: Int) { getTodayAqi(for: "pm25")}
    var todayO3Aqi: (name: String, value: Int) { getTodayAqi(for: "o3")}
    
    var tomorrowUviAqi: (name: String, value: Int) { getTomorrowAqi(for: "uvi")}
    var tomorrowPm10Aqi: (name: String, value: Int) { getTomorrowAqi(for: "pm10")}
    var tomorrowPm25Aqi: (name: String, value: Int) { getTomorrowAqi(for: "pm25")}
    var tomorrowO3Aqi: (name: String, value: Int) { getTomorrowAqi(for: "o3")}
    
    private func getTodayAqi(for pollutant: String) -> (name: String, value: Int) {
        let pollutantData: Dictionary<String,[AqiForecastData?]> = [
            "o3":o3,
            "pm25":pm25,
            "pm10":pm10,
            "uvi":uvi
        ]
        
        guard let forecastData = pollutantData[pollutant] else { return (name: pollutant, value: -1) }
        
        guard let tomorrowData = forecastData.compactMap({ value -> AqiForecastData? in
            
            if let date = value?.date {
                return Calendar(identifier: .gregorian).isDateInToday(date) ? value : nil
            }
            return nil
        }).first else { return (name: pollutant, value: -1) }
        
        guard let min = tomorrowData.min, let max = tomorrowData.max, let avg = tomorrowData.avg else { return (name: pollutant, value: -1) }
        return EPAData.getAqi(for: pollutant, min: .ppb(min), max: .ppb(max), avg: .ppb(avg))
    }
    
    private func getTomorrowAqi(for pollutant: String) -> (name: String, value: Int) {
        let pollutantData: Dictionary<String,[AqiForecastData?]> = [
            "o3":o3,
            "pm25":pm25,
            "pm10":pm10,
            "uvi":uvi
        ]
        
        guard let forecastData = pollutantData[pollutant] else { return (name: pollutant, value: -1) }
        
        guard let tomorrowData = forecastData.compactMap({ value -> AqiForecastData? in
            
            if let date = value?.date {
                return Calendar(identifier: .gregorian).isDateInTomorrow(date) ? value : nil
            }
            return nil
        }).first else { return (name: pollutant, value: -1) }
        
        guard let min = tomorrowData.min, let max = tomorrowData.max, let avg = tomorrowData.avg else { return (name: pollutant, value: -1) }
        //return EPAData.getAqi(for: pollutant, min: min, max: max, avg: avg, convertPPBtoPPM: true)
        return EPAData.getAqi(for: pollutant, min: .ppb(min), max: .ppb(max), avg: .ppb(avg))
    }
}

struct AqiForecastData: Codable {
    let avg: Int?
    let day: String?
    let max: Int?
    let min: Int?
    
    var date: Date? {
        guard let dateString = day else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateFormatter.locale = .current
        return dateFormatter.date(from: dateString)
    }
}

struct Aqiiaqi: Codable {
    let co: AqiValue?
    let h: AqiValue?
    let no2: AqiValue?
    let o3: AqiValue?
    let p: AqiValue?
    let pm10: AqiValue?
    let pm25: AqiValue?
    let so2: AqiValue?
    let t: AqiValue?
    let w: AqiValue?
}

struct AqiValue: Codable {
    let v: Double?
}

struct AqiAttribution: Codable {
    let url: String?
    let name: String?
}

struct AqiCity: Codable {
    let geo: [Double]?
    let name: String?
    let url: String?
}


/*

 schema:
 
{
    "status": "ok",
    "data": {
        "aqi": 42,
        "idx": 1451,
        "attributions": [
            {
                "url": "http://www.bjmemc.com.cn/",
                "name": "Beijing Environmental Protection Monitoring Center (北京市环境保护监测中心)"
            },
            {
                "url": "https://waqi.info/",
                "name": "World Air Quality Index Project"
            }
        ],
        "city": {
            "geo": [
                39.954592,
                116.468117
            ],
            "name": "Beijing (北京)",
            "url": "https://aqicn.org/city/beijing"
        },
        "dominentpol": "pm25",
        "iaqi": {
            "co": {
                "v": 4.6
            },
            "h": {
                "v": 88
            },
            "no2": {
                "v": 5.5
            },
            "o3": {
                "v": 26.4
            },
            "p": {
                "v": 1016
            },
            "pm10": {
                "v": 10
            },
            "pm25": {
                "v": 42
            },
            "so2": {
                "v": 1.6
            },
            "t": {
                "v": 19
            },
            "w": {
                "v": 2.5
            }
        },
        "time": {
            "s": "2021-09-19 08:00:00",
            "tz": "+08:00",
            "v": 1632038400,
            "iso": "2021-09-19T08:00:00+08:00"
        },
        "forecast": {
            "daily": {
                "o3": [
                    {
                        "avg": 1,
                        "day": "2021-09-17",
                        "max": 18,
                        "min": 1
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-18",
                        "max": 7,
                        "min": 1
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-19",
                        "max": 6,
                        "min": 1
                    },
                    {
                        "avg": 5,
                        "day": "2021-09-20",
                        "max": 14,
                        "min": 1
                    },
                    {
                        "avg": 2,
                        "day": "2021-09-21",
                        "max": 17,
                        "min": 1
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-22",
                        "max": 14,
                        "min": 1
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-23",
                        "max": 8,
                        "min": 1
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-24",
                        "max": 1,
                        "min": 1
                    }
                ],
                "pm10": [
                    {
                        "avg": 60,
                        "day": "2021-09-18",
                        "max": 72,
                        "min": 28
                    },
                    {
                        "avg": 73,
                        "day": "2021-09-19",
                        "max": 119,
                        "min": 63
                    },
                    {
                        "avg": 29,
                        "day": "2021-09-20",
                        "max": 58,
                        "min": 21
                    },
                    {
                        "avg": 23,
                        "day": "2021-09-21",
                        "max": 32,
                        "min": 19
                    },
                    {
                        "avg": 49,
                        "day": "2021-09-22",
                        "max": 57,
                        "min": 34
                    },
                    {
                        "avg": 58,
                        "day": "2021-09-23",
                        "max": 67,
                        "min": 46
                    },
                    {
                        "avg": 53,
                        "day": "2021-09-24",
                        "max": 58,
                        "min": 46
                    },
                    {
                        "avg": 49,
                        "day": "2021-09-25",
                        "max": 58,
                        "min": 45
                    }
                ],
                "pm25": [
                    {
                        "avg": 155,
                        "day": "2021-09-18",
                        "max": 164,
                        "min": 88
                    },
                    {
                        "avg": 172,
                        "day": "2021-09-19",
                        "max": 243,
                        "min": 158
                    },
                    {
                        "avg": 87,
                        "day": "2021-09-20",
                        "max": 154,
                        "min": 68
                    },
                    {
                        "avg": 71,
                        "day": "2021-09-21",
                        "max": 91,
                        "min": 59
                    },
                    {
                        "avg": 123,
                        "day": "2021-09-22",
                        "max": 154,
                        "min": 89
                    },
                    {
                        "avg": 147,
                        "day": "2021-09-23",
                        "max": 158,
                        "min": 134
                    },
                    {
                        "avg": 148,
                        "day": "2021-09-24",
                        "max": 159,
                        "min": 138
                    },
                    {
                        "avg": 124,
                        "day": "2021-09-25",
                        "max": 151,
                        "min": 89
                    }
                ],
                "uvi": [
                    {
                        "avg": 0,
                        "day": "2021-09-18",
                        "max": 0,
                        "min": 0
                    },
                    {
                        "avg": 0,
                        "day": "2021-09-19",
                        "max": 2,
                        "min": 0
                    },
                    {
                        "avg": 0,
                        "day": "2021-09-20",
                        "max": 2,
                        "min": 0
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-21",
                        "max": 5,
                        "min": 0
                    },
                    {
                        "avg": 1,
                        "day": "2021-09-22",
                        "max": 5,
                        "min": 0
                    },
                    {
                        "avg": 0,
                        "day": "2021-09-23",
                        "max": 2,
                        "min": 0
                    }
                ]
            }
        },
        "debug": {
            "sync": "2021-09-19T09:53:39+09:00"
        }
    }
}

 */
