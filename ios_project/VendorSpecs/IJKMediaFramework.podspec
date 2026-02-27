Pod::Spec.new do |s|
  s.name             = 'IJKMediaFramework'
  s.version          = '0.1.5'
  s.summary          = 'Local vendored IJKMediaFramework'
  s.description      = 'Vendored IJKMediaFramework for CI without external network.'
  s.homepage         = 'https://github.com/renzifeng/IJKMediaFramework'
  s.license          = { :type => 'Proprietary', :text => 'Local binary' }
  s.author           = { 'Local' => 'n/a' }
  s.platform         = :ios, '11.0'
  s.source           = { :path => '.' }
  s.requires_arc     = true
  s.vendored_frameworks = 'VendorFrameworks/IJKMediaFramework.framework'
end
