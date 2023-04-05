Pod::Spec.new do |spec|
spec.name = 'MagicPixelTraceHub'
spec.version = '1.0'
spec.homepage = 'https://github.com/sridmat/mp-trace-hub-sdk-ios'
spec.source = { :git => "https://github.com/sridmat/mp-trace-hub-sdk-ios.git", :tag => spec.version.to_s }
spec.authors = 'MagicPixel Operations'
spec.license = 'MIT'
spec.summary = 'MagicPixel TraceHub iOS framework'
spec.source_files = 'MagicPixelTraceHub', 'MagicPixelTraceHub/*'
spec.module_name = 'MagicPixelTraceHub'
spec.ios.deployment_target = '11.0'
end