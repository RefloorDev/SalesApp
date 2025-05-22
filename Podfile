# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Refloor' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Refloor

pod 'DropDown', '2.3.2'
pod 'SDWebImage/WebP', '~> 4.4.1'
pod 'SVProgressHUD'
pod 'IQKeyboardManagerSwift', '6.1.1'
pod 'Alamofire', '4.7.3'
pod 'AlamofireObjectMapper', '5.1.0'
pod 'MaterialShowcase'
pod 'PayCardsRecognizer'
pod 'CHRTextFieldFormatter'
pod 'GoogleMaps'
pod 'GooglePlaces'
pod 'RealmSwift', '10.46.0'
pod 'ObjectMapper+Realm'
pod 'FirebaseAnalytics'
pod 'FirebaseAuth'
pod 'FirebaseFirestore'
pod 'Firebase/Messaging'
pod 'JWTCodable'
pod 'SwiftJWT'
pod 'Firebase/Crashlytics'
pod 'Zip'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
