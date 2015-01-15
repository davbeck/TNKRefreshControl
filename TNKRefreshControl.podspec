Pod::Spec.new do |s|
  s.name             = "TNKRefreshControl"
  s.version          = "0.1.1"
  s.summary          = "A replacement for UIRefreshControl with a more modern look and more flexibility."
  s.homepage         = "https://github.com/davbeck/TNKRefreshControl"
  s.screenshots     = "http://zippy.gfycat.com/BlackandwhiteUnevenIndianspinyloach.gif", "http://f.cl.ly/items/2l183G2a0l0U30033L3v/iOS%20Simulator%20Screen%20Shot%20Jan%2014,%202015,%205.37.25%20PM.png", "http://f.cl.ly/items/1W223R1I3028002y350B/iOS%20Simulator%20Screen%20Shot%20Jan%2014,%202015,%205.37.30%20PM.png"
  s.license          = 'MIT'
  s.author           = { "David Beck" => "code@thinkultimate.com" }
  s.source           = { :git => "https://github.com/davbeck/TNKRefreshControl.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'TNKRefreshControl' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CKShapeView', '~> 0.1'
end
