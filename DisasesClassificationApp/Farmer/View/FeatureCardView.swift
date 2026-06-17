//
//  FeatureCardView.swift
//  DisasesClassificationApp
//
//  Created by fahim on 6/5/26.
//
import SwiftUI

// MARK: - FeatureCardView
struct FeatureCardView: View {
    let card: FeatureCard
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon container
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(card.backgroundColor).opacity(0.25))
                        .frame(width: 64, height: 64)

                    Image(systemName: card.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(card.backgroundColor), Color(card.backgroundColor).opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolRenderingMode(.hierarchical)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(card.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color("textPrimary"))
                        .multilineTextAlignment(.leading)

                    Text(card.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color("textSecondary"))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color("cardBackground"))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color(card.backgroundColor).opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
        ForEach(FeatureCard.allCards) { card in
            FeatureCardView(card: card, action: {})
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
