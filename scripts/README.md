

## Use script fastlane
Usage: bash fastlane.sh <options>

Script build and upload to Firebase or Store with Fastlane.
Options: 

-h,--help       display this usage message and exit
--all           Build android and ios, then upload them to Firebase and Store (Anroid is alpla test, Ios is Testflight)
--all-dev       Build android and ios, then upload them to Firebase
--all-prod      Build android and ios, then upload them to Store (Anroid is alpla test, Ios is Testflight)
--ios           Only build iOS, then upload them to Firebase and TestFlight
--ios-dev       Only build iOS, then upload them to Firebase
--ios-prod      Only build iOS, then upload them to TestFlight
--android       Only build Android, then upload them to Firebase and Play Store (alpha test)
--android-dev   Only build Android, then upload them to Firebase  
--android-prod  Only build Android, then upload them to Play Store (alpha test)