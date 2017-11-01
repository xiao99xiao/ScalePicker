<p align="center">
    <img src="https://travis-ci.org/kronik/ScalePicker.svg?branch=master" />
    <img src="https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat" alt="Platform: iOS 8+" />
    <img src="https://img.shields.io/cocoapods/v/ScalePicker.svg?style=flat" />
    <a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Language: Swift 2.2" /></a>
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
    <img src="http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat" alt="License: MIT" />
    <a href="https://twitter.com/dklimkin"><img src="http://img.shields.io/badge/contact-@dklimkin-blue.svg?style=flat"/></a>
</p>

# ScalePicker

Generic scale and a handy float-value picker for any iOS app.

## Preview

<img src="https://raw.githubusercontent.com/kronik/ScalePicker/master/Screenshots/demo.gif" width="400"/>

<br>
<img src="https://raw.githubusercontent.com/kronik/ScalePicker/master/Screenshots/1.png" width="33%"/>
<img src="https://raw.githubusercontent.com/kronik/ScalePicker/master/Screenshots/2.png" width="33%"/>
<img src="https://raw.githubusercontent.com/kronik/ScalePicker/master/Screenshots/3.png" width="33%"/>

## Installation

### With source code

[Download repository](https://github.com/kronik/ScalePicker/archive/master.zip), then add [ScalePicker directory](https://github.com/kronik/ScalePicker/blob/master/ScalePicker/) to your project.

### With CocoaPods

CocoaPods is a dependency manager for Objective-C/Swift, which automates and simplifies the process of using 3rd-party libraries in your projects. To install with cocoaPods, follow the "Get Started" section on [CocoaPods](https://cocoapods.org/).

#### Podfile
```ruby
platform :ios, '8.0'
use_frameworks!

pod 'ScalePicker'
```

### With Carthage

Carthage is a lightweight dependency manager for Swift and Objective-C. It leverages CocoaTouch modules and is less invasive than CocoaPods. To install with carthage, follow the instruction on [Carthage](https://github.com/Carthage/Carthage/).

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```
To integrate ScalePicker into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "kronik/ScalePicker"
```

## Usage

### Initialisation

Instantiate scale view with preferred frame:

```swift
let screenWidth = UIScreen.mainScreen().bounds.size.width
let scaleView = ScalePicker(frame: CGRectMake(0, 0, screenWidth, 50))

view.addSubview(scaleView)
```

### Properties

####Set minimum value

```swift
scaleView.minValue = -3.0
```

####Set maximum value

```swift
scaleView.maxValue = 3.0
```

####Set number of ticks between values value

```swift
scaleView.numberOfTicksBetweenValues = 2
```

####Set space between ticks

```swift
scaleView.spaceBetweenTicks = 20.0
```

####Set tick label visibility

```swift
scaleView.showTickLabels = true
```

####Set a delegate

```swift
scaleView.delegate = self
```

####Set ability to snap to the nearest value

```swift
scaleView.snapEnabled = true
```

####Set bounces value

```swift
scaleView.bounces = false
```

####Set tick (and center/arrow view) color

```swift
scaleView.tickColor = UIColor.whiteColor()
```

####Set center/arrow image

```swift
scaleView.centerArrowImage = UIImage(named: "arrowPointer")
```

### Control actions
#### Increase current value

```swift
scaleView.increaseValue()
```
#### Decrease current value

```swift
scaleView.decreaseValue()
```
#### Reset current value

```swift
scaleView.reset()
```
#### Gestures
In addition to increase/decrease/reset actions ScaleView allows you to double tap to trigger reset action

### More

For more details try Xcode [Demo project](https://github.com/kronik/ScalePicker/blob/master/Demo)

# Etc.

* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## Use it? Love/hate it?

Tweet the author [@dklimkin](http://twitter.com/dklimkin), and check out Dmitry's portfolio: http://dmitry-klimkin.com

## License

ScalePicker is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/kronik/ScalePicker/master/LICENSE) for details.
