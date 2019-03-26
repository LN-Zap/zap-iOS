platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

target 'Zap' do
    pod 'SwiftBTC', :path => './SwiftBTC'
end

target 'SnapshotUITests' do
    pod 'SimulatorStatusMagic', :configurations => ['Debug', 'DebugRemote']
end

abstract_target 'RPC' do
    pod 'LndRpc', :path => '.'
    pod 'SwiftBTC', :path => './SwiftBTC'

    target 'SwiftLnd' do
        target 'SwiftLndTests' do
            inherit! :search_paths
        end
    end
    
    target 'Library' do
        pod 'ScrollableGraphView'
        pod 'KeychainAccess'
        pod 'Bond'
        
        target 'LibraryTests' do
            inherit! :search_paths
        end
    end

    target 'Lightning' do
        pod 'Bond'
        pod 'SQLite.swift', :git => 'https://github.com/ottosuess/SQLite.swift.git', :commit => 'c96a5da4ef8c9ccec7bfac254b56ae17199097f3'
        
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
end
