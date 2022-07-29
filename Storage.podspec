
Pod::Spec.new do |s|
  s.name             = 'Storage'
  s.version          = '0.1.0-beta1'
  s.summary          = 'A short description of Storage.'
  s.description      = <<-DESC
      TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pozi119/Storage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Valo Lee' => 'pozi119@163.com' }
  s.source           = { :git => 'https://github.com/pozi119/Storage.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.watchos.deployment_target = '3.0'

  s.swift_version = '5.0'

  s.source_files = 'Storage/Classes/**/*'
  s.dependency 'SQLiteORM', '~> 0.1.4-beta2'
  s.dependency 'MMapKV', '~> 0.1.0-beta1'

end
