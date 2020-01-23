Pod::Spec.new do |s|

  s.name         = "PeakOperation"
  s.version      = "4.1.0"
  s.summary      = "A collection of Operation subclasses and extensions."
  s.homepage     = "https://github.com/3squared/PeakOperation"
  s.license      = { :type => 'Custom', :file => 'LICENSE.md' }
  s.author       = { "Sam Oakley" => "sam.oakley@3squared.com", "David Yates" => "david.yates@3squared.com"  }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/3squared/PeakOperation.git", :tag => s.version.to_s }
  s.source_files = "PeakOperation", "PeakOperation/**/*.{h,m,swift}"
  s.swift_version = '5.0'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.macos.deployment_target = '10.13'

  s.source_files = "PeakOperation", "PeakOperation/Core/**/*.{h,m,swift}"
  s.ios.source_files = "PeakOperation/Platforms/iOS/**/*.{h,m,swift}"
  s.tvos.source_files = "PeakOperation/Platforms/iOS/**/*.{h,m,swift}"
  s.macos.source_files = "PeakOperation/Platforms/macOS/**/*.{h,m,swift}"

end
