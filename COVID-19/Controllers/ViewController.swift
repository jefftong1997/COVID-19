//
//  ViewController.swift
//  COVID-19
//
//  Created by Jeff Tong on 12/4/20.
//  Copyright © 2020 Jeff Tong. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var newConfirmedLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var countryManager = CountryManager()
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        countryManager.delegate = self
        searchTextField.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    @IBAction func onLocationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
}

//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            searchTextField.placeholder = "Type a country"
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let country = searchTextField.text {
            countryManager.getStats(with: country)
        }
        searchTextField.text = ""
        searchTextField.placeholder = "Search"
    }
}

//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let safeError = error {
                    print(safeError)
                } else {
                    if let placemark = placemarks?[0] {
                        if let country = placemark.country {
                            self.countryManager.getStats(with: country)
                        }
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

//MARK: - CountryManagerDelegate

extension ViewController: CountryManagerDelegate {
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdateCountry(_ countryManager: CountryManager, countryStats: CountryModel) {
        DispatchQueue.main.async {
            self.countryLabel.text = countryStats.country
            self.confirmedLabel.text = "Confirmed - \(countryStats.totalConfirmed)"
            self.newConfirmedLabel.text = "New Cases - \(countryStats.newConfirmed)"
            self.recoveredLabel.text = "Recovered - \(countryStats.totalRecovered)"
            self.deathsLabel.text = "Deaths - \(countryStats.totalDeaths)"
        }
    }
}
