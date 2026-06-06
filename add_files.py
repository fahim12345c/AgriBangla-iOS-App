import sys
from pbxproj import XcodeProject

try:
    project = XcodeProject.load('DisasesClassificationApp.xcodeproj/project.pbxproj')
    project.add_file('DisasesClassificationApp/Authentication/Manager/FirestoreManager.swift', force=False, target_name='DisasesClassificationApp')
    project.add_file('DisasesClassificationApp/Authentication/Model/UserModel.swift', force=False, target_name='DisasesClassificationApp')
    project.save()
    print("Successfully added files to Xcode project.")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
