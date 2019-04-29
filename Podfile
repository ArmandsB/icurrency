# Uncomment the next line to define a global platform for your project

platform :ios, '12.2'
# ignore all warnings from all pods
use_frameworks!
inhibit_all_warnings!

def common_pods
  pod 'SnapKit', '~> 5.0.0'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'Action'
  pod 'SwiftLint', :configurations => ['Debug']
end

target 'iCurrency' do
  common_pods
end

target 'iCurrencyTests' do
  inherit! :search_paths
  common_pods
  pod 'iOSSnapshotTestCase'
  pod 'RxTest'
  pod 'RxBlocking'
end
