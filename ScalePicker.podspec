Pod::Spec.new do |s|

    s.name = 'ScalePicker'
    s.version = '3.0.0'
    s.platform = :ios, '9.0'
    s.license = 'MIT'
    s.homepage = 'https://github.com/kronik/ScalePicker'
    s.author = { 'Dmitry Klimkin' => 'dmitry.klimkin@gmail.com' }
    s.source = { :git => 'https://github.com/kronik/ScalePicker.git', :tag => s.version }
    s.summary = 'Generic scale and a float value picker for any iOS app'
    s.ios.deployment_target = '9.0'
    s.framework = 'UIKit'
    s.requires_arc = true

    s.swift_version = '5.0'

    s.source_files = 'ScalePicker/*.swift'

end
