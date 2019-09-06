Pod::Spec.new do |s|
  s.name             = 'TwitterLoginKit'
  s.version          = '0.1.4'
  s.summary          = 'A Twitter Login library to replace the deprecated TwitterKit.'

  s.homepage         = 'https://github.com/xiao99xiao/TwitterLoginKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiao99xiao' => 'xx2004xiamen@gmail.com' }
  s.source           = { :git => 'https://github.com/xiao99xiao/TwitterLoginKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'TwitterLoginKit/Classes/**/*'
  s.frameworks = 'UIKit'
  s.swift_version = '5.0'
end
