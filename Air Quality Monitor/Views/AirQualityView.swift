//
//  ContentView.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import SwiftUI
import Combine

struct AirQualityView: View {
    
    var yesterdayAqi = 72
    var aqi = 75
    var tomorrowAqi = 70
    
    var body: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()
            Text("AQI: \(aqi)")
                .frame(width: 200, height: 200, alignment: .center)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .onAppear() {
            LocationManager.shared.receivedLocationCompletion = { location, error in
                print(location as Any)
                print(error as Any)
                
                guard let location = location else { return }
                NetworkManager.fetchOpenAQMeasurements(location: location, radius: 5000) {
                    switch $0 {
                    case .failure(let error):
                        break
                    case .success(let measurements):
                        print(measurements)
                    }
                }
            }
            LocationManager.shared.getLocation()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AirQualityView()
    }
}
