flutter build apk
flutter build ios
rm -rf build/export
mkdir -p build/export
cp build/app/outputs/apk/release/app-release.apk build/export
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -sdk iphoneos -configuration Release archive -archivePath $PWD/build/Runner.xcarchive
xcodebuild -exportArchive -archivePath $PWD/build/Runner.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath $PWD/build/Runner.ipa -allowProvisioningUpdates
cd ..
cp ios/build/Runner.ipa/fstore.ipa build/export
open build/export