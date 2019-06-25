#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'tazz_socket'
  s.version          = '1.0.1'
  s.summary          = 'Flutter Socket Plugin with custom Options.'
  s.description      = <<-DESC
Flutter Socket Plugin with custom Options.
                       DESC
  s.homepage         = 'http://tazzix.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Tasnim Ahmed' => 'phonedev@tazzix.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Socket.IO-Client-Swift'
  s.dependency 'Starscream'
  s.ios.deployment_target = '9.0'
end

