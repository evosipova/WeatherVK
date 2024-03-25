//
//  ViewController.swift
//  WeatherVK
//
//  Created by Elizaveta Osipova on 3/24/24.
//

import UIKit
//import Alamofire
import CoreLocation

final class ViewController: UIViewController {

    //  MARK: - Constants
    private let stackView = UIStackView()
    private let searchBar = UISearchBar()
    private let coreDataManager = CoreDataManager()
    private let locationManager = CLLocationManager()

    private enum Constants {
        static let backgroundColor = UIColor(named: "dark")
    }

    //  MARK: - Properties
    private var networking: Networking!
    private var currentUserWeather = UserWeather()

    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let tempCV = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return tempCV
    }()

    //  MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        networking = Networking(coreDataManager: coreDataManager)
        networking.reloadCollectionDelegate = self

        view.backgroundColor = Constants.backgroundColor

        configureStackView()
        currentUserWeather.isHidden = true
        addToStackView(view: currentUserWeather, height: 80)
        configureLocation()
        configureSearchBar()
        createWeatherCollectionView()
        fetchWeather()
    }

    //  MARK: - Fetch weather
    private func fetchWeather() {
        if let cities = coreDataManager.getCitiesWeather() {
            for city in cities {
                let url = getURL(lat: city.latitude, lng: city.longitude)
                networking.getWeatherInfo(url: url)
            }
        }
    }

    //  MARK: - Get URL
    private func getURL(lat: Float, lng: Float) -> URL {
        return URL(string: String(
            "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lng)&appid=be2d818c98fc7a2c8da8479d3b15a785&units=metric"))!
    }

    private func configureLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    //  MARK: - Configure stack view
    private func configureStackView() {
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
    }

    //  MARK: - Configure search bar
    private func configureSearchBar() {
        addToStackView(view: searchBar, height: 30)

        searchBar.placeholder = "Enter City"
        searchBar.tintColor = .systemPink
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = UIColor.darkText

        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.resignFirstResponder()
    }

    //  MARK: - Create weather collection view
    private func createWeatherCollectionView() {
        view.addSubview(collectionView)

        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true

        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.identifire)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    //  MARK: - Add to stack view
    private func addToStackView(view: UIView, height: CGFloat) {
        stackView.addArrangedSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    //  MARK: - Get coordinates by name
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
}

//    MARK: - extension UICollectionViewDelegate && UICollectionViewDataSource
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreDataManager.getCitiesWeather()?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCell.identifire, for: indexPath) as! WeatherCell
        cell.set(city: (coreDataManager.getCitiesWeather()![indexPath.row]))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentUserWeather.isHidden = !currentUserWeather.isHidden
    }
}

//    MARK: - extension UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width/4)
    }
}

//    MARK: - extension UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        guard let address = searchBar.text else { return }
        getCoordinateFrom(address: address) { coordinate, error in
            guard let coordinate = coordinate, error == nil else {
                print (error ?? "hi")
                return
            }
            let latitude = Float(coordinate.latitude)
            let longitude = Float(coordinate.longitude)

            let weatherURL = self.getURL(lat: latitude, lng: longitude)
            self.networking.getWeatherInfo(url: weatherURL)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()

    }

    @objc private func dismissKeyboard(){
        view.endEditing(true)
        searchBar.text = nil
    }
}

//  MARK: - extension ReloadCollectionDelegate
extension ViewController: ReloadCollectionDelegate {
    func reloadCollectionView() {
        collectionView.reloadData()
        // TODO: - fix calling it for each element
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                break
            case .authorizedAlways, .authorizedWhenInUse:
                currentUserWeather.isHidden = false
            }
        } else {
            print("Location services are not enabled")
        }
        if !currentUserWeather.isHidden {
            let coordinate = locations.last?.coordinate
            let weatherURL = getURL(lat: Float(coordinate!.latitude), lng: Float(coordinate!.longitude))
            networking.getCurrentrWeatherInfo(url: weatherURL) {city in
                self.currentUserWeather.setup(city: city)
            }
        }
    }
}
