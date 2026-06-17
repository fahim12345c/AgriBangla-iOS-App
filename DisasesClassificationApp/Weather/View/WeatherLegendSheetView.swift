import SwiftUI

struct WeatherLegendSheetView: View {
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    LegendCard(
                        title: "Humidity",
                        descriptionText: "Amount of moisture in the air.",
                        tip: "Best for spraying: 40–95%. Outside this range spray won't work well.",
                        tint: .blue
                    )
                    LegendCard(
                        title: "Wind",
                        descriptionText: "How fast the wind is blowing.",
                        tip: "Ideal: 3–15 km/h. Too strong = spray drifts. Too calm = spray won't spread.",
                        tint: .teal
                    )
                    LegendCard(
                        title: "Rain",
                        descriptionText: "Rain in the last 1 hour.",
                        tip: "Do not spray if it is raining — chemicals will wash away.",
                        tint: .indigo
                    )
                    LegendCard(
                        title: "Feels Like",
                        descriptionText: "How hot it actually feels on your body.",
                        tip: "Above 38°C — work in morning or evening. Rest at midday.",
                        tint: .orange
                    )
                    LegendCard(
                        title: "Delta T",
                        descriptionText: "Difference between dry and wet air temperature.",
                        tip: "Best: 2–8°C. Higher = spray evaporates. Lower = runoff risk.",
                        tint: .red
                    )
                    LegendCard(
                        title: "Leaf Wetness",
                        descriptionText: "How long water stays on crop leaves.",
                        tip: "Long wetness causes fungal disease (blight, mildew).",
                        tint: .green
                    )
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
        }
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .foregroundStyle(.white)
            Text("Weather Guide")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(brandGreen)
    }
}

private struct LegendCard: View {
    let title: String
    let descriptionText: String
    let tip: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(tint)
                    )
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }

            Text(descriptionText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                    .font(.system(size: 13))
                Text(tip)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.orange.opacity(0.10))
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(tint.opacity(0.12), lineWidth: 1)
                )
        )
    }
}

#Preview {
    WeatherLegendSheetView()
}
