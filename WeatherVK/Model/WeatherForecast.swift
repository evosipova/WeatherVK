//
//  WeatherForecast.swift
//  WeatherVK
//
//  Created by Elizaveta Osipova on 3/24/24.


import Foundation

fileprivate let kelvin: Float = -273.15

struct Weather: Decodable {
    let main: String
    let description: String
    let icon: String
}

protocol WeatherForecastProtocol {
    var date: Date? { get }
    var temperature: String? { get }
    var weather: [Weather]? { get }
}

struct WeatherMainCast: Decodable {
    let coord: Coord
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let name: String

    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }

    struct Main: Codable {
        let temp: Double
        let humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case humidity
        }
    }

    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }

    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
    }
}
