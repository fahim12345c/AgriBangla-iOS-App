//
//  DrawerView.swift
//  DisasesClassificationApp
//
//  Created by fahim on 20/5/26.
//

import SwiftUI

struct DrawerView: View {
    @StateObject private var viewModel = DrawerViewModel()
    @StateObject private var langManager = LocalizationManager.shared
    var onNavigate: ((DrawerDestination) -> Void)?
    @State private var showLanguagePicker = false

    private let brandGreen = Color(red: 0.35, green: 0.69, blue: 0.46)
    private let textDark = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let iconGreen = Color(red: 0.29, green: 0.62, blue: 0.44)
    private let backgroundLight = Color(red: 0.96, green: 0.98, blue: 0.96)

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                        Image(systemName: "leaf.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(brandGreen)
                            .frame(width: 35, height: 35)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 10)

                    Text(viewModel.userName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(viewModel.userSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(brandGreen)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(viewModel.topMenuItems) { item in
                                menuItemRow(item: item)
                            }
                        }

                        Divider()
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(viewModel.bottomMenuItems) { item in
                                menuItemRow(item: item)
                            }
                        }

                        Button {
                            viewModel.logout()
                        } label: {
                            HStack(spacing: 20) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                                    .frame(width: 30)

                                Text(langManager.localized("drawer_logout"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .padding(.bottom, 100)
                        Spacer()
                    }
                }
                .background(backgroundLight)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .confirmationDialog(langManager.localized("drawer_change_language"), isPresented: $showLanguagePicker) {
            ForEach(LocalizationManager.Language.allCases, id: \.rawValue) { lang in
                Button(lang.displayName) {
                    langManager.setLanguage(lang)
                }
            }
            Button(langManager.localized("general_cancel"), role: .cancel) { }
        } message: {
            Text(langManager.localized("drawer_change_language"))
        }
    }

    private func menuItemRow(item: DrawerMenuItem) -> some View {
        Button(action: {
            if item.destination == .changeLanguage {
                showLanguagePicker = true
            } else {
                onNavigate?(item.destination)
            }
        }) {
            HStack(spacing: 20) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconGreen)
                    .frame(width: 30)

                HStack(spacing: 8) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(textDark)

                    if item.isNew {
                        Text("(NEW)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.red)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    DrawerView()
}
