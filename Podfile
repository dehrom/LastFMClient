# Uncomment the next line to define a global platform for your project
 platform :ios, '12.4'
 inhibit_all_warnings!

 def ui
   pod 'AlamofireImage', '~> 3.5'
   pod 'RxDataSources'
   pod 'SnapKit'
   pod 'SVProgressHUD'
   pod 'RxDataSources'
   pod 'NSObject+Rx'
   pod 'RIBs', '~> 0.9'
 end

 def core
   pod 'RxSwift'
   pod 'RxCocoa', '~> 4.0'
   pod 'RxRealm'
 end

target 'App' do
  use_frameworks!
  pod 'RIBs', '~> 0.9'
end

target 'Main' do
  use_frameworks!
  ui
  core
end

target 'Search' do
  use_frameworks!
  inherit! :search_paths
  
  ui
  core
end

target 'Albums' do
  use_frameworks!
  inherit! :search_paths
  
  ui
  core
end

target 'Detail' do
  use_frameworks!
  inherit! :search_paths
  
  ui
  core
end

target 'RIBsExtensions' do
  use_frameworks!
  inherit! :search_paths
  
  pod 'RIBs', '~> 0.9'
  core
end

target 'Utils' do
  use_frameworks!
  inherit! :search_paths
  
  core
  pod 'RxAlamofire'
  pod 'AlamofireImage', '~> 3.5'
end

target 'ManagedModels' do
  use_frameworks!
  inherit! :search_paths
  
  pod 'RealmSwift'
end

target 'UIComponents' do
  use_frameworks!
  inherit! :search_paths
  
  pod 'RxCocoa', '~> 4.0'
  pod 'RxSwift'
  pod 'SnapKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    
    if !['RIBs', 'RxCocoa'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.1'
      end
    else
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.6'
      end
    end
    
  end
  
  installer.pods_project.root_object.attributes['LastSwiftMigration'] = 9999
  installer.pods_project.root_object.attributes['LastSwiftUpdateCheck'] = 9999
  installer.pods_project.root_object.attributes['LastUpgradeCheck'] = 9999
end
