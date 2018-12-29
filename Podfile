platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

target 'Zap' do
    pod 'SwiftBTC'
end

abstract_target 'RPC' do
    pod 'LndRpc', :path => '.'
    
    target 'SwiftLnd' do
        pod 'SwiftBTC'
        pod 'SwiftProtobuf'
        
        target 'SwiftLndTests' do
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

    target 'Lightning' do
        pod 'SwiftBTC'
        pod 'Bond'
        pod 'KeychainAccess'
        pod 'SQLite.swift', '~> 0.11.5'
        
        target 'LightningTests' do
            inherit! :search_paths
        end
    end
end

post_install do | installer |
    # Copy Acknowledgements to Settings.bundle
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Zap/Pods-Zap-acknowledgements.plist', 'Zap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
