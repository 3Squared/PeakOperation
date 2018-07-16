Pod::Spec.new do |s|

  s.name         = "PeakOperation"
  s.version      = "1.4.3"
  s.summary      = "A collection of Operation subclasses and extensions."
  s.homepage     = "https://gitlab.3squared.com/iOSLibraries/PeakOperation"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "Sam Oakley" => "sam.oakley@3squared.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "git@gitlab.3squared.com:iOSLibraries/PeakOperation.git", :tag => s.version.to_s }
  s.source_files = "PeakOperation", "PeakOperation/**/*.{h,m,swift}"
  s.dependency 'PeakResult'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

end
