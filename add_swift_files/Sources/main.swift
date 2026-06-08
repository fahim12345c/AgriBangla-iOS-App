import Foundation
import XcodeProj
import PathKit

func main() throws {
    let projectPath = Path("/Users/fahim/Developer/project/DiseasesClassificationApp/DisasesClassificationApp.xcodeproj")
    let xcodeproj = try XcodeProj(path: projectPath)
    let pbxproj = xcodeproj.pbxproj
    let sourceRoot = Path("/Users/fahim/Developer/project/DiseasesClassificationApp")

    guard let target = pbxproj.nativeTargets.first(where: { $0.name == "DisasesClassificationApp" }) else {
        print("Target not found")
        exit(1)
    }

    guard let sourcesBuildPhase = try target.sourcesBuildPhase() else {
        print("Sources build phase not found")
        exit(1)
    }

    guard let frameworksBuildPhase = try target.frameworksBuildPhase() else {
        print("Frameworks build phase not found")
        exit(1)
    }

    guard let resourcesBuildPhase = try target.resourcesBuildPhase() else {
        print("Resources build phase not found")
        exit(1)
    }

    let mainGroup = try xcodeproj.pbxproj.rootProject()?.mainGroup

    // Add Swift source files
    let sourceFiles = [
        "DisasesClassificationApp/DiseaseClassification/Model/ClassificationResult.swift",
        "DisasesClassificationApp/DiseaseClassification/Service/TFLiteService.swift",
        "DisasesClassificationApp/DiseaseClassification/Service/DiseaseReportService.swift",
        "DisasesClassificationApp/DiseaseClassification/Utility/PDFGenerator.swift",
        "DisasesClassificationApp/DiseaseClassification/ViewModel/DiseaseClassificationViewModel.swift",
        "DisasesClassificationApp/DiseaseClassification/View/DiseaseClassificationView.swift",
        "DisasesClassificationApp/DiseaseClassification/View/CameraPreview.swift",
    ]

    for file in sourceFiles {
        let filePath = sourceRoot + Path(file)
        if !filePath.exists {
            print("File does not exist: \(filePath)")
            continue
        }

        if let fileRef = try mainGroup?.addFile(at: filePath, sourceRoot: sourceRoot) {
            if !sourcesBuildPhase.files!.contains(where: { $0.file == fileRef }) {
                _ = try sourcesBuildPhase.add(file: fileRef)
                print("Added \(file) to Sources")
            } else {
                print("\(file) already in Sources")
            }
        }
    }

    // Add TensorFlowLiteC.xcframework
    let frameworkPath = sourceRoot + Path("DisasesClassificationApp/Frameworks/TensorFlowLiteC.xcframework")
    if frameworkPath.exists {
        if let frameworkRef = try mainGroup?.addFile(at: frameworkPath, sourceRoot: sourceRoot) {
            if !frameworksBuildPhase.files!.contains(where: { $0.file == frameworkRef }) {
                _ = try frameworksBuildPhase.add(file: frameworkRef)
                print("Added TensorFlowLiteC.xcframework to Frameworks")
            } else {
                print("TensorFlowLiteC.xcframework already in Frameworks")
            }
        }
    } else {
        print("Framework not found at: \(frameworkPath)")
    }

    // Add framework search path
    let searchPath = "$(PROJECT_DIR)/DisasesClassificationApp/Frameworks"
    var buildSettings = target.buildConfigurationList?.buildConfigurations.first?.buildSettings
    if var frameworkSearchPaths = buildSettings?["FRAMEWORK_SEARCH_PATHS"] as? [String] {
        if !frameworkSearchPaths.contains(searchPath) {
            frameworkSearchPaths.append(searchPath)
            buildSettings?["FRAMEWORK_SEARCH_PATHS"] = frameworkSearchPaths
            print("Added framework search path")
        }
    } else {
        buildSettings?["FRAMEWORK_SEARCH_PATHS"] = [searchPath]
        print("Set framework search path")
    }

    // ---- Fix Config.xcconfig ----

    // Find the Config.xcconfig file reference
    let configPath = sourceRoot + Path("Config.xcconfig")
    guard let configFileRef = try mainGroup?.addFile(at: configPath, sourceRoot: sourceRoot) else {
        print("Could not create file reference for Config.xcconfig")
        exit(1)
    }

    // Remove Config.xcconfig from the Resources build phase (it's not a runtime resource)
    if let resourceFiles = resourcesBuildPhase.files {
        for buildFile in resourceFiles {
            if buildFile.file?.uuid == configFileRef.uuid {
                resourcesBuildPhase.files?.removeAll(where: { $0.uuid == buildFile.uuid })
                print("Removed Config.xcconfig from Resources build phase")
                break
            }
        }
    }

    // Assign Config.xcconfig as the base configuration for the PROJECT-level Debug and Release configs
    guard let project = try pbxproj.rootProject() else {
        print("Root project not found")
        exit(1)
    }

    guard let projectBuildConfigList = project.buildConfigurationList else {
        print("Project build configuration list not found")
        exit(1)
    }

    for config in projectBuildConfigList.buildConfigurations {
        config.baseConfiguration = configFileRef
        print("Set Config.xcconfig as base configuration for project '\(config.name)'")
    }

    try xcodeproj.write(path: projectPath)
    print("Project successfully updated.")
}

do {
    try main()
} catch {
    print("Error: \(error)")
    exit(1)
}
