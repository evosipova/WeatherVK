//
//  WeatherCell.swift
//  WeatherVK
//
//  Created by Elizaveta Osipova on 3/24/24.
//

import UIKit

final class WeatherCell: UICollectionViewCell {

    // MARK: - Properties
    private var cityLabel: UILabel?
    private var temperatureLabel: UILabel?
    private var windSpeedLabel: UILabel?
    private var humidityLabel: UILabel?
    private var temperatureImageView = UIView()
    static let identifire = "weathercell"

    // MARK: - WeatherCell init
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 20
        self.backgroundColor = .white
        self.layer.borderColor = UIColor(named: "border")?.cgColor
        self.layer.borderWidth = 3

        configureTemperatureImageView()
        reset()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(city: CityWeather) {
        cityLabel = createLabel(text: city.city, font: .monospacedDigitSystemFont(ofSize: 30, weight: UIFont.Weight.light))
        configureCityLabel(label: cityLabel)

        let temperature = Int(city.tmp).description
        temperatureLabel = createLabel(text: temperature + "°C", font: .monospacedSystemFont(ofSize: 30, weight: UIFont.Weight.medium))
        configureTemperatureLabel(label: temperatureLabel)

        let windSpeed = Int(city.speed).description
        windSpeedLabel = createLabel(text: windSpeed + "m/s", font: .monospacedSystemFont(ofSize: 20, weight: UIFont.Weight.medium))
        configureWindSpeedLabel(label: windSpeedLabel)


        let humidity = Int(city.humidity).description
        humidityLabel =  createLabel(text: humidity + "%", font: .monospacedSystemFont(ofSize: 20, weight: UIFont.Weight.medium))
        configureHumidityLabel(label: humidityLabel)

        if let iconImg = city.icon, let image = UIImage(named: iconImg) {
            temperatureImageView.backgroundColor = UIColor(patternImage: image)
        }

    }

    private func createLabel(text: String?, font: UIFont) -> UILabel {
        let label = UILabel()
        addSubview(label)

        if let text = text {
            label.text = text
        }

        label.font = font
        label.textColor = UIColor(named: "border")
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true

        return label
    }

    // MARK: - Configuretion
    private func configureCityLabel(label: UILabel?) {
        if let label = label {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            label.widthAnchor.constraint(equalToConstant: self.frame.width/2).isActive = true
        }
    }

    private func configureTemperatureLabel(label: UILabel?) {
        if let label = label {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -45).isActive = true
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
            label.widthAnchor.constraint(equalToConstant: self.frame.width/4).isActive = true
        }
    }

    private func configureWindSpeedLabel(label: UILabel?) {
        if let label = label {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -45).isActive = true
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -30).isActive = true
            label.widthAnchor.constraint(equalToConstant: self.frame.width/4).isActive = true
        }
    }

    private func configureHumidityLabel(label: UILabel?) {
        if let label = label {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -45).isActive = true
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            label.widthAnchor.constraint(equalToConstant: self.frame.width/4).isActive = true
        }
    }

    private func configureTemperatureImageView() {
        addSubview(temperatureImageView)
        if let image =  UIImage(named: "weatherCells") {
            temperatureImageView.backgroundColor = UIColor(patternImage: image)
        }

        temperatureImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        temperatureImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
        temperatureImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        temperatureImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true

    }

    // MARK: - PrepareForUse
    override func prepareForReuse() {
        super.prepareForReuse()
        self.reset()
    }

    func reset() {
        if let image =  UIImage(named: "backGroundImages") {
            self.cityLabel?.removeFromSuperview()
            self.temperatureLabel?.removeFromSuperview()
            self.windSpeedLabel?.removeFromSuperview()
            self.humidityLabel?.removeFromSuperview()
            self.backgroundColor = UIColor(patternImage: image)
        }
    }
}
