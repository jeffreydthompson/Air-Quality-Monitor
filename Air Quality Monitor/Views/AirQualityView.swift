//
//  ContentView.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import SwiftUI
import Combine

struct AirQualityView: View {
    
    @ObservedObject var airQualityModelView: AirQualityModelView
    
    var body: some View {
        Group {
            if airQualityModelView.modelViewError != nil {
                ErrorView(airQualityModelView: airQualityModelView)
            }
            if airQualityModelView.todayAqi == nil {
                LoadingView()
            } else {
                ZStack {
                    //BackgroundView(airQualityModelView: airQualityModelView)
                    LinearGradient(gradient: Gradient(colors: [Color(.sRGB, white: 0.9, opacity: 0.9), Color(hue: 0.6, saturation: 0.6, brightness: 0.7)]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    
                    VStack {
                        VStack {
                            Text("Air Quality Index:")
                                .font(.title)
                            Text("\(airQualityModelView.todayAqi ?? 0)")
                                .font(.largeTitle)
                                .background(airQualityModelView.indicatorColor)
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .frame(width: 50, height: 50, alignment: .center)
                            Text("\(airQualityModelView.cityName ?? "")")
                                .font(.title3)
                            Text("\(airQualityModelView.stationName ?? "")")
                                .font(.body)
                            Text("""
                                \(String(format: "%.5f", airQualityModelView.coordinates?.latitude ?? 0)), \(String(format: "%.5f", airQualityModelView.coordinates?.longitude ?? 0))
                                """)
                                .font(.body)
                        }
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 65.0, leading: 5.0, bottom: 30.0, trailing: 5.0))
                        
                        HStack {
                            VStack {
                                Text("Yesterday's AQI:")
                                    .font(.title3)
                                Text("\(airQualityModelView.yesterdayAqi ?? 0)")
                                    .font(.largeTitle)
                            }
                            .padding(10)
                            
                            VStack {
                                Text("Tomorrow's AQI:")
                                    .font(.title3)
                                Text("\(airQualityModelView.tomorrowAqi ?? 0)")
                                    .font(.largeTitle)
                            }
                            .padding(10)
                        }
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 5.0, leading: 5.0, bottom: 55.0, trailing: 5.0))
                        
                        VStack {
                            Text("Search another city")
                                .font(.title3)
                            
                            Text("City")
                                .font(.caption)
                            TextField("City", text: $airQualityModelView.searchCity)
                                .frame(width: 300, height: 35, alignment: .center)
                                .background(Color.white)
                                .foregroundColor(.gray)
                            Text("Country")
                                .font(.caption)
                            TextField("Country", text: $airQualityModelView.searchCountry)
                                .frame(width: 300, height: 35, alignment: .center)
                                .background(Color.white)
                                .foregroundColor(.gray)
                            Button("Search") {
                                airQualityModelView.geocoderSearch()
                            }
                            .frame(width: 200, height: 35, alignment: .center)
                            .background(Color(.sRGB, white: 0.8, opacity: 0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            .padding(3)
                            
                            HStack {
                                Button(action: {
                                    airQualityModelView.fetchLocalData()
                                }, label: {
                                    Image(systemName: "location.fill")
                                        .frame(width: 35, height: 35, alignment: .center)
                                })
                                .foregroundColor(Color(.sRGB, red: 0.2, green: 0.3, blue: 0.7, opacity: 1.0))
                                
                                Text("Get local data")
                                    .font(.title3)
                            }
                            .padding(EdgeInsets(top: 45.0, leading: 25.0, bottom: 5.0, trailing: 25.0))
                            
                        }
                        .foregroundColor(.black)
                        .padding(EdgeInsets(top: 5.0, leading: 5.0, bottom: 100.0, trailing: 5.0))
                    }
                }
            }
        }
        .onAppear() {
            airQualityModelView.fetchLocalData()
        }
    }
}

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, white: 0.9, opacity: 0.9), Color(hue: 0.6, saturation: 0.6, brightness: 0.7)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .ignoresSafeArea()
            VStack {
                Text("Air Quality Monitor")
                    .font(.largeTitle)
                    .foregroundColor(Color(.sRGB, red: 0.2, green: 0.3, blue: 0.7, opacity: 1.0))
                    .shadow(radius: 2)
                WaitSpinner()
                    .frame(width: 100, height: 100, alignment: .center)
                    .padding(EdgeInsets(top: 50.0, leading: 0.0, bottom: 350.0, trailing: 0.0))
            }
            
        }
    }
}

struct ErrorView: View {
    
    @ObservedObject var airQualityModelView: AirQualityModelView
    
    var body: some View {
        VStack {
            Text(airQualityModelView.modelViewError?.localizedDescription ?? "Error")
            Button("Dismiss") {
                airQualityModelView.modelViewError = nil
            }
        }
        .frame(width: 300, height: 300, alignment: .center)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AirQualityView(airQualityModelView: AirQualityModelView())
    }
}
