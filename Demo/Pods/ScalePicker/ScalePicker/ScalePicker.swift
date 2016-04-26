//
//  ScalePicker.swift
//  Dmitry Klimkin
//
//  Created by Dmitry Klimkin on 12/11/15.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import UIKit

public typealias ValueFormatter = (CGFloat) -> NSAttributedString
public typealias ValueChangeHandler = (CGFloat) -> Void

public protocol ScalePickerDelegate {
    func didChangeScaleValue(picker: ScalePicker, value: CGFloat)
}

@IBDesignable
public class ScalePicker: UIView, SlidePickerDelegate {
    
    public var delegate: ScalePickerDelegate?
    
    public var valueChangeHandler: ValueChangeHandler = {(value: CGFloat) in
    
    }
    
    @IBInspectable
    public var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable
    public var gradientMaskEnabled: Bool = false {
        didSet {
            picker.gradientMaskEnabled = gradientMaskEnabled
        }
    }
    
    @IBInspectable
    public var showCurrentValue: Bool = false {
        didSet {
            valueLabel.alpha = showCurrentValue ? 1.0 : 0.0
            
            showTickLabels = !showTickLabels
            showTickLabels = !showTickLabels
        }
    }
    
    @IBInspectable
    public var blockedUI: Bool = false {
        didSet {
            picker.blockedUI = blockedUI
        }
    }
    
    @IBInspectable
    public var numberOfTicksBetweenValues: UInt = 4 {
        didSet {
            picker.numberOfTicksBetweenValues = numberOfTicksBetweenValues
            reset()
        }
    }
    
    @IBInspectable
    public var minValue: CGFloat = -3.0 {
        didSet {
            picker.minValue = minValue
            reset()
        }
    }
    
    @IBInspectable
    public var maxValue: CGFloat = 3.0 {
        didSet {
            picker.maxValue = maxValue
            reset()
        }
    }
    
    @IBInspectable
    public var spaceBetweenTicks: CGFloat = 10.0 {
        didSet {
            picker.spaceBetweenTicks = spaceBetweenTicks
            reset()
        }
    }
    
    @IBInspectable
    public var centerViewWithLabelsYOffset: CGFloat = 15.0 {
        didSet {
            updateCenterViewOffset()
        }
    }

    @IBInspectable
    public var centerViewWithoutLabelsYOffset: CGFloat = 10.0 {
        didSet {
            updateCenterViewOffset()
        }
    }
    
    @IBInspectable
    public var tickColor: UIColor = UIColor.whiteColor() {
        didSet {
            picker.tickColor = tickColor
            centerImageView.image = centerArrowImage?.tintImage(tickColor)
            titleLabel.textColor = tickColor
        }
    }
    
    @IBInspectable
    public var centerArrowImage: UIImage? {
        didSet {
            centerImageView.image = centerArrowImage
            reset()
        }
    }
    
    @IBInspectable
    public var showTickLabels: Bool = true {
        didSet {
            picker.showTickLabels = showTickLabels
            
            updateCenterViewOffset()
            
            layoutSubviews()
        }
    }
    
    @IBInspectable
    public var snapEnabled: Bool = false {
        didSet {
            picker.snapEnabled = snapEnabled
        }
    }
    
    @IBInspectable
    public var showPlusForPositiveValues: Bool = true {
        didSet {
            picker.showPlusForPositiveValues = showPlusForPositiveValues
        }
    }
    
    @IBInspectable
    public var fireValuesOnScrollEnabled: Bool = true {
        didSet {
            picker.fireValuesOnScrollEnabled = fireValuesOnScrollEnabled
        }
    }
    
    @IBInspectable
    public var bounces: Bool = false {
        didSet {
            picker.bounces = bounces
        }
    }
    
    @IBInspectable
    public var sidePadding: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    public var pickerPadding: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    public var currentTransform: CGAffineTransform = CGAffineTransformIdentity {
        didSet {
            picker.currentTransform = currentTransform
        }
    }
    
    public var valueFormatter: ValueFormatter = {(value: CGFloat) -> NSAttributedString in
        let attrs = [NSForegroundColorAttributeName: UIColor.whiteColor(),
                     NSFontAttributeName: UIFont.systemFontOfSize(12.0)]
        
        return NSMutableAttributedString(string: value.format(".2"), attributes: attrs)
    }
    
    public var rightView: UIView? {
        willSet(newRightView) {
            if let view = rightView {
                view.removeFromSuperview()
            }
        }
        
        didSet {
            if let view = rightView {
                addSubview(view)
            }

            layoutSubviews()
        }
    }
    
    private var picker: SlidePicker!
    private var shouldUpdatePicker = true
    private let centerImageView = UIImageView(frame: CGRectMake(0, 0, 10, 10))
    private let centerView = UIView(frame: CGRectMake(0, 0, 10, 10))
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    public var currentValue: CGFloat = 0.0 {
        didSet {
            if shouldUpdatePicker {
                let snapEnabled = picker.snapEnabled

                picker.snapEnabled = true
                picker.scrollToValue(currentValue, animated: true)
                
                picker.snapEnabled = snapEnabled
            }
            
            valueLabel.attributedText = valueFormatter(currentValue)
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
        
        titleLabel.textColor = tickColor
        titleLabel.textAlignment = .Left
        titleLabel.font = UIFont.systemFontOfSize(13.0)
        
        addSubview(titleLabel)
        
        valueLabel.textColor = tickColor
        valueLabel.textAlignment = .Center
        valueLabel.font = UIFont.systemFontOfSize(13.0)
        
        addSubview(valueLabel)
        
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
        picker.spaceBetweenTicks = spaceBetweenTicks
        
        updateCenterViewOffset()
        
        addSubview(picker)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScalePicker.onDoubleTap(_:)))
        
        tapGesture.numberOfTapsRequired = 2
        
        addGestureRecognizer(tapGesture)
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        layoutSubviews()
        reset()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        valueLabel.frame = CGRectMake(sidePadding + pickerPadding, 0,
                                      frame.width - sidePadding * 2 - pickerPadding * 2, frame.size.height / 3.0)
        if showCurrentValue {
            picker.frame = CGRectMake(pickerPadding + sidePadding, frame.size.height / 3.0,
                                      frame.size.width - pickerPadding * 2 - sidePadding * 2, frame.size.height * 2.0 / 3.0)
        } else {
            picker.frame = CGRectMake(pickerPadding + sidePadding, 0,
                                      frame.size.width - pickerPadding * 2 - sidePadding * 2, frame.size.height)
        }
        
        picker.layoutSubviews()
        
        titleLabel.frame = CGRectMake(sidePadding, 0, frame.width - sidePadding * 2, frame.size.height)
        
        if let view = rightView {
            view.center = CGPointMake(frame.size.width - sidePadding - view.frame.size.width / 2, frame.size.height / 2)
        }
    }
    
    public func onDoubleTap(recognizer: UITapGestureRecognizer) {
        reset()
    }
    
    public func reset() {
        currentValue = 0.0
        delegate?.didChangeScaleValue(self, value: currentValue)
        valueChangeHandler(currentValue)
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
            valueChangeHandler(value)
        }
        
        shouldUpdatePicker = true
    }
    
    private func updateCenterViewOffset() {
        picker.centerViewOffsetY = showTickLabels ? centerViewWithLabelsYOffset : centerViewWithoutLabelsYOffset
    }
}

private extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

private extension Float {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

private extension CGFloat {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}