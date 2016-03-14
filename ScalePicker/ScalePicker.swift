//
//  ScalePicker.swift
//  Dmitry Klimkin
//
//  Created by Dmitry Klimkin on 12/11/15.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import UIKit

public protocol ScalePickerDelegate {
    func didChangeScaleValue(picker: ScalePicker, value: CGFloat)
}

public class ScalePicker: UIView, SlidePickerDelegate {
    
    public var delegate: ScalePickerDelegate?
    
    public var numberOfTicksBetweenValues: UInt = 4 {
        didSet {
            picker.numberOfTicksBetweenValues = numberOfTicksBetweenValues
        }
    }

    public var showTickLabels = true {
        didSet {
            picker.showTickLabels = showTickLabels
            picker.centerViewOffsetY = showTickLabels ? 15 : 10.0
        }
    }
    
    public var snapEnabled = false {
        didSet {
            picker.snapEnabled = snapEnabled
        }
    }
    
    public var bounces = false {
        didSet {
            picker.bounces = bounces
        }
    }
    
    public var minValue: CGFloat = -3.0 {
        didSet {
            picker.minValue = minValue
        }
    }
    
    public var maxValue: CGFloat = 3.0 {
        didSet {
            picker.maxValue = maxValue
        }
    }
    
    public var spaceBetweenTicks: CGFloat = 10.0 {
        didSet {
            picker.spaceBetweenTicks = spaceBetweenTicks
        }
    }
    
    public var tickColor = UIColor.whiteColor() {
        didSet {
            picker.tickColor = tickColor
            centerImageView.image = centerArrowImage?.tintImage(tickColor)
        }
    }
    
    public var centerArrowImage: UIImage? {
        didSet {
            centerImageView.image = centerArrowImage
        }
    }
    
    private var picker: SlidePicker!
    private var shouldUpdatePicker = true
    private let pickerPadding: CGFloat = 0
    private let centerImageView = UIImageView(frame: CGRectMake(0, 0, 10, 10))

    public var currentValue: CGFloat = 0.0 {
        didSet {
            if shouldUpdatePicker {
                let snapEnabled = picker.snapEnabled

                picker.snapEnabled = true
                picker.scrollToValue(currentValue, animated: true)
                
                picker.snapEnabled = snapEnabled
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        userInteractionEnabled = true
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
        
        let centerView = UIView()
        
        centerImageView.contentMode = .Center
        centerImageView.center = CGPointMake(centerView.frame.size.width / 2, centerView.frame.size.height / 2 + 5)
        
        centerView.addSubview(centerImageView)
        
        picker = SlidePicker(frame: CGRectMake(pickerPadding, 0, frame.size.width - pickerPadding * 2, frame.size.height))
        
        picker.numberOfTicksBetweenValues = numberOfTicksBetweenValues
        picker.minValue = minValue
        picker.maxValue = maxValue
        picker.delegate = self
        picker.snapEnabled = snapEnabled
        picker.showTickLabels = showTickLabels
        picker.highlightCenterTick = true
        picker.bounces = bounces
        picker.tickColor = tickColor
        picker.centerView = centerView
        picker.centerViewOffsetY = showTickLabels ? 15 : 10.0
        picker.spaceBetweenTicks = spaceBetweenTicks
        
        addSubview(picker)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * CGFloat(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.setInitialCurrentValue(0.0)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "onDoubleTap:")
        
        tapGesture.numberOfTapsRequired = 2
        
        addGestureRecognizer(tapGesture)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        picker.frame = CGRectMake(pickerPadding, 0, frame.size.width - pickerPadding * 2, frame.size.height)
    }
    
    public func onDoubleTap(recognizer: UITapGestureRecognizer) {
        reset()
    }
    
    public func reset() {
        currentValue = 0.0
        delegate?.didChangeScaleValue(self, value: currentValue)
    }
    
    public func increaseValue() {
        picker.increaseValue()
    }
    
    public func decreaseValue() {
        picker.decreaseValue()
    }
    
    public func setInitialCurrentValue(value: CGFloat) {
        shouldUpdatePicker = false
        
        currentValue = value
        
        picker.scrollToValue(value, animated: false)
        
        shouldUpdatePicker = true
    }
    
    public func didSelectValue(value: CGFloat) {
        shouldUpdatePicker = false
        
        if value != currentValue {
            currentValue = value
            delegate?.didChangeScaleValue(self, value: value)
        }
        
        shouldUpdatePicker = true
    }
}