//
//  CoreDataManager.swift
//  WeatherVK
//
//  Created by Elizaveta Osipova on 3/24/24.
//

import CoreData
import Foundation

// MARK: - Core data manager
final class CoreDataManager {

    //
    // MARK: - Constants
    static let shared = CoreDataManager()

    private enum EntityKeys {
        static let cityWeatherName = "CityWeather"
        static let dailyWeatherName = "DailyWeather"
    }

    // MARK: - Properties
    private var Context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherBD")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading store failed \(error)")
            }
        }
        return container
    }()



    // MARK: - Has saved weather
    func hasWeather() -> Bool {
        return getCitiesWeather() != nil
    }

    // MARK: - Get cities weather
    func getCitiesWeather() -> [CityWeather]? {

        let fetchRequest = NSFetchRequest<CityWeather>(entityName: EntityKeys.cityWeatherName)

        do {
            let cities = try Context.fetch(fetchRequest)
            return cities
        } catch {
            print("Failed to get cities: \(error)")
        }
        return nil
    }

    // MARK: - Get weather for city
    func getCityWeather(cityName: String) -> CityWeather? {
        let fetchRequest = NSFetchRequest<CityWeather>(entityName: EntityKeys.cityWeatherName)
        //fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "city == %@", cityName)

        do {
            let cities = try Context.fetch(fetchRequest)
            return cities.first
        } catch {
            print("Failed to get city: \(error)")
        }
        return nil
    }

    // MARK: - Get future forecast
    func getFutureForecast(city: CityWeather) -> [DailyWeather]? {
        return city.futureForecast?.allObjects as? [DailyWeather]
    }

    // MARK: - Get current forecast
    func getCurrentForecast(city: CityWeather) -> DailyWeather? {
        return city.currentForecast
    }

    // MARK: - Create city
    func createCity(city: WeatherMainCast) {
        let context = persistentContainer.viewContext
        let cityWeather = NSEntityDescription.insertNewObject(forEntityName: EntityKeys.cityWeatherName, into: context) as! CityWeather
        cityWeather.city = city.name
        cityWeather.longitude = Float(city.coord.lon)
        cityWeather.latitude = Float(city.coord.lat)
        cityWeather.tmp = Float(city.main.temp)
        cityWeather.icon = city.weather.first?.icon
//        cityWeather.currentForecast = createWeather(city.)
//        cityWeather.futureForecast = createFutureWeather((city.weeklyForecast)!)

        do {
            try context.save()
        } catch {
            print("Failed to create person: \(error)")
        }
    }

    // MARK: - Create weather
    func createWeather(_ weather: WeatherForecastProtocol) -> DailyWeather? {
        let context = Context

        let current = NSEntityDescription.insertNewObject(forEntityName: EntityKeys.dailyWeatherName, into: context) as! DailyWeather
        current.weather = weather.weather?[0].main
        current.tempreture = Float(weather.temperature!)!
        current.date = weather.date
        current.icon = weather.weather?[0].icon

        do {
            try context.save()
            return current
        } catch {
            print("Failed to create weather: \(error)")
        }
        return nil
    }

    // MARK: - Create weather array
    func createFutureWeather(_ weatherArray: [WeatherForecastProtocol]) -> NSSet? {
        var result: [DailyWeather?] = []
        for weather in weatherArray {
            result.append(createWeather(weather))
        }

        return NSSet(array: result as [Any])
    }


    // MARK: - Update city
    @discardableResult
    func updateCity(city: WeatherMainCast) -> CityWeather? {
        let context = Context
        let fetchRequest = NSFetchRequest<CityWeather>(entityName: EntityKeys.cityWeatherName)
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "city == %@", city.name)

        do {
            let cities = try Context.fetch(fetchRequest)
            cities.first?.city = city.name
            cities.first?.longitude = Float(city.coord.lon)
            cities.first?.latitude = Float(city.coord.lat)
            cities.first?.tmp = Float(city.main.temp)

            cities.first?.icon = city.weather.first?.icon

//            cities.first?.currentForecast = createWeather(city.current)
//            cities.first?.futureForecast = createFutureWeather(city.weeklyForecast)
            try context.save()
            return cities.first
        } catch {
            print("Failed to update city: \(error)")
        }
        return nil
    }

    // MARK: - Update city array
    func updateCities(cities: [WeatherMainCast]) -> [CityWeather]? {
        for city in cities {
            updateCity(city: city)
        }
        return getCitiesWeather()
    }

    // MARK: - Delete city array
    func deleteCities() {
        let context = Context
        if let cities = getCitiesWeather() {
            for city in cities {
                context.delete(city)
            }
            do {
                try context.save()
            } catch {
                print("Failed to delete cities: \(error)")
            }
        }
    }

    // MARK: - Delete city
    func deleteCity(cityName: String) {
        let context = Context
        if let city = getCityWeather(cityName: cityName) {
            context.delete(city)
            do {
                try context.save()
            } catch {
                print("Failed to delete citiy: \(error)")
            }
        }
    }
}
