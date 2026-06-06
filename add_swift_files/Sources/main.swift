import Foundation
import XcodeProj
import PathKit

func main() throws {
    let projectPath = Path("/Users/fahim/Developer/project/DiseasesClassificationApp/DisasesClassificationApp.xcodeproj")
    let xcodeproj = try XcodeProj(path: projectPath)
    let pbxproj = xcodeproj.pbxproj
    let sourceRoot = Path("/Users/fahim/Developer/project/DiseasesClassificationApp")
    
    // Find Target
    guard let target = pbxproj.nativeTargets.first(where: { $0.name == "DisasesClassificationApp" }) else {
        print("Target not found")
        exit(1)
    }
    
    // Find or get Sources build phase
    guard let sourcesBuildPhase = try target.sourcesBuildPhase() else {
        print("Sources build phase not found")
        exit(1)
    }
    
    let filesToAdd = [
        "DisasesClassificationApp/Authentication/Manager/FirestoreManager.swift",
        "DisasesClassificationApp/Authentication/Model/UserModel.swift"
    ]
    
    let mainGroup = try xcodeproj.pbxproj.rootProject()?.mainGroup
    
    for file in filesToAdd {
        let filePath = sourceRoot + Path(file)
        if !filePath.exists {
            print("File does not exist: \(filePath)")
            continue
        }
        
        // Add file reference
        let fileRef = try mainGroup?.addFile(at: filePath, sourceRoot: sourceRoot)
        
        // Add to sources build phase if not already present
        if let fileRef = fileRef {
            if !sourcesBuildPhase.files!.contains(where: { $0.file == fileRef }) {
                _ = try sourcesBuildPhase.add(file: fileRef)
                print("Added \(file) to Sources Build Phase.")
            } else {
                print("\(file) is already in Sources Build Phase.")
            }
        }
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
