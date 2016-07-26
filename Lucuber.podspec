Pod::Spec.new do |s|
  s.name         = 'Lucuber'
  s.version      = '<#Project Version#>'
  s.license      = '<#License#>'
  s.homepage     = '<#Homepage URL#>'
  s.authors      = '<#Author Name#>': '<#Author Email#>'
  s.summary      = '<#Summary (Up to 140 characters#>'

  s.platform     =  :ios, '<#iOS Platform#>'
  s.source       =  git: '<#Github Repo URL#>', :tag => s.version
  s.source_files = '<#Resources#>'
  s.frameworks   =  '<#Required Frameworks#>'
  s.requires_arc = true
  
# Pod Dependencies
  s.dependencies =	pod 'AVOSCloud'
  s.dependencies =	pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
  s.dependencies =	pod 'SnapKit', '~> 0.15.0'    ##AutoLayout第三方架构
  s.dependencies =	pod 'Ruler'
  s.dependencies =	pod 'Kingfisher', '~> 2.4'

end