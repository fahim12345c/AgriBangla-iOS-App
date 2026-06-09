import SwiftUI

struct LText: View {
    @ObservedObject private var lm = LocalizationManager.shared
    let key: String

    init(_ key: String) {
        self.key = key
    }

    var body: some View {
        Text(lm.localized(key))
    }
}
