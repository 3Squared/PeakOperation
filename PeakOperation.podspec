Pod::Spec.new do |s|

  s.name         = "PeakOperation"
  s.version      = "2.0.0"
  s.summary      = "A collection of Operation subclasses and extensions."
  s.homepage     = "https://gitlab.3squared.com/MobileTeam/PeakOperation"
  s.license      = { :type => 'Custom', :file => 'LICENSE.md' }
  s.author       = { "Sam Oakley" => "sam.oakley@3squared.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "git@gitlab.3squared.com:MobileTeam/PeakOperation.git", :tag => s.version.to_s }
  s.source_files = "PeakOperation", "PeakOperation/**/*.{h,m,swift}"
  s.dependency 'PeakResult'
  s.swift_version = '4.2'

end
