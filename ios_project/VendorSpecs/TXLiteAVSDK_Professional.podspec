Pod::Spec.new do |s|
  s.name             = 'TXLiteAVSDK_Professional'
  s.version          = '10.9.13148'
  s.summary          = 'Local vendored TXLiteAVSDK_Professional'
  s.description      = 'Vendored TXLiteAVSDK_Professional for CI without external network.'
  s.homepage         = 'https://cloud.tencent.com/product/rtmp'
  s.license          = { :type => 'Proprietary', :text => 'Local binary' }
  s.author           = { 'Local' => 'n/a' }
  s.platform         = :ios, '11.0'
  s.source           = { :path => '.' }
  s.requires_arc     = true
  s.vendored_frameworks = 'VendorFrameworks/TXLiteAVSDK_Professional.framework'
end
