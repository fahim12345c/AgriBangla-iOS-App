//
//  WeatherDisplayModel.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//

import Foundation

struct WeatherDisplayModel {
    let temperature: String       // "34°C"
    let tempRange: String         // "30°C / 34°C"
    let description: String       // "Broken clouds"
    let humidity: String          // "72%"
    let windSpeed: String         // "12 km/h"
    let rain: String              // "0.5 mm"  (from WeatherRain.oneHour)
    let icon: String              // SF Symbol name  (was weatherIcon)
    let backgroundColors: [String]// gradient color names
 
    static var placeholder: WeatherDisplayModel {
        WeatherDisplayModel(
            temperature: "--°C",
            tempRange: "--°C / --°C",
            description: "Fetching weather",
            humidity: "--%",
            windSpeed: "-- km/h",
            rain: "0.0 mm",
            icon: "cloud.fill",
            backgroundColors: ["cloudyStart", "cloudyEnd"]
        )
    }
}
