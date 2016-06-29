//
//  SlidePicker.swift
//  Dmitry Klimkin
//
//  Created by Dmitry Klimkin on 12/11/15.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import Foundation
import UIKit

public protocol SlidePickerDelegate {
    func didSelectValue(value: CGFloat)
    func didChangeContentOffset(offset: CGFloat, progress: CGFloat)
}

@IBDesignable
public class SlidePicker: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    public var delegate: SlidePickerDelegate?

    @IBInspectable
    public var gradientMaskEnabled: Bool = false {
        didSet {
            layer.mask = gradientMaskEnabled ? maskLayer : nil
            
            layoutSubviews()
        }
    }
    
    @IBInspectable
    public var invertValues: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var fillSides: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var allTicksWithSameSize: Bool = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var blockedUI: Bool = false {
        didSet {
            uiBlockView.removeFromSuperview()
            
            if blockedUI {
                addSubview(uiBlockView)
            }
            
            layoutSubviews()
        }
    }
    
    @IBInspectable
    public var showPlusForPositiveValues: Bool = true {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var snapEnabled: Bool = true
    
    @IBInspectable
    public var fireValuesOnScrollEnabled: Bool = true
    
    @IBInspectable
    public var showTickLabels: Bool = true {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var highlightCenterTick: Bool = true {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var bounces: Bool = false {
        didSet {
            collectionView.bounces = bounces
        }
    }
    
    @IBInspectable
    public var spaceBetweenTicks: CGFloat = 20.0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var centerViewOffsetY: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }

    private let cellId = "collectionViewCellId"

    private var flowLayout = SlidePickerFlowLayout()
    private var collectionView: UICollectionView!
    private var tickValue: CGFloat = 1.0
    
    private var maskLayer: CALayer!
    private var maskLeftLayer: CAGradientLayer!
    private var maskRightLayer: CAGradientLayer!
    private var uiBlockView: UIView!

    public var centerView: UIView? {
        didSet {
            if let centerView = centerView {
                centerViewOffsetY = 0.0
                
                addSubview(centerView)
            }
        }
    }
    
    public var values: [CGFloat]? {
        didSet {
            guard let values = values where values.count > 1 else { return; }
            
            updateSectionsCount()

            collectionView.reloadData()
        }
    }

    @IBInspectable
    public var tickColor: UIColor = UIColor.whiteColor() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var sectionsCount: Int = 0 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBInspectable
    public var minValue: CGFloat = 0.0 {
        didSet {
            updateSectionsCount()
        }
    }
    
    @IBInspectable
    public var maxValue: CGFloat = 0.0 {
        didSet {
            updateSectionsCount()
        }
    }
    
    private func updateSectionsCount() {
        guard minValue < maxValue else {
            return
        }
        
        if let values = values {
            var sections = (values.count / Int(numberOfTicksBetweenValues + 1)) + 2
            
            if values.count % Int(numberOfTicksBetweenValues + 1) > 0 {
                sections += 1
            }
            
            sectionsCount = sections
        } else {
            let items = maxValue - minValue + 1.0
            
            if items > 1 {
                sectionsCount = Int(items) + 2
            } else {
                sectionsCount = 0
            }
        }
    }
    
    @IBInspectable
    public var numberOfTicksBetweenValues: UInt = 2 {
        didSet {
            tickValue = 1.0 / CGFloat(numberOfTicksBetweenValues + 1)
            
            updateSectionsCount()
        }
    }
    
    public var currentTransform: CGAffineTransform = CGAffineTransformIdentity {
        didSet {
            collectionView.reloadData()
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
        
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0

        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true

        collectionView.registerClass(SlidePickerCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        
        maskLayer = CALayer()
        
        maskLayer.frame = CGRectZero
        maskLayer.backgroundColor = UIColor.clearColor().CGColor
        
        maskLeftLayer = CAGradientLayer()

        maskLeftLayer.frame = maskLayer.bounds
        maskLeftLayer.colors = [UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor, UIColor.blackColor().CGColor]
        maskLeftLayer.startPoint = CGPointMake(0.1, 0.0)
        maskLeftLayer.endPoint = CGPointMake(0.9, 0.0)

        maskRightLayer = CAGradientLayer()
        
        maskRightLayer.frame = maskLayer.bounds
        maskRightLayer.colors = [UIColor.blackColor().CGColor, UIColor.blackColor().colorWithAlphaComponent(0.0).CGColor]
        maskRightLayer.startPoint = CGPointMake(0.1, 0.0)
        maskRightLayer.endPoint = CGPointMake(0.9, 0.0)

        maskLayer.addSublayer(maskLeftLayer)
        maskLayer.addSublayer(maskRightLayer)
        
        uiBlockView = UIView(frame: self.bounds)
        
//        layer.addSublayer(maskLayer)
    }
   
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.frame = bounds
        
        centerView?.center = CGPointMake(frame.size.width / 2,
                                         centerViewOffsetY + (frame.size.height / 2) - 2)
        if gradientMaskEnabled {
            let gradientMaskWidth = frame.size.width / 2
            
            maskLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
            maskLeftLayer.frame = CGRect(x: 0, y: 0, width: gradientMaskWidth, height: frame.size.height)
            maskRightLayer.frame = CGRect(x: frame.size.width - gradientMaskWidth, y: 0, width: gradientMaskWidth, height: frame.size.height)
        } else {
            maskLayer.frame = CGRectZero
            maskLeftLayer.frame = maskLayer.bounds
            maskRightLayer.frame = maskLayer.bounds
        }
        
        uiBlockView.frame = bounds
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        layoutSubviews()
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        guard sectionsCount > 2 else {
            return CGSizeZero
        }
        
        let regularCellSize = CGSizeMake(spaceBetweenTicks, bounds.height)
        
        if (indexPath.section == 0) || (indexPath.section == (sectionsCount - 1)) {
            if fillSides {
                let sideItems = (Int(frame.size.width / spaceBetweenTicks) + 2) / 2

                if (indexPath.section == 0 && indexPath.row == 0) ||
                    (indexPath.section == sectionsCount - 1 && indexPath.row == sideItems - 1)  {
                    
                    return CGSizeMake((spaceBetweenTicks / 2) - SlidePickerCell.strokeWidth, bounds.height)
                } else {
                    return regularCellSize
                }
            } else {
                return CGSizeMake((bounds.width / 2) - (spaceBetweenTicks / 2), bounds.height)
            }
        }
        
        return regularCellSize
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard sectionsCount > 2 else {
            return 0
        }
        
        if (section == 0) || (section >= (sectionsCount - 1)) {
            let sideItems = Int(frame.size.width / spaceBetweenTicks) + 2
            
            return fillSides ? sideItems / 2 : 1
        } else {
            if let values = values {
                let elements = (section - 1) * Int(numberOfTicksBetweenValues + 1)
                let rows = values.count - elements
                
                if rows > 0 {
                    return min(rows, Int(numberOfTicksBetweenValues + 1))
                } else {
                    return 0
                }
            } else {
                if section >= (sectionsCount - 2) {
                    return 1
                } else {
                    return Int(numberOfTicksBetweenValues) + 1
                }
            }
        }
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! SlidePickerCell
        
        cell.indexPath = indexPath
        cell.tickColor = tickColor
        cell.showTickLabels = showTickLabels
        cell.highlightTick = false
        cell.currentTransform = currentTransform
        cell.showPlusForPositiveValues = showPlusForPositiveValues

        if indexPath.section == 0 {
            cell.updateValue(invertValues ? CGFloat.max : CGFloat.min, type: fillSides ? .BigStroke : .Empty)
        } else if indexPath.section == sectionsCount - 1 {
            cell.updateValue(invertValues ? CGFloat.min : CGFloat.max, type: fillSides ? .BigStroke : .Empty)
        } else {
            if let values = values {
                cell.highlightTick = false
                
                let index = (indexPath.section - 1) * Int(numberOfTicksBetweenValues + 1) + indexPath.row
                let currentValue = values[index]
                
                cell.updateValue(currentValue, type: allTicksWithSameSize || indexPath.row == 0 ? .BigStroke : .SmallStroke)
            } else {
                let currentValue = invertValues ? maxValue - CGFloat(indexPath.section - 1) : minValue + CGFloat(indexPath.section - 1)

                if indexPath.row == 0 {
                    if highlightCenterTick {
                        cell.highlightTick = (currentValue == ((maxValue - minValue) * 0.5 + minValue))
                    } else {
                        cell.highlightTick = false
                    }
                    
                    cell.updateValue(currentValue, type: .BigStroke)
                } else {
                    let value = invertValues ? currentValue - tickValue * CGFloat(indexPath.row) : currentValue + tickValue * CGFloat(indexPath.row)
                    cell.showTickLabels = allTicksWithSameSize ? false : showTickLabels
                    cell.updateValue(value, type: allTicksWithSameSize ? .BigStroke : .SmallStroke)
                }
            }
        }
        
        return cell
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sectionsCount
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        updateSelectedValue(true)
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateSelectedValue(true)
    }
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        updateSelectedValue(false)
        
        let offset = scrollView.contentOffset.x
        let contentSize = scrollView.contentSize.width
        
        if offset <= 0 {
            delegate?.didChangeContentOffset(offset, progress: 0)
        } else if offset >= contentSize - frame.size.width {
            delegate?.didChangeContentOffset(offset - contentSize + frame.size.width, progress: 1)
        } else {
            delegate?.didChangeContentOffset(0, progress: offset / (scrollView.contentSize.width - frame.size.width))
        }
    }
    
    public func scrollToValue(value: CGFloat, animated: Bool) {
        var indexPath: NSIndexPath?
        
        guard sectionsCount > 0 else {
            return
        }
        
        if let values = values {
            var valueIndex = 0
            
            for index in 0..<values.count {
                if value == values[index] {
                    valueIndex = index
                    break
                }
            }
            
            let section = (valueIndex / Int(numberOfTicksBetweenValues + 1))
            let row = valueIndex - (section * Int(numberOfTicksBetweenValues + 1))

            indexPath = NSIndexPath(forRow: row, inSection: section + 1)
            
            let cell = collectionView(collectionView, cellForItemAtIndexPath: indexPath!) as? SlidePickerCell
            
            if let cell = cell where cell.value == value {
                delegate?.didSelectValue(cell.value)
                collectionView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .CenteredHorizontally, animated: animated)
            }
        } else {
            for i in 1 ... sectionsCount - 1 {
                indexPath = NSIndexPath(forRow: 0, inSection: i)
                
                let cell = collectionView(collectionView, cellForItemAtIndexPath: indexPath!) as? SlidePickerCell
                
                if let cell = cell where cell.value == value {
                    delegate?.didSelectValue(cell.value)
                    collectionView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .CenteredHorizontally, animated: animated)
                    
                    break
                }
            }
        }
    }
    
    public func increaseValue() {
        let point = CGPointMake(collectionView.center.x + collectionView.contentOffset.x + spaceBetweenTicks * 2 / 3,
                                collectionView.center.y + collectionView.contentOffset.y)
        
        scrollToNearestCellAtPoint(point)
    }
    
    public func decreaseValue() {
        let point = CGPointMake(collectionView.center.x + collectionView.contentOffset.x - spaceBetweenTicks * 2 / 3,
            collectionView.center.y + collectionView.contentOffset.y)
        
        scrollToNearestCellAtPoint(point)
    }
    
    private func updateSelectedValue(tryToSnap: Bool) {
        if snapEnabled {
            let initialPinchPoint = CGPointMake(collectionView.center.x + collectionView.contentOffset.x,
                                                collectionView.center.y + collectionView.contentOffset.y)
            
            scrollToNearestCellAtPoint(initialPinchPoint, skipScroll: fireValuesOnScrollEnabled && !tryToSnap)
        } else {
            let percent = collectionView.contentOffset.x / (collectionView.contentSize.width - bounds.width)
            let absoluteValue = percent * (maxValue - minValue)
            let currentValue = invertValues ? min(max(maxValue - absoluteValue, minValue), maxValue) : max(min(absoluteValue + minValue, maxValue), minValue)
            
            delegate?.didSelectValue(currentValue)
        }
    }
    
    private func scrollToNearestCellAtPoint(point: CGPoint, skipScroll: Bool = false) {
        var centerCell: SlidePickerCell?
        
        let indexPath = collectionView.indexPathForItemAtPoint(point)
        
        if let iPath = indexPath {
            if (iPath.section == 0) || (iPath.section == (sectionsCount - 1)) {
                return
            }
            
            centerCell = self.collectionView(collectionView, cellForItemAtIndexPath: iPath) as? SlidePickerCell
        }
        
        guard let cell = centerCell else {
            return
        }
        
        delegate?.didSelectValue(cell.value)
        
        if !skipScroll {
            collectionView.scrollToItemAtIndexPath(indexPath!, atScrollPosition: .CenteredHorizontally, animated: true)
        }
    }
}

