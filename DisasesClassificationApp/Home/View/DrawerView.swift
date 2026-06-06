//
//  DrawerView.swift
//  DisasesClassificationApp
//
//  Created by fahim on 20/5/26.
//

import SwiftUI

struct DrawerView: View {
    @StateObject private var viewModel = DrawerViewModel()
    
    // Brand colors based on the screenshot
    private let brandGreen = Color(red: 0.35, green: 0.69, blue: 0.46) // Approximate green from image header
    private let textDark = Color(red: 0.1, green: 0.1, blue: 0.1)
    private let iconGreen = Color(red: 0.29, green: 0.62, blue: 0.44)
    private let backgroundLight = Color(red: 0.96, green: 0.98, blue: 0.96) // Slightly greenish-white background
    
    var body: some View {
        ZStack(alignment: .top){
            // Header Section
            VStack{
                VStack(alignment: .leading, spacing: 10) {
                    // Logo placeholder
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
                    .padding(.top, 40) // Status bar padding approximation if ignoring safe area
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
                        // Top Menu Items
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(viewModel.topMenuItems) { item in
                                menuItemRow(item: item)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)
                        
                        // Bottom Menu Items
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(viewModel.bottomMenuItems) { item in
                                menuItemRow(item: item)
                            }
                        }
                        // Logout Section
                        Button {
                            viewModel.logout()
                        } label: {
                            HStack(spacing: 20) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                
                                Text("Logout")
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
        .edgesIgnoringSafeArea(.top) // To make the green header touch the very top
    }
    
    // MARK: - Menu Item View
    private func menuItemRow(item: DrawerMenuItem) -> some View {
        Button(action: {
            // Coordinator navigation action could go here
        }) {
            HStack(spacing: 20) {
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconGreen)
                    .frame(width: 30) // Fixed width to align text
                
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
