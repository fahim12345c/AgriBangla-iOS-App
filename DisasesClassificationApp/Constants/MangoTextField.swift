//
//  Constants.swift
//  DisasesClassificationApp
//
//  Created by fahim on 4/5/26.
//

import SwiftUI

// MARK: - MangoTextField
struct MangoTextField: View {
    let placeholder: String
    let systemImage: String
    @Binding var text: String
    var errorMessage: String? = nil
    var isSecure: Bool = false
    var isRevealed: Bool = false
    var toggleReveal: (() -> Void)? = nil
    var onEditingChanged: ((Bool) -> Void)? = nil
 
    @FocusState private var isFocused: Bool
 
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(iconColor)
                    .frame(width: 20)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
 
                Group {
                    if isSecure && !isRevealed {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .keyboardType(placeholder.lowercased().contains("email") ? .emailAddress : .default)
                    }
                }
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .focused($isFocused)
                .onChange(of: isFocused) { focused in
                    onEditingChanged?(focused)
                }
 
                if isSecure {
                    Button(action: { toggleReveal?() }) {
                        Image(systemName: isRevealed ? "eye" : "eye.slash")
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: shadowColor, radius: isFocused ? 6 : 2, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(borderColor, lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.25), value: isFocused)
            .animation(.easeInOut(duration: 0.25), value: errorMessage)
 
            if let error = errorMessage, !error.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(error)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.red)
                .padding(.horizontal, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3), value: errorMessage)
    }
 
    private var borderColor: Color {
        if let error = errorMessage, !error.isEmpty { return .red.opacity(0.7) }
        if isFocused { return MangoTheme.primaryOrange.opacity(0.8) }
        return Color.gray.opacity(0.2)
    }
 
    private var shadowColor: Color {
        if let error = errorMessage, !error.isEmpty { return .red.opacity(0.1) }
        if isFocused { return MangoTheme.primaryOrange.opacity(0.15) }
        return .black.opacity(0.05)
    }
 
    private var iconColor: Color {
        if let error = errorMessage, !error.isEmpty { return .red.opacity(0.7) }
        if isFocused { return MangoTheme.primaryOrange }
        return .gray.opacity(0.5)
    }
}
 
// MARK: - Password Strength
enum PasswordStrength: Equatable {
    case none, weak, fair, good, strong
 
    var label: String {
        switch self {
        case .none:   return ""
        case .weak:   return "Weak"
        case .fair:   return "Fair"
        case .good:   return "Good"
        case .strong: return "Strong"
        }
    }
 
    var filledSegments: Int {
        switch self {
        case .none:   return 0
        case .weak:   return 1
        case .fair:   return 2
        case .good:   return 3
        case .strong: return 4
        }
    }
}
 
// MARK: - Password Strength Bar View
struct PasswordStrengthBar: View {
    let strength: PasswordStrength
    private let totalSegments = 4
 
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                ForEach(0..<totalSegments, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < strength.filledSegments ? segmentColor : Color.gray.opacity(0.2))
                        .frame(height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(Double(index) * 0.05), value: strength.filledSegments)
                }
            }
            if strength != .none {
                Text("Password strength: \(strength.label)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(segmentColor)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: strength.filledSegments)
    }
 
    private var segmentColor: Color {
        switch strength {
        case .none:   return .clear
        case .weak:   return .red
        case .fair:   return .orange
        case .good:   return .yellow
        case .strong: return .green
        }
    }
}
 
// MARK: - Mango Theme
enum MangoTheme {
    static let primaryOrange  = Color(red: 1.0, green: 0.55, blue: 0.0)
    static let accentYellow   = Color(red: 1.0, green: 0.75, blue: 0.1)
    static let gradientStart  = Color(red: 1.0, green: 0.60, blue: 0.15)
    static let gradientEnd    = Color(red: 0.95, green: 0.38, blue: 0.0)
    static let background     = Color(red: 0.97, green: 0.97, blue: 0.97)
 
    static var headerGradient: LinearGradient {
        LinearGradient(
            colors: [gradientStart, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
