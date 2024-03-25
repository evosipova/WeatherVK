//
//  Networking.swift
//  WeatherVK
//
//  Created by Elizaveta Osipova on 3/24/24.
//

import Foundation
//import Alamofire

protocol ReloadCollectionDelegate {
    func reloadCollectionView()
}

class Networking {

    private let coreDataManager: CoreDataManager!
    var reloadCollectionDelegate: ReloadCollectionDelegate?

    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }

    func getWeatherInfo(url: URL) {
        print(url)
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

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
                    if let _ = self.coreDataManager.getCityWeather(cityName: weather.name ?? "") {
                        self.coreDataManager.updateCity(city: weather)
                    } else {
                        self.coreDataManager.createCity(city: weather)
                    }
                    self.reloadCollectionDelegate?.reloadCollectionView()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }

    func getCurrentrWeatherInfo(url: URL, completion: @escaping (_ city: WeatherForCity) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
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
                let city = try JSONDecoder().decode(WeatherForCity.self, from: data)
                DispatchQueue.main.async {
                    completion(city)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
    }
}
