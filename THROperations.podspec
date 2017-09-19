Pod::Spec.new do |s|

  s.name         = "THROperations"
  s.version      = "1.0.0"
  s.summary      = "A collection of Operation subclasses and extensions."
  s.homepage     = "https://gitlab.3squared.com/iOSLibraries/THROperations"
  s.license      = { :type => 'Custom', :file => 'LICENCE' }
  s.author       = { "Sam Oakley" => "sam.oakley@3squared.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "git@gitlab.3squared.com:iOSLibraries/THROperations.git", :tag => s.version.to_s }
  s.source_files = "Operation", "Operation/**/*.{h,m,swift}"
	s.dependency 'THRResult', '~> 1.0.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }

end
