platform :ios, '10.0'

target 'TrueThat' do
  use_frameworks!
  pod 'Alamofire', '~> 4.4'
  pod 'ReactiveCocoa', '~> 6.0'
  pod 'Swinject', '~> 2.1.0'
  pod 'SwiftyBeaver'
  pod 'SwiftyJSON'
  
  target 'TrueThatTests' do
    inherit! :search_paths
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
  end
  
  target 'TrueThatUITests' do
    inherit! :search_paths
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
  end
end
