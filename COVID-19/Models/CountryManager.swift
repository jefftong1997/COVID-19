//
//  CountryManager.swift
//  COVID-19
//
//  Created by Jeff Tong on 12/4/20.
//  Copyright © 2020 Jeff Tong. All rights reserved.
//

import Foundation

protocol CountryManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdateCountry(_ countryManager: CountryManager, countryStats: CountryModel)
}

struct CountryManager {
    let url = URL(string: "https://api.covid19api.com/summary")
    
    var delegate: CountryManagerDelegate?
    
    func getStats(with country: String) {
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url!) { (data, response, error) in
            if let safeError = error {
                self.delegate?.didFailWithError(error: safeError)
                return
            }
            
            if let safeData = data {
                if let countryStats = self.parseJSON(safeData, country: country) {
                    self.delegate?.didUpdateCountry(self, countryStats: countryStats)
                }
            }
        }
        
        task.resume()
    }
    
    func parseJSON(_ data: Data, country: String) -> CountryModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CountryDecode.self, from: data)
            if let index = decodedData.Countries.firstIndex(where: { $0.Country.contains(country) }) {
                let countryData = decodedData.Countries[index]
                let countryStats = CountryModel(country: country,
                                                totalConfirmed: countryData.TotalConfirmed,
                                                newConfirmed: countryData.NewConfirmed,
                                                totalRecovered: countryData.TotalRecovered,
                                                totalDeaths: countryData.TotalDeaths)
                return countryStats
            } else {
                return nil
            }
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
