platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

install! 'cocoapods'

target 'Zap' do
end

target 'SwiftLnd' do
    pod 'SwiftGRPC', :git => 'https://github.com/grpc/grpc-swift'
end

target 'Lightning' do
    pod 'Bond'
    pod 'KeychainAccess'
    pod 'SQLite.swift', '~> 0.11.5'
end

target 'Library' do
    pod 'ScrollableGraphView'
    pod 'KeychainAccess'
    pod 'Bond'
    
    target 'LibraryTests' do
        inherit! :search_paths
    end
end

target 'ZapMessages' do
    pod 'Bond'
end

target 'BTCUtil' do
    pod 'BigInt', '~> 3.0'
end

post_install do | installer |
    # Copy Acknowledgements to Settings.bundle
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods-Zap/Pods-Zap-acknowledgements.plist', 'Zap/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
