#
# Be sure to run `pod lib lint SwiftyCam.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftyCam'
  s.version          = '3.0.0'
  s.summary          = 'A Simple, Snapchat inspired camera Framework written in Swift'
  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

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
end
