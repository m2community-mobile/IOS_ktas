# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ktas' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ktas

 inhibit_all_warnings!


 pod 'Alamofire', '~> 4.7'
 pod 'KeychainSwift', '~> 13.0'

 ##https://firebase.google.com/docs/ios/setup
 pod 'Firebase/Core', '7.5.0'
 pod 'Firebase/Messaging', '7.5.0'
 
 #https://firebase.google.com/docs/crashlytics?hl=ko
 pod 'Firebase/Crashlytics', '7.5.0'
 pod 'Firebase/Analytics', '7.5.0'
 
 #https://github.com/thii/FontAwesome.swift
 pod 'FontAwesome.swift', '1.9.1'
 
end
post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
               end
          end
   end
end