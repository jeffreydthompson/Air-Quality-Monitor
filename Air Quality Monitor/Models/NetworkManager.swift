//
//  NetworkManager.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import Foundation
import Combine
import CoreLocation



struct NetworkManager {
    
    enum NetworkError: Error {
        case BadURL
        case NilData
        case SearchAreaOutOfRange
    }
    
    private static var cancellable: AnyCancellable?
    
    public static func fetchAqiCNMeasurements(location: CLLocationCoordinate2D, completion: @escaping (Result<AqiCNMeasurements,Error>) -> Void) {
        //example url: https://api.waqi.info/feed/geo:37.787;-122.4/?token=e97369c464a2e75b9f3d79e2007dffe64d793cbf
        
        let route = "feed/geo:\(location.latitude);\(location.longitude)/"
        guard var urlComponents = URLComponents(string: aqiCNServer+route) else {
            completion(.failure(NetworkError.BadURL))
            return
        }
        
        urlComponents.queryItems = [URLQueryItem(name: "token", value: aqicnToken)] // token in gitignored file.
        guard urlComponents.url != nil else { completion(.failure(NetworkError.BadURL)); return }
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: AqiCNMeasurements.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { receiveCompletion in
                switch receiveCompletion {
                case .failure(let error):
                    completion(.failure(error))
                    break
                case .finished:
                    break
                }
            }, receiveValue: { receiveValue in
                completion(.success(receiveValue))
            })
        
    }

    public static func fetchOpenAQMeasurements(location: CLLocationCoordinate2D, searchRadiusInMeters: Int, daysIntoThePast: Int, completion: @escaping (Result<OpenAQMeasurements,Error>) -> Void) {
        
        guard (0...100000).contains(searchRadiusInMeters) else {
            completion(.failure(NetworkError.SearchAreaOutOfRange))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let nearestDate = Date(timeIntervalSinceNow: -24*60*60*Double(daysIntoThePast))
        let furthestDate = Date(timeIntervalSinceNow: -24*60*60*Double(daysIntoThePast+1))

        let parameters: Dictionary<String, String> = [
            "page":"1",
            "offset":"0",
            "sort":"desc",
            "date_from":dateFormatter.string(from: furthestDate),
            "date_to":dateFormatter.string(from: nearestDate),
            "coordinates":"\(String(format: "%.3f",location.latitude)),\(String(format: "%.3f",location.longitude))",
            "radius":"\(searchRadiusInMeters)",
            "sensorType":"reference grade",
            "limit":"100",
            "order_by":"datetime"
        ]
        
        let route = "v2/measurements"
        guard var urlComponents = URLComponents(string: openAQServer+route) else {
            completion(.failure(NetworkError.BadURL))
            return
        }
        
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard urlComponents.url != nil else {
            completion(.failure(NetworkError.BadURL))
            return
        }
        
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        
        cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: OpenAQMeasurements.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { receiveCompletion in
                switch receiveCompletion {
                case .failure(let error):
                    print("receive error")
                    completion(.failure(error))
                default:
                    break
                }
            }, receiveValue: { receiveValue in
                completion(.success(receiveValue))
            })
    }
}
