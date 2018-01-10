#
#  Be sure to run `pod spec lint WDCalendar.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "WDCalendar"
  s.version      = "0.0.1"   #库原代码的版本
  s.summary      = "WDCalendar."
  s.description  = <<-DESC
                   #日历WDCalendar
                   DESC

  s.homepage     = "https://github.com/iamagirlforios/CalendarDemo"   #声明库的主页
  s.license      = "MIT"   #所采用的授权版本
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "吴丹" => "wudancer@outlook.com" }   #库的作者。

  s.platform     = :ios, "8.0"
#https://github.com/iamagirlforios/CalendarDemo.git
  s.source       = { :git => "https://github.com/iamagirlforios/CalendarDemo.git", :tag => "#{s.version}" }  #声明原代码的地址
  s.source_files  = "CalendarDemo", "CalendarDemo/WDCalendar/*.{h,m}", "CalendarDemo/WDCalendar/Model/*.{h,m}", "CalendarDemo/WDCalendar/Util/*.{h,m}", "CalendarDemo/WDCalendar/Views/*.{h,m}"
  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  s.frameworks = "UIKit", "Foundation", 'CoreGraphics'

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