public enum SlidePickerCellType {
    case Empty
    case BigStroke
    case SmallStroke
}

public class SlidePickerCell: UICollectionViewCell {
    public static var signWidth: CGFloat = {
        let sign = "-"
        let maximumTextSize = CGSizeMake(100, 100)
        let textString = sign as NSString
        let font = UIFont.systemFontOfSize(12.0)
        
        let rect = textString.boundingRectWithSize(maximumTextSize, options: .UsesLineFragmentOrigin,
                                                   attributes: [NSFontAttributeName: font], context: nil)

        return (rect.width / 2) + 1
    }()
    
    public static let strokeWidth: CGFloat = 1.5
    
    public var showTickLabels = true
    public var showPlusForPositiveValues = true
    public var highlightTick = false

    private var type = SlidePickerCellType.Empty
    
    public var value: CGFloat = 0.0 {
        didSet {
            let strValue = String(format: "%0.0f", value)
            
            if value > 0.00001 && showPlusForPositiveValues {
                valueLabel.text = "+" + strValue
            } else {
                valueLabel.text = strValue
            }
        }
    }
    
    public var indexPath: NSIndexPath?
    
    private let strokeView = UIView()
    private let valueLabel = UILabel()
    private let strokeWidth: CGFloat = SlidePickerCell.strokeWidth
    private var bigStrokePaddind: CGFloat = 4.0
    private var smallStrokePaddind: CGFloat = 8.0
    
