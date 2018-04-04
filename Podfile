platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

target 'Zap' do
  pod 'LightningRpc', :path => '.'
  pod 'KeychainAccess'
  pod 'Bond'

  target 'ZapTests' do
    inherit! :search_paths
  end
end

target 'BTCUtil' do
    pod 'BigInt', '~> 3.0'
end

post_install do | installer |
    # Copy Acknowledgements to Settings.bundle
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Zap/Pods-Zap-acknowledgements.plist', 'Zap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    
    # Enable RxSwift TRACE_RESOURCES
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
