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
    func didSelectValue(_ value: CGFloat)
    func didChangeContentOffset(_ offset: CGFloat, progress: CGFloat)
}

@IBDesignable
open class SlidePicker: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    open var delegate: SlidePickerDelegate?
    
    @IBInspectable
    open var gradientMaskEnabled: Bool = false {
        didSet {
            layer.mask = gradientMaskEnabled ? maskLayer : nil
            
            layoutSubviews()
        }
    }
    
    @IBInspectable
    open var invertValues: Bool = false {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var fillSides: Bool = false {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var allTicksWithSameSize: Bool = false {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var blockedUI: Bool = false {
        didSet {
            uiBlockView.removeFromSuperview()
            
            if blockedUI {
                addSubview(uiBlockView)
            }
            
            layoutSubviews()
        }
    }
    
    @IBInspectable
    open var showPlusForPositiveValues: Bool = true {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var snapEnabled: Bool = true
    
    @IBInspectable
    open var fireValuesOnScrollEnabled: Bool = true
    
    @IBInspectable
    open var showTickLabels: Bool = true {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var highlightCenterTick: Bool = true {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var bounces: Bool = false {
        didSet {
            collectionView.bounces = bounces
        }
    }
    
    @IBInspectable
    open var spaceBetweenTicks: CGFloat = 20.0 {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var centerViewOffsetY: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    fileprivate let cellId = "collectionViewCellId"
    
    fileprivate var flowLayout: SlidePickerFlowLayout!
    fileprivate var collectionView: UICollectionView!
    fileprivate var tickValue: CGFloat = 1.0
    
    fileprivate var maskLayer: CALayer!
    fileprivate var maskLeftLayer: CAGradientLayer!
    fileprivate var maskRightLayer: CAGradientLayer!
    fileprivate var uiBlockView: UIView!
    fileprivate var reloadTimer: Timer?
    
    open var centerView: UIView? {
        didSet {
            if let centerView = centerView {
                centerViewOffsetY = 0.0
                
                addSubview(centerView)
            }
        }
    }
    
    open var values: [CGFloat]? {
        didSet {
            guard let values = values , values.count > 1 else { return; }
            
            updateSectionsCount()
            
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var tickColor: UIColor = UIColor.white {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    fileprivate var sectionsCount: Int = 0 {
        didSet {
            requestCollectionViewReloading()
        }
    }
    
    @IBInspectable
    open var minValue: CGFloat = 0.0 {
        didSet {
            updateSectionsCount()
        }
    }
    
    @IBInspectable
    open var maxValue: CGFloat = 0.0 {
        didSet {
            updateSectionsCount()
        }
    }
    
    @IBInspectable
    open var isVertical: Bool = false {
        didSet {
            updateCollectionLayout()
        }
    }
    
    fileprivate func updateSectionsCount() {
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
    open var numberOfTicksBetweenValues: UInt = 2 {
        didSet {
            tickValue = 1.0 / CGFloat(numberOfTicksBetweenValues + 1)
            
            updateSectionsCount()
        }
    }
    
    open var currentTransform: CGAffineTransform = CGAffineTransform.identity {
        didSet {
            requestCollectionViewReloading()
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
    
    open func commonInit() {
        isUserInteractionEnabled = true
        
        flowLayout = SlidePickerFlowLayout()
        flowLayout.update(withDirection: self.isVertical ? UICollectionViewScrollDirection.vertical : UICollectionViewScrollDirection.horizontal)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.bounces = false
        collectionView.allowsSelection = false
        collectionView.delaysContentTouches = true
        
        collectionView.register(SlidePickerCell.self, forCellWithReuseIdentifier: cellId)
        updateCollectionLayout()
        
        addSubview(collectionView)
        
        maskLayer = CALayer()
        
        maskLayer.frame = CGRect.zero
        maskLayer.backgroundColor = UIColor.clear.cgColor
        
        maskLeftLayer = CAGradientLayer()
        maskLeftLayer.frame = maskLayer.bounds
        maskLeftLayer.colors = [UIColor.black.withAlphaComponent(0.0).cgColor, UIColor.black.cgColor]
        
        maskRightLayer = CAGradientLayer()
        maskRightLayer.frame = maskLayer.bounds
        maskRightLayer.colors = [UIColor.black.cgColor, UIColor.black.withAlphaComponent(0.0).cgColor]
        
        maskLayer.addSublayer(maskLeftLayer)
        maskLayer.addSublayer(maskRightLayer)
        
        uiBlockView = UIView(frame: self.bounds)
    }
    
    func updateCollectionLayout(){
        flowLayout = SlidePickerFlowLayout()
        flowLayout.update(withDirection: self.isVertical ? UICollectionViewScrollDirection.vertical : UICollectionViewScrollDirection.horizontal)
        self.collectionView.setCollectionViewLayout(flowLayout, animated: false)
    }
    
    fileprivate func requestCollectionViewReloading() {
        reloadTimer?.invalidate()
        
        reloadTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(SlidePicker.reloadCollectionView), userInfo: nil, repeats: false)
    }
    
    @objc func reloadCollectionView() {
        reloadTimer?.invalidate()
        
        collectionView.reloadData()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame = bounds
        
        centerView?.center = CGPoint(x: frame.size.width / 2, y: centerViewOffsetY + (frame.size.height / 2) - 2)
        if gradientMaskEnabled {
            
            if isVertical{
                let gradientMaskHeight = frame.size.height / 2
                maskLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
                maskLeftLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: gradientMaskHeight)
                maskRightLayer.frame = CGRect(x: 0, y: frame.size.height - gradientMaskHeight, width: frame.size.width, height: gradientMaskHeight)
                
                maskLeftLayer.startPoint = CGPoint(x: 0, y: 0.1)
                maskLeftLayer.endPoint = CGPoint(x: 0, y: 0.9)
                maskRightLayer.startPoint = CGPoint(x: 0, y: 0.1)
                maskRightLayer.endPoint = CGPoint(x: 0, y: 0.9)
            }else{
                let gradientMaskWidth = frame.size.width / 2
                maskLayer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
                maskLeftLayer.frame = CGRect(x: 0, y: 0, width: gradientMaskWidth, height: frame.size.height)
                maskRightLayer.frame = CGRect(x: frame.size.width - gradientMaskWidth, y: 0, width: gradientMaskWidth, height: frame.size.height)
                
                maskLeftLayer.startPoint = CGPoint(x: 0.1, y: 0)
                maskLeftLayer.endPoint = CGPoint(x: 0.9, y: 0)
                maskRightLayer.startPoint = CGPoint(x: 0.1, y: 0)
                maskRightLayer.endPoint = CGPoint(x: 0.9, y: 0)
            }
            
        } else {
            maskLayer.frame = CGRect.zero
            maskLeftLayer.frame = maskLayer.bounds
            maskRightLayer.frame = maskLayer.bounds
        }
        
        uiBlockView.frame = bounds
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        layoutSubviews()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard sectionsCount > 2 else {
            return CGSize.zero
        }
        
        let regularCellSize: CGSize
        if isVertical{
            regularCellSize = CGSize(width: bounds.width, height: spaceBetweenTicks)
        }else{
            regularCellSize = CGSize(width: spaceBetweenTicks, height: bounds.height)
        }
        
        if indexPath.section == 0 || indexPath.section == (sectionsCount - 1) {
            if fillSides {
                let sideItems = (Int(frame.size.width / spaceBetweenTicks) + 2) / 2
                
                if (indexPath.section == 0 && indexPath.row == 0) ||
                    (indexPath.section == sectionsCount - 1 && indexPath.row == sideItems - 1)  {
                    
                    if isVertical{
                        return CGSize(width: bounds.width, height: spaceBetweenTicks)
                    }else{
                        return CGSize(width: (spaceBetweenTicks / 2) - SlidePickerCell.strokeWidth, height: bounds.height)
                    }
                } else {
                    if isVertical{
                        return CGRect.zero.size
                    }else{
                        return regularCellSize
                    }
                    
                }
            } else {
                if isVertical{
                    return CGSize(width: bounds.width, height: (bounds.height - spaceBetweenTicks)/2 )
                }else{
                    return CGSize(width: (bounds.width - spaceBetweenTicks)/2, height: bounds.height)
                }
            }
        }
        
        return regularCellSize
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SlidePickerCell
        
        cell.indexPath = indexPath
        cell.tickColor = tickColor
        cell.showTickLabels = showTickLabels
        cell.highlightTick = false
        cell.currentTransform = currentTransform
        cell.showPlusForPositiveValues = showPlusForPositiveValues
        cell.isVertical = self.isVertical
        
        if indexPath.section == 0 {
            cell.updateValue(invertValues ? CGFloat.greatestFiniteMagnitude : CGFloat.leastNormalMagnitude, type: fillSides ? .bigStroke : .empty)
        } else if indexPath.section == sectionsCount - 1 {
            cell.updateValue(invertValues ? CGFloat.leastNormalMagnitude : CGFloat.greatestFiniteMagnitude, type: fillSides ? .bigStroke : .empty)
        } else {
            if let values = values {
                cell.highlightTick = false
                
                let index = (indexPath.section - 1) * Int(numberOfTicksBetweenValues + 1) + indexPath.row
                let currentValue = values[index]
                
                cell.updateValue(currentValue, type: allTicksWithSameSize || indexPath.row == 0 ? .bigStroke : .smallStroke)
            } else {
                let currentValue = invertValues ? maxValue - CGFloat(indexPath.section - 1) : minValue + CGFloat(indexPath.section - 1)
                
                if indexPath.row == 0 {
                    if highlightCenterTick {
                        cell.highlightTick = (currentValue == ((maxValue - minValue) * 0.5 + minValue))
                    } else {
                        cell.highlightTick = false
                    }
                    
                    cell.updateValue(currentValue, type: .bigStroke)
                } else {
                    let value = invertValues ? currentValue - tickValue * CGFloat(indexPath.row) : currentValue + tickValue * CGFloat(indexPath.row)
                    cell.showTickLabels = allTicksWithSameSize ? false : showTickLabels
                    cell.updateValue(value, type: allTicksWithSameSize ? .bigStroke : .smallStroke)
                }
            }
        }
        
        return cell
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionsCount
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateSelectedValue(true)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateSelectedValue(true)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSelectedValue(false)
        updateCurrentProgress()
    }
    
    open func updateCurrentProgress() {
        let offset = collectionView.contentOffset.x
        let contentSize = collectionView.contentSize.width
        
        if offset <= 0 {
            delegate?.didChangeContentOffset(offset, progress: 0)
        } else if offset >= contentSize - frame.size.width {
            delegate?.didChangeContentOffset(offset - contentSize + frame.size.width, progress: 1)
        } else {
            delegate?.didChangeContentOffset(0, progress: offset / (collectionView.contentSize.width - frame.size.width))
        }
    }
    
    open func scrollToValue(_ value: CGFloat, animated: Bool) {
        var indexPath: IndexPath?
        
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
            
            indexPath = IndexPath(row: row, section: section + 1)
            
            let cell = collectionView(collectionView, cellForItemAt: indexPath!) as? SlidePickerCell
            
            if let cell = cell , cell.value == value {
                delegate?.didSelectValue(cell.value)
                collectionView.scrollToItem(at: indexPath!, at: isVertical ? .centeredVertically : .centeredHorizontally, animated: animated)
            }
        } else {
            if snapEnabled {
                for i in 1..<sectionsCount {
                    let itemsCount = self.collectionView(collectionView, numberOfItemsInSection: i)
                    
                    for j in 0..<itemsCount {
                        indexPath = IndexPath(row: j, section: i)
                        
                        let cell = collectionView(collectionView, cellForItemAt: indexPath!) as? SlidePickerCell
                        
                        if let cell = cell , cell.value == value {
                            delegate?.didSelectValue(cell.value)
                            collectionView.scrollToItem(at: indexPath!, at: isVertical ? .centeredVertically : .centeredHorizontally, animated: animated)
                            
                            break
                        }
                    }
                }
            } else {
                collectionView.reloadData()
                let popTime = DispatchTime.now() + Double(Int64(0.5 * CGFloat(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                
                DispatchQueue.main.asyncAfter(deadline: popTime) {
                    let absoluteValue = value - self.minValue
                    let percent = absoluteValue / (self.maxValue - self.minValue)
                    let absolutePercent = self.invertValues ? (1.0 - percent) : percent
                    
                    if self.isVertical {
                        let offsetY = absolutePercent * (self.collectionView.contentSize.height - self.bounds.height)
                        self.collectionView.contentOffset = CGPoint(x: self.collectionView.contentOffset.x, y: offsetY)
                    }
                    else {
                        let offsetX = absolutePercent * (self.collectionView.contentSize.width - self.bounds.width)
                        self.collectionView.contentOffset = CGPoint(x: offsetX, y: self.collectionView.contentOffset.y)
                    }
                }
            }
        }
    }
    
    open func increaseValue() {
        let point = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x + spaceBetweenTicks * 2 / 3,
                            y: collectionView.center.y + collectionView.contentOffset.y)
        
        scrollToNearestCellAtPoint(point)
    }
    
    open func decreaseValue() {
        let point = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x - spaceBetweenTicks * 2 / 3,
                            y: collectionView.center.y + collectionView.contentOffset.y)
        
        scrollToNearestCellAtPoint(point)
    }
    
    fileprivate func updateSelectedValue(_ tryToSnap: Bool) {
        if snapEnabled {
            let initialPinchPoint = CGPoint(x: collectionView.center.x + collectionView.contentOffset.x,
                                            y: collectionView.center.y + collectionView.contentOffset.y)
            
            scrollToNearestCellAtPoint(initialPinchPoint, skipScroll: fireValuesOnScrollEnabled && !tryToSnap)
        } else {
            
            let percent: CGFloat
            if isVertical {
                percent = collectionView.contentOffset.y  / (collectionView.contentSize.height - bounds.height)
            }
            else {
                percent = collectionView.contentOffset.x  / (collectionView.contentSize.width - bounds.width)
            }
            let absoluteValue = percent * (maxValue - minValue)
            let currentValue = invertValues ? min(max(maxValue - absoluteValue, minValue), maxValue) : max(min(absoluteValue + minValue, maxValue), minValue)
            
            delegate?.didSelectValue(currentValue)
        }
    }
    
    fileprivate func scrollToNearestCellAtPoint(_ point: CGPoint, skipScroll: Bool = false) {
        var centerCell: SlidePickerCell?
        
        let indexPath = collectionView.indexPathForItem(at: point)
        
        if let iPath = indexPath {
            if ((iPath as NSIndexPath).section == 0) || ((iPath as NSIndexPath).section == (sectionsCount - 1)) {
                return
            }
            
            centerCell = self.collectionView(collectionView, cellForItemAt: iPath) as? SlidePickerCell
        }
        
        guard let cell = centerCell else {
            return
        }
        
        delegate?.didSelectValue(cell.value)
        
        if !skipScroll {
            if isVertical {
                collectionView.scrollToItem(at: indexPath!, at: .centeredVertically, animated: true)
            }
            else {
                collectionView.scrollToItem(at: indexPath!, at: .centeredHorizontally, animated: true)
            }
        }
    }
}

public enum SlidePickerCellType {
    case empty
    case bigStroke
    case smallStroke
}

open class SlidePickerCell: UICollectionViewCell {
    open static var signWidth: CGFloat = {
        let sign = "-"
        let maximumTextSize = CGSize(width: 100, height: 100)
        let textString = sign as NSString
        let font = UIFont.systemFont(ofSize: 12.0)
        
        let rect = textString.boundingRect(with: maximumTextSize, options: .usesLineFragmentOrigin,
                                           attributes: [kCTFontAttributeName as NSAttributedStringKey: font], context: nil)
        
        return (rect.width / 2) + 1
    }()
    
    open static var strokeWidth: CGFloat = 1.5
    
    open var showTickLabels = true
    open var showPlusForPositiveValues = true
    open var highlightTick = false
    open var isVertical = false
    
    fileprivate var type = SlidePickerCellType.empty
    
    open var value: CGFloat = 0.0 {
        didSet {
            let strValue = String(format: "%0.0f", value)
            
            if value > 0.00001 && showPlusForPositiveValues {
                valueLabel.text = "+" + strValue
            } else {
                valueLabel.text = strValue
            }
        }
    }
    
    open var indexPath: IndexPath?
    
    fileprivate let strokeView = UIView()
    fileprivate let valueLabel = UILabel()
    fileprivate let strokeWidth: CGFloat = SlidePickerCell.strokeWidth
    fileprivate var bigStrokePaddind: CGFloat = 4.0
    fileprivate var smallStrokePaddind: CGFloat = 8.0
    
    open var currentTransform: CGAffineTransform = CGAffineTransform.identity {
        didSet {
            valueLabel.transform = currentTransform
        }
    }
    
    open var tickColor = UIColor.white {
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
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        strokeView.alpha = 0.0
        valueLabel.alpha = 0.0
        
        indexPath = nil
    }
    
    open func updateValue(_ value: CGFloat, type: SlidePickerCellType) {
        self.value = value
        self.type = type
        
        layoutSubviews()
    }
    
    fileprivate func commonInit() {
        strokeView.backgroundColor = UIColor.white
        strokeView.alpha = 0.0
        strokeView.layer.masksToBounds = true
        strokeView.layer.cornerRadius = strokeWidth / 2
        
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 12.0)
        valueLabel.textColor = UIColor.white
        valueLabel.alpha = 0.0
        
        contentView.addSubview(strokeView)
        contentView.addSubview(valueLabel)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = frame.size.height
        let xShift: CGFloat = (showPlusForPositiveValues && value > 0.0001) || value < -0.0001 ? SlidePickerCell.signWidth : 0.0
        
        switch type {
        case .empty:
            strokeView.alpha = 0.0
            valueLabel.alpha = 0.0
            break
            
        case .bigStroke:
            let widthAddition: CGFloat = highlightTick ? 0.5 : 0.0
            
            strokeView.alpha = 1.0
            valueLabel.alpha = showTickLabels ? 1.0 : 0.0
            
            if showTickLabels {
                valueLabel.frame = CGRect(x: -5 - xShift, y: 0, width: frame.size.width + 10, height: height / 3)
            } else {
                valueLabel.frame = CGRect.zero
            }
            
            
            if isVertical{
                strokeView.frame = CGRect(x: bigStrokePaddind, y: (frame.size.height - strokeWidth + widthAddition * 2)/2, width: frame.size.width - bigStrokePaddind*2, height: strokeWidth + widthAddition * 2)
                strokeView.layer.cornerRadius = strokeWidth + widthAddition * 2
            }else{
                if showTickLabels {
                    strokeView.frame = CGRect(x: (frame.size.width / 2) - (strokeWidth / 2) - widthAddition,
                                              y: (height / 3) + bigStrokePaddind,
                                              width: strokeWidth + widthAddition * 2,
                                              height: (height / 2) - (bigStrokePaddind * 2))
                }
                else {
                    strokeView.frame = CGRect(x: (frame.size.width / 2) - (strokeWidth / 2) - widthAddition,
                                              y: bigStrokePaddind * 2, width: strokeWidth + widthAddition * 2,
                                              height: height  - (bigStrokePaddind * 4))
                }
                strokeView.layer.cornerRadius = strokeWidth + widthAddition * 2
            }
            
            break
            
        case .smallStroke:
            strokeView.alpha = 1.0
            valueLabel.alpha = 0.0
            
            if showTickLabels {
                valueLabel.frame = CGRect(x: -xShift, y: 0, width: frame.size.width, height: height / 2)
            } else {
                valueLabel.frame = CGRect.zero
            }
            
            if isVertical{
                strokeView.frame = CGRect(x: smallStrokePaddind*2, y: (frame.size.height - strokeWidth)/2, width: frame.size.width - smallStrokePaddind*4, height: strokeWidth)
                strokeView.layer.cornerRadius = strokeWidth
            }else{
                if showTickLabels {
                    strokeView.frame = CGRect(x: (frame.size.width / 2) - (strokeWidth / 2),
                                              y: (height / 3) + smallStrokePaddind, width: strokeWidth,
                                              height: (height / 2) - (smallStrokePaddind * 2))
                }
                else {
                    strokeView.frame = CGRect(x: (frame.size.width / 2) - (strokeWidth / 2),
                                              y: smallStrokePaddind * 2,
                                              width: strokeWidth,
                                              height: height - smallStrokePaddind * 4)
                }
                
                strokeView.layer.cornerRadius = strokeView.frame.width
            }
            
            
            break
        }
    }
}

internal extension UIImage {
    internal func tintImage(_ color: UIColor) -> UIImage {
        let scale: CGFloat = 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0, y: size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        context?.setBlendMode(.normal)
        context?.draw(cgImage!, in: rect)
        
        context?.setBlendMode(.sourceIn)
        color.setFill()
        context?.fill(rect)
        
        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return coloredImage!.withRenderingMode(.alwaysOriginal)
    }
}
