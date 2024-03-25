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

// MARK: - Wrather for the day
final class WeatherForecast: Decodable, WeatherForecastProtocol {
    var _date: Date?
    var _temperature: Double?
    var _weather: [Weather]?
    
    var date: Date? {
        return _date
    }
    
    var temperature: String? {
        if let tempKelvin = _temperature {
            let tempCelsius = tempKelvin - Double(kelvin)
            return "\(Int(tempCelsius))"
        }
        return nil
    }
    
    var weather: [Weather]? {
        return _weather
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case _temperature = "temp"
        case _weather = "weather"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let date = try container.decode(Double.self, forKey: .date)
        self._date = Date(timeIntervalSince1970: date)
        self._temperature = try? container.decode(Double.self, forKey: ._temperature)
        self._weather = try? container.decode([Weather].self, forKey: ._weather)
    }
}

// MARK: - Wrather for the day
final class FutureForecast: Decodable, WeatherForecastProtocol {
    var _date: Date?
    var _temperature: Float?
    var _weather: [Weather]?
    
    var date: Date? {
        return _date
    }
    
    var temperature: String? {
        if let kelvinTemperature = _temperature {
            return Int(kelvin + kelvinTemperature).description
        }
        return nil
    }
    
    var weather: [Weather]? {
        return _weather
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case tempereture = "temp"
        case weather
    }
    
    struct Temperature: Decodable {
        let max: Float?
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let date = try container.decode(Double.self, forKey: .date)
        self._date = Date(timeIntervalSince1970: date)
        let temp = try container.decode(Temperature.self, forKey: .tempereture)
        self._temperature = temp.max
        self._weather = try container.decode([Weather].self, forKey: .weather)
    }
}


struct WeatherMainCast: Decodable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let timezone, id: Int
    let name: String
    let cod: Int


    // MARK: - Clouds
    struct Clouds: Codable {
        let all: Int
    }

    // MARK: - Coord
    struct Coord: Codable {
        let lon, lat: Double
    }

    struct Main: Codable {
        let temp, feelsLike, tempMin, tempMax: Double
        let pressure, humidity: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure, humidity
        }
    }

    struct Weather: Codable {
        let id: Int
        let main, description, icon: String
    }

    // MARK: - Wind
    struct Wind: Codable {
        let speed: Double
        let deg: Int
        let gust: Double
    }



}


// MARK: - Weather for city
struct WeatherForCity: Decodable {
    var lattitude: Float!
    var longitude: Float!
    var city: String!
    var current: WeatherForecast!
    var weather: [Weather]
    var weeklyForecast: [FutureForecast]!

    enum CodingKeys: String, CodingKey {
        case coord
        case current
        case weeklyForecast
        case weather
        case city = "name"
    }
    
    enum CoordKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
    
    struct MainWeatherData: Decodable {
        var temp: Float
        var feelsLike: Float
        var tempMin: Float
        var tempMax: Float
        var pressure: Int
        var humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }
    
    struct Wind: Decodable {
        let speed: Double
        let deg: Int
        let gust: Double
    }
    
    
    public init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordContainer = try container.nestedContainer(keyedBy: CoordKeys.self, forKey: .coord)
        self.lattitude = try coordContainer.decode(Float.self, forKey: .latitude)
        self.longitude = try coordContainer.decode(Float.self, forKey: .longitude)
        self.city = try container.decode(String.self, forKey: .city)
        self.weather = try container.decode([Weather].self, forKey: .weather)
        
        getCity(&self.city)
    }
}

// MARK: - Get city name
private func getCity(_ timezoneOffset: inout String) {
    let separatedTimeZone = timezoneOffset.split(separator: "/")
    //timezoneOffset = separatedTimeZone[1].description
}


