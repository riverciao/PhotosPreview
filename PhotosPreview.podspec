Pod::Spec.new do |s|
  s.name             = 'PhotosPreview'
  s.version          = '1.2.9'
  s.summary          = 'Messenger-like photo browser for user to preview and pick photo.'

  s.description      = <<-DESC
PhotosPreview is a Swift library, making Messenger-like photo browser. User can pick photo with bottom preview bar or preview with a entire album.
                       DESC

  s.homepage         = 'https://github.com/riverciao/PhotosPreview'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ciao Huang' => 'forwardciao@gmail.com' }
  s.source           = { :git => 'https://github.com/riverciao/PhotosPreview.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.source_files = '{PhotosPreview/*, PhotosPreview.xcodeproj}'
  s.resource_bundles = {'PhotosPreview' => ['PhotosPreview/*.xcassets']}
  s.swift_version = '4.0'

end
