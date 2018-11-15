platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

abstract_target 'Apps' do
    pod 'SwiftBTC'

    target 'Zap' do
    end
    
    target 'ZapPos' do
    end
end

target 'SwiftLnd' do
    pod 'SwiftBTC'
    pod 'SwiftGRPC', :git => 'https://github.com/grpc/grpc-swift'
    
    target 'SwiftLndTests' do
        inherit! :search_paths
    end
end

target 'Lightning' do
    pod 'SwiftBTC'
    pod 'Bond'
    pod 'KeychainAccess'
    pod 'SQLite.swift', '~> 0.11.5'
    
    target 'LightningTests' do
        inherit! :search_paths
    end
end

target 'Library' do
    pod 'SwiftBTC'
    pod 'ScrollableGraphView'
    pod 'KeychainAccess'
    pod 'Bond'
    
    target 'LibraryTests' do
        inherit! :search_paths
    end
end

post_install do | installer |
    # Copy Acknowledgements to Settings.bundle
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Apps-Zap/Pods-Apps-Zap-acknowledgements.plist', 'Zap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
    FileUtils.cp_r('Pods/Target Support Files/Pods-Apps-ZapPos/Pods-Apps-ZapPos-acknowledgements.plist', 'ZapPos/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