    public var currentTransform: CGAffineTransform = CGAffineTransformIdentity {
        didSet {
            valueLabel.transform = currentTransform
        }
    }
    
    public var tickColor = UIColor.whiteColor() {
        didSet {
            strokeView.backgroundColor = tickColor
            valueLabel.textColor = tickColor
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
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        strokeView.alpha = 0.0
        valueLabel.alpha = 0.0
        
        indexPath = nil
    }
    
    public func updateValue(value: CGFloat, type: SlidePickerCellType) {
        self.value = value
        self.type = type
        
        layoutSubviews()
    }
    
    private func commonInit() {
        strokeView.backgroundColor = UIColor.whiteColor()
        strokeView.alpha = 0.0
        strokeView.layer.masksToBounds = true
        strokeView.layer.cornerRadius = strokeWidth / 2
        
        valueLabel.textAlignment = .Center
        valueLabel.font = UIFont.systemFontOfSize(12.0)
        valueLabel.textColor = UIColor.whiteColor()
        valueLabel.alpha = 0.0

        contentView.addSubview(strokeView)
        contentView.addSubview(valueLabel)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = frame.size.height
        let xShift: CGFloat = (showPlusForPositiveValues && value > 0.0001) || value < -0.0001 ? SlidePickerCell.signWidth : 0.0
        
        switch type {
            case .Empty:
                strokeView.alpha = 0.0
                valueLabel.alpha = 0.0
                break
                
            case .BigStroke:
                let widthAddition: CGFloat = highlightTick ? 0.5 : 0.0

                strokeView.alpha = 1.0
                valueLabel.alpha = showTickLabels ? 1.0 : 0.0
                
                if showTickLabels {
                    valueLabel.frame = CGRectMake(-5 - xShift, 0, frame.size.width + 10, height / 3)
                } else {
                    valueLabel.frame = CGRectZero
                }
                
                strokeView.frame = CGRectMake((frame.size.width / 2) - (strokeWidth / 2) - widthAddition,
                                              (height / 3) + bigStrokePaddind, strokeWidth + widthAddition * 2,
                                              (height / 2) - (bigStrokePaddind * 2))

                strokeView.layer.cornerRadius = strokeView.frame.width
                
                break

            case .SmallStroke:
                strokeView.alpha = 1.0
                valueLabel.alpha = 0.0
                
                if showTickLabels {
                    valueLabel.frame = CGRectMake(-xShift, 0, frame.size.width, height / 2)
                } else {
                    valueLabel.frame = CGRectZero
                }
                
                strokeView.frame = CGRectMake((frame.size.width / 2) - (strokeWidth / 2),
                                              (height / 3) + smallStrokePaddind, strokeWidth,
                                              (height / 2) - (smallStrokePaddind * 2))
                
                strokeView.layer.cornerRadius = strokeView.frame.width
                
                break
        }
    }
}

internal extension UIImage {
    internal func tintImage(color: UIColor) -> UIImage {
        let scale: CGFloat = 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, 0, size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        CGContextSetBlendMode(context, .Normal)
        CGContextDrawImage(context, rect, CGImage)
        
        CGContextSetBlendMode(context, .SourceIn)
        color.setFill()
        CGContextFillRect(context, rect)
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return coloredImage.imageWithRenderingMode(.AlwaysOriginal)
    }
}
