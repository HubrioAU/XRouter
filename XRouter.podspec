Pod::Spec.new do |s|
  s.name             = 'XRouter'
  s.version          = '1.2.0'
  s.summary          = 'The simple routing library for iOS.'

  s.description      = <<-DESC
A simple routing library for iOS.
Setup routes and map them to controllers, easy peasy.
                       DESC

  s.homepage         = 'https://github.com/reececomo/XRouter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Reece Como' => 'reece.como@gmail.com' }
  s.source           = { :git => 'https://github.com/reececomo/XRouter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'

  s.source_files = 'Router/Classes/**/*'
end
