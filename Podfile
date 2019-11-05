platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

target 'Zap' do
end

target 'SnapshotUITests' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end

abstract_target 'RPC' do
    pod 'SwiftBTC', :path => './SwiftBTC'

    target 'SwiftLnd' do
        pod 'SwiftGRPC'
        pod 'ReachabilitySwift'
        
        target 'SwiftLndTests' do
            inherit! :search_paths
        end
    end
    
    target 'Library' do
        pod 'KeychainAccess'
        pod 'Bond'
        
        target 'LibraryTests' do
            inherit! :search_paths
        end
    end

    target 'Lightning' do
        pod 'Bond'
        
        target 'LightningTests' do
            inherit! :search_paths
        end
    end
    
    target 'Widget' do
    end
end

post_install do | installer |
    # Copy Acknowledgements to Settings.bundle
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Zap/Pods-Zap-acknowledgements.plist', 'Zap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)

    # don't include pod dsyms
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end
