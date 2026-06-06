import SwiftUI

struct WeatherLegendSheetView: View {
    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    LegendCard(
                        title: "আর্দ্রতা · Humidity",
                        descriptionText: "বাতাসে কতটুকু জলীয় বাষ্প আছে তার পরিমাণ।\nAmount of moisture in the air.",
                        tip: "৪০–৯৫% হলে স্প্রে করুন। এর বাইরে হলে কীটনাশক ভালো কাজ করে না।\nBest for spraying: 40–95%. Outside this range spray won't work well.",
                        tint: .blue
                    )
                    LegendCard(
                        title: "বাতাস · Wind",
                        descriptionText: "বাতাস কত জোরে বইছে।\nHow fast the wind is blowing.",
                        tip: "৩–১৫ km/h হলে স্প্রে করুন। বেশি জোরে হলে কীটনাশক উড়ে যাবে। কম হলে ফসলে বসবে না।\nIdeal: 3–15 km/h. Too strong = spray drifts. Too calm = spray won't spread.",
                        tint: .teal
                    )
                    LegendCard(
                        title: "বৃষ্টি · Rain",
                        descriptionText: "গত ১ ঘণ্টায় কতটুকু বৃষ্টি হয়েছে।\nRain in the last 1 hour.",
                        tip: "বৃষ্টি হলে স্প্রে করবেন না — কীটনাশক ধুয়ে যাবে।\nDo not spray if it is raining — chemicals will wash away.",
                        tint: .indigo
                    )
                    LegendCard(
                        title: "গরম অনুভব · Feels Like",
                        descriptionText: "শরীরে কতটা গরম লাগছে সেটার হিসাব।\nHow hot it actually feels on your body.",
                        tip: "৩৮°C এর বেশি হলে সকালে বা বিকালে কাজ করুন। মাঝ দুপুরে বিশ্রাম নিন।\nAbove 38°C — work in morning or evening. Rest at midday.",
                        tint: .orange
                    )
                    LegendCard(
                        title: "গরম-ঠান্ডা ফারাক · Delta T",
                        descriptionText: "শুকনা ও ভেজা তাপমাত্রার পার্থক্য।\nDifference between dry and wet air temperature.",
                        tip: "২–৮°C হলে সবচেয়ে ভালো। বেশি হলে কীটনাশক উড়ে যায়। কম হলে গাছে লাগে না।\nBest: 2–8°C. Higher = spray evaporates. Lower = runoff risk.",
                        tint: .red
                    )
                    LegendCard(
                        title: "পাতার ভেজাভাব · Leaf Wetness",
                        descriptionText: "ফসলের পাতায় পানি কতক্ষণ থাকছে।\nHow long water stays on crop leaves.",
                        tip: "পাতা বেশিক্ষণ ভেজা থাকলে ছত্রাক রোগ হয় (ব্লাইট, মিলডিউ)।\nLong wetness causes fungal disease (blight, mildew).",
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
            Text("আবহাওয়ার ব্যাখ্যা · Weather Guide")
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
