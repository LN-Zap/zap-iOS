platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

target 'Zap' do
end

target 'SwiftLnd' do
    pod 'SwiftBTC', :git => 'https://github.com/LN-Zap/SwiftBTC.git'
    pod 'SwiftGRPC', :git => 'https://github.com/grpc/grpc-swift'
end

target 'Lightning' do
    pod 'SwiftBTC', :git => 'https://github.com/LN-Zap/SwiftBTC.git'
    pod 'Bond'
    pod 'KeychainAccess'
    pod 'SQLite.swift', '~> 0.11.5'
end

target 'Library' do
    pod 'SwiftBTC', :git => 'https://github.com/LN-Zap/SwiftBTC.git'
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
    FileUtils.cp_r('Pods/Target Support Files/Pods-Zap/Pods-Zap-acknowledgements.plist', 'Zap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
