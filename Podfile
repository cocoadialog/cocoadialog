platform :osx, '10.8'
inhibit_all_warnings!

class ::Pod::Generator::Acknowledgements
  def header_text
    "\nThe following third party libraries are so awesome, you'll just have to check them out to see how badass they are! Thank you for coding amazing tools and letting this project use them!\n\n\n" +
    "## CocoaPods\n\n[CocoaPods](https://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects.\n\nThe MIT License (MIT): \n\nhttps://github.com/CocoaPods/CocoaPods/blob/master/LICENSE\n\n"
  end
  def footnote_text
    ""
  end
end

target 'cocoadialog' do
  #use_frameworks!

  pod 'GRMustache', '~> 7.3.2'
  pod 'TSMarkdownParser', '~> 2.1.3'
  
  post_install do | installer |
    require 'fileutils'
    file = "Pods/Target\ Support\ Files/Pods-cocoadialog/Pods-cocoadialog-acknowledgements.markdown"
    if (File.file?(file))
      FileUtils.cp_r(file, 'Resources/Acknowledgements.md', :remove_destination => true)
    else
      warn('The following file does not exist: ' + file)
    end
  end

end
