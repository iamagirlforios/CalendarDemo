#
#  Be sure to run `pod spec lint WDCalendar.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "WDCalendar"
  s.version      = "1.0.1"   #库原代码的版本
  s.summary      = "WDCalendar."
  s.description  = <<-DESC
                   #日历WDCalendar
                   DESC

  s.homepage     = "https://github.com/iamagirlforios/CalendarDemo"   #声明库的主页
  s.license      = "MIT"   #所采用的授权版本
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "吴丹" => "wudancer@outlook.com" }   #库的作者。
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/iamagirlforios/CalendarDemo.git", :tag => "#{s.version}" }  #声明原代码的地址
  s.source_files  = "WDCalendar/*.{h,m}", "WDCalendar/Model/*.{h,m}", "WDCalendar/Util/*.{h,m}", "WDCalendar/Views/*.{h,m}"
  s.frameworks = "UIKit", "Foundation", 'CoreGraphics'
  s.requires_arc = true

end
