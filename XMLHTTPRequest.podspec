Pod::Spec.new do |s|
  s.name             = "XMLHTTPRequest"
  s.version          = "0.1.1"
  s.summary          = "An implementation of the JavaScript XMLHttpRequest object to extend JavaScriptCore."
  s.description      = <<-DESC
                        In iOS 7, Apple introduced the possibility to [execute JavaScript via the JavaScriptCore JavaScript
                        engine] (http://nshipster.com/javascriptcore/). Unfortunately, JavaScriptCore is missing some
                        objects and functions a JavaScript environment of a browser would have. Especially the
                        `XMLHTTPRequest` (see the [Mozilla documentation]
                        (https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest) object needed for AJAX reqeuests
                        is not provided by JavaScriptCore. This library implements this missing object, so it is possible to
                        use JavaScript libraries which were originally developed for in-browser use in your Objective-C
                        (or Swift) application without the need to use a hidden WebView.
                       DESC
  s.homepage         = "https://github.com/Lukas-Stuehrk/XMLHTTPRequest"
  s.license          = 'MIT'
  s.author           = { "Lukas Stührk" => "Lukas@Stuehrk.net" }
  s.source           = { :git => "https://github.com/Lukas-Stuehrk/XMLHTTPRequest.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'XMLHTTPRequest/XMLHTTPRequest.*'
  s.resource_bundles = {
  }

  s.public_header_files = 'XMLHTTPRequest/XMLHTTPRequest.h'
  s.frameworks = 'JavaScriptCore'
end
