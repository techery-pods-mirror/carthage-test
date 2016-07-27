Pod::Spec.new do |s|
  s.name         = "CriolloKitDI"
  s.version      = "0.0.4"
  s.summary      = "DI framework for Criollo Kit"

  s.description  = <<-DESC
                Dependency Injection Framework
                   DESC

  s.homepage     = "https://github.com/CriolloKit/DI"

  s.license      = 'MIT (example)'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "CriolloKit" => "thesooth@aol.com" }

  s.platform     = :ios, '6.0'

  s.source       = { :git => "https://github.com/CriolloKit/DI.git", :tag => "#{s.version}"}

  s.source_files  = 'CRDI/Code', 'CRDI/Code/**/*.{h,m}'
  
  s.frameworks = 'Foundation'

  s.requires_arc = true

  s.dependency 'MAObjCRuntime'
  s.dependency 'ISMethodSwizzling'

end
