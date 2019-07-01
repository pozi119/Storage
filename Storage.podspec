
Pod::Spec.new do |s|
  s.name             = 'Storage'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Storage.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/SecludedMoon/Storage'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SecludedMoon' => 'pozi119@163.com' }
  s.source           = { :git => 'https://github.com/SecludedMoon/Storage.git', :tag => s.version.to_s }

  s.platform = :osx
  s.osx.deployment_target = "10.12"

  s.source_files = 'Storage/Classes/**/*'
  s.dependency 'SQLiteORM'
  s.dependency 'MMapKV'

end
