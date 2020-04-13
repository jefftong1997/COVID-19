//
//  CountryDecode.swift
//  COVID-19
//
//  Created by Jeff Tong on 12/4/20.
//  Copyright © 2020 Jeff Tong. All rights reserved.
//

import Foundation

struct CountryDecode: Decodable {
    let Countries: [Country]
}

struct Country: Decodable {
    let Country: String
    let NewConfirmed: Int
    let TotalConfirmed: Int
    let TotalDeaths: Int
    let TotalRecovered: Int
}
