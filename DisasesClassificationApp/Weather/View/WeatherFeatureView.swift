import SwiftUI

// MARK: - WeatherFeatureView
struct WeatherFeatureView: View {
    @StateObject private var vm = WeatherFeatureViewModel()

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    @State private var isLegendPresented = false

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            if let error = vm.errorMessage {
                errorBanner(error)
            }
            if vm.isLoading {
                loadingState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        currentWeatherCard
                            .padding(.top, 14)
                        modeTabs
                        if vm.mode == .spraying {
                            sprayingContent
                        } else {
                            detailsContent
                        }
                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(red: 0.91, green: 0.96, blue: 0.91).ignoresSafeArea())
        .onAppear { vm.onAppear() }
        .sheet(isPresented: $isLegendPresented) {
            WeatherLegendSheetView()
                .presentationDetents([.large])
        }
    }

    private var loadingState: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("আবহাওয়া তথ্য আনা হচ্ছে...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.white)
            Spacer()
            Button(action: { vm.refresh() }) {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.8))
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack(spacing: 10) {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .accessibilityLabel("Menu")

            VStack(alignment: .leading, spacing: 1) {
                Text("আবহাওয়া · Weather")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Farmer Dashboard")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.70))
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.white.opacity(0.18)))
            }
            .accessibilityLabel("Search")

            Button(action: { vm.refresh() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.white.opacity(0.18)))
            }
            .accessibilityLabel("Refresh")

            Button(action: { isLegendPresented = true }) {
                Image(systemName: "questionmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.white.opacity(0.18)))
            }
            .accessibilityLabel("Help")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(brandGreen.ignoresSafeArea(edges: .top))
    }

    // MARK: - Current Weather Card
    private var currentWeatherCard: some View {
        VStack(spacing: 0) {

            // Main info row
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.green.opacity(0.12))
                    Image(systemName: vm.icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Color.green)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 3) {
                    Text(vm.locationTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(vm.temperatureText)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text(vm.conditionText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }

                    // Simple heat advice line
                    Text(vm.farmerHeatAdvice)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(vm.farmerHeatAdviceColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .padding(16)

            Rectangle()
                .fill(Color(.separator).opacity(0.5))
                .frame(height: 0.5)
                .padding(.horizontal, 16)

            // Quick stats — only humidity, wind, rain
            HStack(spacing: 0) {
                quickStat(icon: "humidity.fill",   value: vm.humidityText, label: "আর্দ্রতা\nHumidity", tint: .blue)
                Divider().frame(height: 36)
                quickStat(icon: "wind",            value: vm.windText,     label: "বাতাস\nWind",         tint: .teal)
                Divider().frame(height: 36)
                quickStat(icon: "cloud.rain.fill", value: vm.rainText,     label: "বৃষ্টি\nRain",        tint: .indigo)
            }
            .padding(.vertical, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 6)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func quickStat(icon: String, value: String, label: String, tint: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Mode Tabs
    private var modeTabs: some View {
        Picker("", selection: $vm.mode) {
            Text("💧 কীটনাশক · Spray").tag(WeatherFeatureViewModel.Mode.spraying)
            Text("📋 বিস্তারিত · Details").tag(WeatherFeatureViewModel.Mode.details)
        }
        .pickerStyle(.segmented)
    }
    // MARK: - Spraying Content
    private var sprayingContent: some View {
        VStack(spacing: 14) {
            applicationTypeCard
            sprayingWindowCard
            smartAdviceCard
        }
    }

    private var applicationTypeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("কী দিচ্ছেন · Application Type", systemImage: "drop.halffull")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach(ApplicationType.allCases) { t in
                    Button { vm.application = t } label: {
                        VStack(spacing: 6) {
                            Image(systemName: vm.application == t ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(vm.application == t ? Color.green : Color.secondary.opacity(0.4))
                            Text(t.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(vm.application == t ? Color.green : Color.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(vm.application == t
                                      ? Color.green.opacity(0.10)
                                      : Color(.secondarySystemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(
                                            vm.application == t ? Color.green.opacity(0.35) : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: vm.application)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private var sprayingWindowCard: some View {
        let status = vm.assessment.status
        return VStack(spacing: 0) {

            // Status banner
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("এখন স্প্রে করা যাবে? · Spray Window")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .kerning(0.3)
                    Text(farmerStatusLabel(status))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(statusColor(status))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: statusIcon(status))
                    .font(.system(size: 36))
                    .foregroundStyle(statusColor(status).opacity(0.85))
            }
            .padding(18)
            .background(statusBackground(status))

            // Wind and Delta T — renamed simply
            HStack(spacing: 0) {
                sprayMetric(
                    label: "গরম-ঠান্ডা ফারাক\nHeat Gap",
                    value: "\(vm.assessment.deltaT.round1)°C",
                    color: .orange
                )
                Divider().frame(height: 40)
                sprayMetric(
                    label: "বাতাসের গতি\nWind Speed",
                    value: "\(vm.assessment.windKmh.round1) km/h",
                    color: .teal
                )
            }
            .padding(.vertical, 14)
            .background(Color(.systemBackground))

            Rectangle()
                .fill(Color(.separator).opacity(0.4))
                .frame(height: 0.5)

            // Summary lines — plain language
            VStack(alignment: .leading, spacing: 10) {
                ForEach(vm.assessment.summaryLines) { line in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: symbol(for: line.level))
                            .foregroundStyle(color(for: line.level))
                            .frame(width: 18)
                        Text(line.text)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 5)
    }

    private func sprayMetric(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    private var smartAdviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.orange)
                Text("পরামর্শ · Advice")
                    .font(.system(size: 16, weight: .bold))
            }

            Text(vm.assessment.adviceTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(vm.assessment.adviceBody)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
        )
    }

    // MARK: - Details Content
    private var detailsContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("এখনকার অবস্থা · Current Conditions", icon: "thermometer.sun.fill")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DetailTile(title: "গরম অনুভব\nFeels Like", value: vm.feelsLikeText, icon: "thermometer",   tint: .orange)
                DetailTile(title: "আর্দ্রতা\nHumidity",    value: vm.humidityText,  icon: "humidity.fill", tint: .blue)
                DetailTile(title: "বাতাস\nWind",           value: vm.windText,      icon: "wind",          tint: .teal)
                DetailTile(title: "বায়ুচাপ\nPressure",    value: vm.pressureText,  icon: "gauge",         tint: .indigo)
            }

            sectionHeader("বৃষ্টিপাত · Precipitation", icon: "cloud.rain.fill")
                .padding(.top, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DetailTile(title: "বৃষ্টি (১ ঘণ্টা)\nRain (1h)", value: vm.rainText,   icon: "cloud.rain.fill", tint: .blue)
                DetailTile(title: "মেঘ\nClouds",                  value: vm.cloudsText, icon: "cloud.fill",      tint: .gray)
            }
        }
        .padding(.top, 2)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(brandGreen)
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Helpers
    private func farmerStatusLabel(_ status: SprayingWindowStatus) -> String {
        switch status {
        case .optimal: return "✓ এখন স্প্রে করুন — Good to spray"
        case .marginal: return "⚠️ সাবধানে করুন — Spray carefully"
        case .poor:    return "✗ এখন করবেন না — Do not spray now"
        }
    }

    private func statusColor(_ status: SprayingWindowStatus) -> Color {
        switch status {
        case .optimal: return .green
        case .marginal: return .orange
        case .poor:    return .red
        }
    }

    private func statusBackground(_ status: SprayingWindowStatus) -> some View {
        let colors: [Color] = {
            switch status {
            case .optimal:  return [Color.green.opacity(0.20),  Color.green.opacity(0.08)]
            case .marginal: return [Color.orange.opacity(0.20), Color.orange.opacity(0.08)]
            case .poor:     return [Color.red.opacity(0.18),    Color.red.opacity(0.06)]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func statusIcon(_ status: SprayingWindowStatus) -> String {
        switch status {
        case .optimal:  return "checkmark.seal.fill"
        case .marginal: return "exclamationmark.triangle.fill"
        case .poor:     return "xmark.octagon.fill"
        }
    }

    private func symbol(for level: SprayingSummaryLine.Level) -> String {
        switch level {
        case .good: return "checkmark.circle.fill"
        case .bad:  return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    private func color(for level: SprayingSummaryLine.Level) -> Color {
        switch level {
        case .good: return .green
        case .bad:  return .red
        case .info: return .blue
        }
    }
}

// MARK: - Double extension
private extension Double {
    var round1: String { String(format: "%.1f", self) }
}

// MARK: - DetailTile
private struct DetailTile: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview {
    WeatherFeatureView()
}
