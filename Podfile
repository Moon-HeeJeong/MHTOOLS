# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

platform :ios, '13.0'
use_frameworks!


def available_pods
pod 'Alamofire'
end



target 'MHTools' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  available_pods
  # Pods for MHTools

  # target 'MHToolsExTests' do
  #   # Pods for testing
  #   available_pods
  # end

  # target 'MHToolsExUITests' do
  #   # Pods for testing
  #   available_pods
  # end

  target 'MHToolsTests' do
    # Pods for testing
    inherit! :search_paths
  end

end

target 'MHToolsEx' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  available_pods
  # Pods for MHToolsEx

  target 'MHToolsExTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MHToolsExUITests' do
    # Pods for testing
  end

end
