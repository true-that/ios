platform :ios, '11.0'
use_frameworks!

target 'TrueThat' do
  pod 'AffdexSDK-iOS'
  pod 'Alamofire', '~> 4.4'
  pod 'Appsee'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'KeychainAccess'
  pod 'Kingfisher', '~> 3.0'
  pod 'ReactiveCocoa', '~> 6.0'
  pod 'SwiftyBeaver'
  pod 'SwiftyJSON'
  
  target 'TrueThatTests' do
    inherit! :search_paths
    pod 'KIF'
    pod 'Nimble', '~> 7.0.1', :inhibit_warnings => true
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if (target.name == 'AWSCore') || (target.name == 'AWSKinesis')
      puts target.name
      target.build_configurations.each do |config|
        config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
      end
    end
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.2'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
