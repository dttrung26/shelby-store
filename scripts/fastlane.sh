#!/bin/bash
set -e
ROOT_DIR=$(pwd)
DIR_IOS="$ROOT_DIR/ios"
DIR_ANDROID="$ROOT_DIR/android"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

textRed(){
    printf "${RED}$*${NC}"
}

textGreen(){
    printf "${GREEN}$*${NC}"
}

textYellow(){
    printf "${YELLOW}$*${NC}"
}

textBlue(){
    printf "${BLUE}$*${NC}"
}

usage() {
    if [ "$*" != "" ] ; then
        textRed "Error: $* \n\n"
    fi
textEL(){
    echo "\t$*"
}

textGreen "Usage: bash fastlane.sh <options>\n\n"
    
 
textYellow "Script build and upload to Firebase or Store with Fastlane.\n"

textBlue "Options: \n\n"
textYellow "-h,--help"     
textEL "display this usage message and exit"

textYellow "--all"           
textEL "\tBuild android and ios, then upload them to Firebase and Store (Anroid is alpla test, Ios is Testflight)"
textYellow "--all-dev"       
textEL "Build android and ios, then upload them to Firebase"
textYellow "--all-prod"      
textEL "Build android and ios, then upload them to Store (Anroid is alpla test, Ios is Testflight)"
textYellow "--ios"           
textEL "\tOnly build iOS, then upload them to Firebase and TestFlight"
textYellow "--ios-dev"       
textEL "Only build iOS, then upload them to Firebase"
textYellow "--ios-prod"      
textEL "Only build iOS, then upload them to TestFlight"
textYellow "--android"       
textEL "Only build Android, then upload them to Firebase and Play Store (alpha test)"
textYellow "--android-dev"   
textEL "Only build Android, then upload them to Firebase  "
textYellow "--android-prod"  
textEL "Only build Android, then upload them to Play Store (alpha test)\n"
    exit 1
}


cleanAll(){
    echo "[Start] clean ..."  
    flutter clean
    rm -rf macos/Pods
    rm -rf ios/Pods
    rm -f macos/Podfile.lock
    rm -f ios/Podfile.lock
    rm -f pubspec.lock
    echo "=>> Clean DONE!\n"  
}

buildIOS(){  
    echo "[Start] build IOS ..."  
    flutter build ios
    echo "=>> Build IOS completed\n"  
}

buildAndroid(){
    echo "[Start] build ANDROID ..."  
    flutter build apk
    echo "=>> Build ANDROID completed\n"  
}


buildAll(){
    echo "[Start] build ALL ..."  
    cleanAll
    buildAndroid
    buildIOS
    echo "=>> DONE build ALL \n"  
}

uploadFirebaseAndroid(){
    echo "[Start] upload Android to Firebase";  
    cd $DIR_ANDROID
    bundle exec fastlane android upload_to_firebase 
    echo "=>> Upload Android to Firebase DONE! \n";  
}

uploadStoreAndroid(){
    echo "[Start] upload Android to Play Store";  
    bundle exec fastlane android upload_to_firebase 
    echo "=>>  Upload Android to Play Store DONE! \n";  
}

uploadFirebaseIOS(){
    echo "[Start] upload Ios to Firebase";  
    cd $DIR_IOS
    bundle exec fastlane ios upload_to_firebase 
    echo "=>> Upload Ios to Firebase DONE! \n";  
}

uploadStoreIOS(){
    echo "[Start] upload Ios to TestFlight";  
    cd $DIR_IOS
    echo "Sorry, features are under development"
    echo "=>>  Upload Ios to TestFlight DONE \n!"; 
}

uploadAllIOS(){
    uploadFirebaseIOS
    uploadStoreIOS
}

uploadAllAndroid(){
    uploadFirebaseAndroid
    uploadStoreAndroid
}

uploadAll(){
    uploadAllAndroid
    uploadAllIOS
}
uploadAllDev(){
    uploadFirebaseAndroid
    uploadFirebaseIOS
}

uploadAllProd(){
    uploadStoreAndroid
    uploadStoreIOS
}

if [ -z "$1" ] ; then 
    usage "missing an argument"
fi


while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    --all)
        buildAll
        uploadAll
        shift
        ;;
    --all-dev)
        buildAll
        uploadAllDev
        shift
        ;;
    --all-prod)
        buildAll
        uploadAllProd
        shift
        ;;
    --ios-dev)
        cleanAll
        buildIOS
        uploadFirebaseIOS
        shift
        ;;
    --ios-prod)
        cleanAll
        buildIOS
        uploadStoreIOS
        shift
        ;;
    --ios)
        cleanAll
        buildIOS
        uploadFirebaseIOS
        uploadStoreIOS
        shift
        ;;
    --android-dev)
        cleanAll
        buildAndroid
        uploadFirebaseAndroid
        shift
        ;;
    --android-prod)
        cleanAll
        buildAndroid
        uploadStoreAndroid
        shift
        ;;
    --android)
        cleanAll
        buildAndroid
        uploadAllAndroid
        shift
        ;;
    -*)
        usage "Unknown option '$1'"
        shift
        ;;
    *)
        usage "Too many arguments"
      ;;
    esac
    shift
done

