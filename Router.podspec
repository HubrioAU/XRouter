Pod::Spec.new do |s|
  s.name             = 'Router'
  s.version          = '0.1.0'
  s.summary          = 'The simple routing library for iOS.'

  s.description      = <<-DESC
The simple routing library for iOS.
                       DESC

  s.homepage         = 'https://github.com/reececomo/Router'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Reece Como' => 'reece.como@gmail.com' }
  s.source           = { :git => 'https://github.com/reececomo/Router.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version = '4.2'

  s.source_files = 'Router/Classes/**/*'
end
