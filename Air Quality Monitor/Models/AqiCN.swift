//
//  AqiCN.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/18/21.
//

import Foundation

struct AqiCNMeasurements: Codable {
    
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
