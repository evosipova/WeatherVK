//
//  Networking.swift
//  WeatherVK
//
//  Created by Elizaveta Osipova on 3/24/24.
//

import Foundation

protocol ReloadCollectionDelegate {
    func reloadCollectionView()
}

enum NetworkingError: Error {
    case requestFailed(String)
    case responseUnsuccessful
    case invalidData
    case decodingFailure(Error)
}

class Networking {

    private let coreDataManager: CoreDataManager!
    var reloadCollectionDelegate: ReloadCollectionDelegate?

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func getWeatherInfo(url: URL, completion: @escaping (Result<WeatherMainCast, NetworkingError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network request error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("The server returned an error")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let weather = try JSONDecoder().decode(WeatherMainCast.self, from: data)
                DispatchQueue.main.async {

                    if let strongSelf = self {
                        if let _ = strongSelf.coreDataManager.getCityWeather(cityName: weather.name) {
                            strongSelf.coreDataManager.updateCity(city: weather)
                        } else {
                            strongSelf.coreDataManager.createCity(city: weather)
                        }
                        strongSelf.reloadCollectionDelegate?.reloadCollectionView()
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()

    }

    func fetchWeatherInfo(url: URL) {
        getWeatherInfo(url: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    if self?.coreDataManager.getCityWeather(cityName: weather.name) != nil {
                        self?.coreDataManager.updateCity(city: weather)
                    } else {
                        self?.coreDataManager.createCity(city: weather)
                    }
                    self?.reloadCollectionDelegate?.reloadCollectionView()
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }
        }
    }
}
