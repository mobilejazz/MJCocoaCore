#
# Be sure to run `–' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MJCocoaCore'
  s.version          = '2.2.0'
  s.summary          = 'Mobile Jazz Cocoa Core'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Common set of reusable classes, categories and definitions for Cocoa.
                       DESC

  s.homepage         = 'https://github.com/mobilejazz/MJCocoaCore'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author           = { 'Mobile Jazz' => 'info@mobilejazz.com' }
  s.source           = { :git => 'https://github.com/mobilejazz/MJCocoaCore.git', :tag => s.version.to_s }
  # s.social_media_url = 'http://twitter.com/mobilejazzcom'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'MJCocoaCore/MJCocoaCore.h'
  
  s.default_subspecs = 'Common'
  
  s.subspec 'Future' do |sp|
      sp.source_files = 'MJCocoaCore/Classes/Future/**/*'
  end
  
  s.subspec 'Common' do |sp|
      sp.source_files = 'MJCocoaCore/Classes/Common/**/*'
      sp.dependency 'MJCocoaCore/Future'
  end
  
  s.subspec 'Realm' do |sp|
      sp.source_files = 'MJCocoaCore/Classes/Realm/**/*'
      sp.dependency 'Realm', '~> 3.0'
      sp.dependency 'MJCocoaCore/Common'
  end
  
  # s.resource_bundles = {
  #   'MJCocoaCore' => ['MJCocoaCore/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
