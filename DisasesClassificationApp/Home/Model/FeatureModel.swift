//
//  FeatureModel.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//

import Foundation
struct FeatureCard: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String        // SF Symbol or asset name
    let backgroundColor: String  // asset color name
    let destination: AppDestination
}
 
enum AppDestination {
    case diseaseScanner
    case smartRecommendations
    case community
    case weather
    case profile
}
 
extension FeatureCard {
    static var allCards: [FeatureCard] {
        [
            FeatureCard(
                title: "Disease Scanner",
                subtitle: "Identify plant problems",
                imageName: "leaf.circle.fill",
                backgroundColor: "cardPink",
                destination: .diseaseScanner
            ),
            FeatureCard(
                title: "Smart Recommendations",
                subtitle: "AI-powered crop advice",
                imageName: "chart.bar.doc.horizontal.fill",
                backgroundColor: "cardBlue",
                destination: .smartRecommendations
            ),
            FeatureCard(
                title: "Community",
                subtitle: "Connect with farmers",
                imageName: "person.3.fill",
                backgroundColor: "cardGreen",
                destination: .community
            ),
            FeatureCard(
                title: "Weather Forecast",
                subtitle: "7-day prediction",
                imageName: "cloud.sun.fill",
                backgroundColor: "cardYellow",
                destination: .weather
            ),
        ]
    }
}
