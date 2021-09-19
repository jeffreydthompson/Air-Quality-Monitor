//
//  NetworkManager.swift
//  Air Quality Monitor
//
//  Created by Jeffrey Thompson on 9/17/21.
//

import Foundation
import Combine
import CoreLocation

let openAQServer = "https://u50g7n0cbj.execute-api.us-east-1.amazonaws.com/"
let aqiCNServer = "https://api.waqi.info/"

struct NetworkManager {
    
    enum NetworkError: Error {
        case BadURL
        case NilData
        case SearchAreaOutOfRange
    }
    
    private static var cancellable: AnyCancellable?

    public static func fetchOpenAQMeasurements(location: CLLocationCoordinate2D, radius: Int, completion: @escaping (Result<OpenAQMeasurements,Error>) -> Void) {
        
        guard (0...100000).contains(radius) else {
            completion(.failure(NetworkError.SearchAreaOutOfRange))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let today = Date()
        let yesterday = Date(timeIntervalSinceNow: -24*60*60)

        let parameters: Dictionary<String, String> = [
            "page":"1",
            "offset":"0",
            "sort":"desc",
            "date_from":dateFormatter.string(from: yesterday),
            "date_to":dateFormatter.string(from: today),
            //"coordinates":"37.3759222,-121.8033345",
            "coordinates":"\(location.latitude),\(location.longitude)",
            "radius":"\(radius)",
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
        
        print(urlComponents.url!)
        
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
