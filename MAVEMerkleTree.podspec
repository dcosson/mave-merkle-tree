#
# Be sure to run `pod lib lint MAVEMerkleTree.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html

Pod::Spec.new do |s|
  s.name             = "MAVEMerkleTree"
  s.version          = "0.1.0"
  s.summary          = "An Objective-C Merkle Tree implementation for iOS"
  s.description      = <<-DESC
                       An Objective-C Merkle Tree implementation for iOS
                       DESC
  s.homepage         = "http://mave.io"
  s.license          = 'MIT'
  s.author           = 'dcosson'
  s.source           = { :git => "https://github.com/dcosson/mave-merkle-tree.git", :tag => "v#{s.version.to_s}" }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MAVEMerkleTree/**/*.{m,h}'

  s.frameworks = 'UIKit'
  s.libraries = 'z'
end
