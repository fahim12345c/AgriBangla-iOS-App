import Foundation
import UIKit
import TensorFlowLiteC

final class TFLiteService {
    static let shared = TFLiteService()

    private var interpreter: OpaquePointer?
    private var modelPtr: UnsafeMutableRawPointer?
    private var modelData: Data?
    private var labels: [String] = []
    private var inputType: TfLiteType = kTfLiteFloat32
    private let inputSize: Int = 224

    private init() {}

    func load() throws {
        guard let modelPath = Bundle.main.path(forResource: "plantDiseaseModel", ofType: "tflite") else {
            throw TFLiteError.modelNotFound
        }
        guard let labelPath = Bundle.main.path(forResource: "lables", ofType: "txt") else {
            throw TFLiteError.labelsNotFound
        }

        labels = try String(contentsOfFile: labelPath, encoding: .utf8)
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        modelData = try Data(contentsOf: URL(fileURLWithPath: modelPath))
        modelData!.withUnsafeBytes { modelPtr = UnsafeMutableRawPointer(mutating: $0.baseAddress) }
        guard let modelPtr else { throw TFLiteError.modelNotFound }

        let model = TfLiteModelCreate(modelPtr, modelData!.count)
        guard model != nil else { throw TFLiteError.modelCreationFailed }

        let options = TfLiteInterpreterOptionsCreate()
        TfLiteInterpreterOptionsSetNumThreads(options, 2)

        interpreter = TfLiteInterpreterCreate(model, options)
        TfLiteInterpreterOptionsDelete(options)
        TfLiteModelDelete(model)

        guard let interpreter else { throw TFLiteError.interpreterCreationFailed }
        guard TfLiteInterpreterAllocateTensors(interpreter) == kTfLiteOk else {
            throw TFLiteError.allocationFailed
        }

        guard let inputTensor = TfLiteInterpreterGetInputTensor(interpreter, 0) else {
            throw TFLiteError.inputTensorNotFound
        }
        inputType = TfLiteTensorType(inputTensor)
    }

    func classify(_ image: UIImage) throws -> ClassificationOutput {
        guard let interpreter else { throw TFLiteError.notLoaded }

        guard let resized = resizeImage(image, to: CGSize(width: inputSize, height: inputSize)),
              let cgImage = resized.cgImage else {
            throw TFLiteError.preprocessingFailed
        }

        guard let inputTensor = TfLiteInterpreterGetInputTensor(interpreter, 0) else {
            throw TFLiteError.inputTensorNotFound
        }

        if inputType == kTfLiteUInt8 {
            let pixels = extractUInt8Pixels(from: cgImage)
            guard TfLiteTensorCopyFromBuffer(inputTensor, pixels, pixels.count) == kTfLiteOk else {
                throw TFLiteError.inputCopyFailed
            }
        } else {
            let pixels = extractFloat32Pixels(from: cgImage)
            let byteSize = pixels.count * MemoryLayout<Float32>.size
            var pixelData = pixels
            guard TfLiteTensorCopyFromBuffer(inputTensor, &pixelData, byteSize) == kTfLiteOk else {
                throw TFLiteError.inputCopyFailed
            }
        }

        guard TfLiteInterpreterInvoke(interpreter) == kTfLiteOk else {
            throw TFLiteError.inferenceFailed
        }

        guard let outputTensor = TfLiteInterpreterGetOutputTensor(interpreter, 0) else {
            throw TFLiteError.outputTensorNotFound
        }

        let byteSize = TfLiteTensorByteSize(outputTensor)
        let outputCount = Int(byteSize) / MemoryLayout<Float32>.size
        var outputData = [Float32](repeating: 0, count: outputCount)

        guard TfLiteTensorCopyToBuffer(outputTensor, &outputData, byteSize) == kTfLiteOk else {
            throw TFLiteError.outputCopyFailed
        }

        let labelCount = min(labels.count, outputData.count)
        let indexed = (0..<labelCount).map { (labels[$0], outputData[$0]) }
        let sorted = indexed.sorted { $0.1 > $1.1 }
        let top5 = sorted.prefix(5).map { ClassificationResult(label: $0.0, confidence: $0.1) }

        return ClassificationOutput(
            topResults: top5,
            allLabels: Array(labels.prefix(labelCount)),
            allConfidences: Array(outputData.prefix(labelCount))
        )
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func extractUInt8Pixels(from cgImage: CGImage) -> [UInt8] {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var rgb = [UInt8](repeating: 0, count: width * height * 3)
        for i in 0..<(width * height) {
            rgb[i * 3]     = rawData[i * 4]
            rgb[i * 3 + 1] = rawData[i * 4 + 1]
            rgb[i * 3 + 2] = rawData[i * 4 + 2]
        }
        return rgb
    }

    private func extractFloat32Pixels(from cgImage: CGImage) -> [Float32] {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        )
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var floats = [Float32](repeating: 0, count: width * height * 3)
        for i in 0..<(width * height) {
            floats[i * 3]     = Float32(rawData[i * 4])     / 255.0
            floats[i * 3 + 1] = Float32(rawData[i * 4 + 1]) / 255.0
            floats[i * 3 + 2] = Float32(rawData[i * 4 + 2]) / 255.0
        }
        return floats
    }

    deinit {
        if let interpreter { TfLiteInterpreterDelete(interpreter) }
    }
}

enum TFLiteError: LocalizedError {
    case modelNotFound
    case labelsNotFound
    case modelCreationFailed
    case interpreterCreationFailed
    case allocationFailed
    case preprocessingFailed
    case inputTensorNotFound
    case inputCopyFailed
    case inferenceFailed
    case outputTensorNotFound
    case outputCopyFailed
    case notLoaded

    var errorDescription: String? {
        switch self {
        case .modelNotFound: return "Model file not found. Make sure plantDiseaseModel.tflite is in the app bundle."
        case .labelsNotFound: return "Labels file not found. Make sure lables.txt is in the app bundle."
        case .modelCreationFailed: return "Failed to create TFLite model."
        case .interpreterCreationFailed: return "Failed to create TFLite interpreter."
        case .allocationFailed: return "Failed to allocate tensors."
        case .preprocessingFailed: return "Failed to preprocess image."
        case .inputTensorNotFound: return "Input tensor not found."
        case .inputCopyFailed: return "Failed to copy input data."
        case .inferenceFailed: return "Model inference failed."
        case .outputTensorNotFound: return "Output tensor not found."
        case .outputCopyFailed: return "Failed to get output data."
        case .notLoaded: return "Model not loaded."
        }
    }
}
