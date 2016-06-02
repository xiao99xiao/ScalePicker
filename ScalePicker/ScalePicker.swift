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

public enum ScalePickerValuePosition {
    case Top
    case Left
}

public protocol ScalePickerDelegate {
    func didChangeScaleValue(picker: ScalePicker, value: CGFloat)
}

@IBDesignable
public class ScalePicker: UIView, SlidePickerDelegate {
    
    public var delegate: ScalePickerDelegate?
    
    public var valueChangeHandler: ValueChangeHandler = {(value: CGFloat) in
    
    }
    
    public var valuePosition = ScalePickerValuePosition.Top {
        didSet {
            layoutSubviews()
        }
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
    public var invertValues: Bool = false {
        didSet {
            picker.invertValues = invertValues
        }
    }
    
    @IBInspectable
    public var fillSides: Bool = false {
        didSet {
            picker.fillSides = fillSides
        }
    }
    
    @IBInspectable
    public var elasticCurrentValue: Bool = false

    @IBInspectable
    public var highlightCenterTick: Bool = true {
        didSet {
            picker.highlightCenterTick = highlightCenterTick
        }
    }

    @IBInspectable
    public var allTicksWithSameSize: Bool = false {
        didSet {
            picker.allTicksWithSameSize = allTicksWithSameSize
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
    public var centerViewWithoutLabelsYOffset: CGFloat = 15.0 {
        didSet {
            updateCenterViewOffset()
        }
    }
    
    @IBInspectable
    public var pickerOffset: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
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
            applyCurrentTransform()
        }
    }
    
    public func applyCurrentTransform() {
        picker.currentTransform = currentTransform
    }
    
    public var values: [CGFloat]? {
        didSet {
            guard let values = values where values.count > 1 else { return; }
            
            picker.values = values
            
            maxValue = values[values.count - 1]
            minValue = values[0]
            initialValue = values[0]
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

    public var leftView: UIView? {
        willSet(newLeftView) {
            if let view = leftView {
                view.removeFromSuperview()
            }
        }
        
        didSet {
            if let view = leftView {
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
    private var initialValue: CGFloat = 0.0

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
    
    public func commonInit() {
        userInteractionEnabled = true
        
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
        picker.highlightCenterTick = highlightCenterTick
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

        picker.frame = CGRectMake(pickerPadding + sidePadding, pickerOffset,
                                  frame.size.width - pickerPadding * 2 - sidePadding * 2, frame.size.height + pickerOffset)
        picker.layoutSubviews()
        
        if let view = rightView {
            view.center = CGPointMake(frame.size.width - sidePadding - view.frame.size.width / 2, picker.center.y + 5)
        }

        if let view = leftView where valuePosition == .Top {
            view.center = CGPointMake(sidePadding + view.frame.size.width / 2, picker.center.y + 5)
        }
        
        var leftViewWidth: CGFloat = 60

        if let view = leftView where valuePosition == .Left {
            view.center = CGPointMake(sidePadding + view.frame.size.width / 2, ((frame.size.height / 2) - view.frame.height / 4) + 5)
            
            leftViewWidth = view.frame.size.width
        }
        
        titleLabel.frame = CGRectMake(sidePadding, 0, frame.width - sidePadding * 2, frame.size.height)

        if valuePosition == .Top {
            valueLabel.frame = CGRectMake(sidePadding + pickerPadding, 5,
                                          frame.width - sidePadding * 2 - pickerPadding * 2, frame.size.height / 4.0)
        } else {
            valueLabel.frame = CGRectMake(0, 7 + frame.size.height / 2,
                                          sidePadding * 2 + leftViewWidth, frame.size.height / 3.0)
        }
    }
    
    public func onDoubleTap(recognizer: UITapGestureRecognizer) {
        reset()
    }
    
    public func reset() {
        currentValue = initialValue
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
        initialValue = value
        
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
    
    public func didChangeContentOffset(offset: CGFloat) {
        guard elasticCurrentValue else { return }
        
        let minScale: CGFloat    = 0.0
        let maxScale: CGFloat    = 0.3
        let maxOffset: CGFloat   = 50.0
        var offsetShift: CGFloat = 0.0
        var scaleShift: CGFloat  = 1.0
        var offsetValue          = offset

        if offset < 0 {
            scaleShift = -0.3
            offsetShift = 50.0
            offsetValue = offset + offsetShift
        }

        var value = min(maxScale, max(minScale, offsetValue * (maxScale / maxOffset)))
        
        value += scaleShift
        
        if offset < 0 {
            if value < 0 {
                if invertValues {
                    value = fabs(value) + 1
                } else {
                    value += 1
                }
            }
        } else {
            if invertValues {
                value = 1 - (value - scaleShift)
            }
        }
                
        valueLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, value, value)
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