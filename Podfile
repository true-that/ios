platform :ios, '10.0'

target 'TrueThat' do
  use_frameworks!
  pod 'Alamofire', '~> 4.4'
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
  
  target 'TrueThatUITests' do
    inherit! :search_paths
    pod 'Nimble', '~> 7.0.1', :inhibit_warnings => true
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
  end
end
