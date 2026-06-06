import Foundation
import Combine
import UIKit

@MainActor
final class CreatePostViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var selectedImage: UIImage?

    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func clearImage() {
        selectedImage = nil
    }
}
