#
# Be sure to run `pod lib lint SwiftyCam.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyCam'
  s.version          = '2.3.0'
  s.summary          = 'A Simple, Snapchat inspired camera Framework written in Swift'
  s.ios.deployment_target = '8.0'


# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
A drop in Camera View Controller for capturing photos and videos from one AVSession. Written in Swift.
                     DESC

  s.homepage         = 'https://github.com/Awalz/SwiftyCam'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'BSD', :file => 'LICENSE' }
  s.author           = { 'Andrew Walz' => 'andrewjwalz@gmail.com' }
  s.source           = { :git => 'https://github.com/Awalz/SwiftyCam.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/**/*'

  # s.resource_bundles = {
  #   'SwiftyCam' => ['SwiftyCam/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
