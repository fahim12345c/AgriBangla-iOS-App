//
//  MenuItem.swift
//  DisasesClassificationApp
//
//  Created by fahim on 20/5/26.
//

import SwiftUI

struct MenuItem: View {
    let icon: String
        let title: String
        
        var body: some View {
            HStack(spacing: 15) {
                Image(systemName: icon)
                Text(title)
                    .font(.headline)
            }
        }
}

