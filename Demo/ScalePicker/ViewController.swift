//
//  ViewController.swift
//  ScalePickerDemo
//
//  Created by Dmitry on 14/3/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import UIKit
import XLForm

class ViewController: XLFormViewController, ScalePickerDelegate {
    typealias FormButtonHandler = () -> Void

    private let scaleView = ScalePicker(frame: CGRect(x: 0, y: 0, width: Utils.ScreenWidth, height: 60))
    private let rightButton = UIImageView(image: UIImage(named: "speedAuto"))
    private let leftButton = UIImageView(image: UIImage(named: "speedManual"))

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: Utils.ScreenWidth, height: 70))
        
        headerView.isUserInteractionEnabled = true
        headerView.backgroundColor = Utils.BackgroundColor
                
        scaleView.center = CGPoint(x: headerView.frame.size.width / 2, y: headerView.frame.size.height / 2)
        scaleView.minValue = -3.0
        scaleView.maxValue = 3.0
        scaleView.numberOfTicksBetweenValues = 2
        scaleView.spaceBetweenTicks = 20.0
        scaleView.showTickLabels = false
        scaleView.delegate = self
        scaleView.snapEnabled = true
        scaleView.bounces = true
        scaleView.tickColor = UIColor.white
        scaleView.centerArrowImage = UIImage(named: "arrowPointer")
        scaleView.gradientMaskEnabled = true
        scaleView.blockedUI = false
        scaleView.sidePadding = 80.0
        scaleView.title = "Speed"
        scaleView.showCurrentValue = true
        scaleView.trackProgress = true
        scaleView.invertProgress = true
        scaleView.valueFormatter = {(value: CGFloat) -> NSAttributedString in
            let attrs = [NSAttributedString.Key.foregroundColor: UIColor.white,
                         NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12.0)]
            
            let text = value.format(f: ".2") + " auto"
            let attrText = NSMutableAttributedString(string: text, attributes: attrs)
            return attrText
        }
        
        scaleView.rightView = rightButton
        
        // Optionally you can set array of values for scale
//        scaleView.values = [32, 40, 50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600]

        DispatchQueue.main.async {
            self.scaleView.setInitialCurrentValue(0)
        }
        
        headerView.addSubview(scaleView)
        
        tableView.tableHeaderView = headerView
        
        initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: "Scale picker")
        
        form.rowNavigationOptions = XLFormRowNavigationOptions.enabled
        
        var section = XLFormSectionDescriptor.formSection(withTitle: "Actions")
        
        form.addFormSection(section)
        
        let _ = createButtonRow(tag: "increaseValue", title: "Increase value", section: section) { [unowned self]() -> Void in
            self.scaleView.increaseValue()
        }
        
        let _ = createButtonRow(tag: "decreaseValue", title: "Decrease value", section: section) { [unowned self]() -> Void in
            self.scaleView.decreaseValue()
        }
        
        let _ = createButtonRow(tag: "resetValue", title: "Reset value", section: section) { [unowned self]() -> Void in
            self.scaleView.reset()
        }
        
        
        let _ = createButtonRow(tag: "setValue", title: "Set value to 0 animated", section: section) { [unowned self]() -> Void in
//            self.scaleView.up
//            self.scaleView.elasticCurrentValue(value: 0, animated: true, notify: true)
        }
        
        let _ = createButtonRow(tag: "setValue", title: "Set value to 0 silent", section: section) { [unowned self]() -> Void in
//            self.scaleView.updateCurrentValue(value: 0, animated: false, notify: false)
        }
        
        section = XLFormSectionDescriptor.formSection(withTitle: "Properties")
        
        form.addFormSection(section)
        
        var row = XLFormRowDescriptor(tag: "minValue", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Min value")
        
        row.selectorOptions = ["-10.0", "-3.0", "-1.0", "0.0"]
        row.value = "-3.0"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? NSString
            
            if let updatedValue = updatedValue {
                self.scaleView.minValue = CGFloat(updatedValue.floatValue)
            }
        }

        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "maxValue", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Max value")
        
        row.selectorOptions = ["3.0", "5.0", "10.0"]
        row.value = "3.0"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? NSString
            
            if let updatedValue = updatedValue {
                self.scaleView.maxValue = CGFloat(updatedValue.floatValue)
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "ticks", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Ticks between values")
        
        row.selectorOptions = ["1", "2", "4", "5"]
        row.value = "2"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? NSString
            
            if let updatedValue = updatedValue {
                self.scaleView.numberOfTicksBetweenValues = UInt(updatedValue.intValue)
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "space", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Space between ticks")
        
        row.selectorOptions = ["10", "20", "30", "40"]
        row.value = "20"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? NSString
            
            if let updatedValue = updatedValue {
                self.scaleView.spaceBetweenTicks = CGFloat(updatedValue.floatValue)
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "show ticks", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Show ticks' labels")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "NO"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.showTickLabels = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "snap ticks", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Snap ticks")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.snapEnabled = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "bounces", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Bounces")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.bounces = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "tickColor", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Tick color")
        
        row.selectorOptions = ["White", "Red", "Green"]
        row.value = "White"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                if updatedValue == "White" {
                    self.scaleView.tickColor = UIColor.white
                } else if updatedValue == "Red" {
                    self.scaleView.tickColor = UIColor.red
                } else if updatedValue == "Green" {
                    self.scaleView.tickColor = UIColor.green
                }
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "gradient", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Gradient")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.gradientMaskEnabled = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "fireValuesOnScroll", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Values on scroll")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.fireValuesOnScrollEnabled = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "showPositiveSign", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Show positive sign")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.showPlusForPositiveValues = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "sidePadding", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Side padding")
        
        row.selectorOptions = ["0", "80", "150"]
        row.value = "80"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? NSString
            
            if let updatedValue = updatedValue {
                self.scaleView.sidePadding = CGFloat(updatedValue.floatValue)
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "title", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Title")
        
        row.selectorOptions = ["Speed", "Empty"]
        row.value = "Speed"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? NSString
            
            if let updatedValue = updatedValue {
                self.scaleView.title = updatedValue == "Speed" ? (updatedValue as String) : ""
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "showValue", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Show value")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.showCurrentValue = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "showLeftButton", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Show left view")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "NO"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.leftView = updatedValue == "YES" ? self.leftButton : nil
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "showRightButton", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Show right view")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.rightView = updatedValue == "YES" ? self.rightButton : nil
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "invertButton", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Invert values")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "NO"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.invertValues = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "valuePosition", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Value position")
        
        row.selectorOptions = ["Top", "Left"]
        row.value = "Top"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
//                self.scaleView.valuePosition = updatedValue == "Top" ? .Top : .Left
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "sameSizeTicks", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Ticks size")
        
        row.selectorOptions = ["Various", "Same"]
        row.value = "Various"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.allTicksWithSameSize = updatedValue == "Same"
            }
        }
        
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "fillSides", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Fill sides")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "NO"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.fillSides = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "elasticValue", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Elastic value")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "NO"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.elasticCurrentValue = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "trackProgress", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Track progress")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.trackProgress = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "invertProgress", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Invert progress")
        
        row.selectorOptions = ["YES", "NO"]
        row.value = "YES"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                self.scaleView.invertProgress = updatedValue == "YES"
            }
        }
        
        section.addFormRow(row)

        row = XLFormRowDescriptor(tag: "progressColor", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Progress color")
        
        row.selectorOptions = ["White", "Red", "Yellow"]
        row.value = "White"
        
        row.onChangeBlock = { [unowned self] (oldValue, newValue, rowDescriptor) -> Void in
            let updatedValue = newValue as? String
            
            if let updatedValue = updatedValue {
                if updatedValue == "White" {
                    self.scaleView.progressColor = UIColor.white
                } else if updatedValue == "Red" {
                    self.scaleView.progressColor = UIColor.red
                } else if updatedValue == "Yellow" {
                    self.scaleView.progressColor = UIColor.yellow
                }
            }
        }
        
        section.addFormRow(row)

        self.form = form
    }
    
    func createButtonRow(tag:String, title:String, section:XLFormSectionDescriptor, handler: @escaping FormButtonHandler) -> XLFormRowDescriptor {
        let row = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeButton, title:title)
        
        row.action.formBlock = { [unowned self] (sender: XLFormRowDescriptor!) -> Void in
            self.deselectFormRow(sender)
            
            handler()
        }
        
        section.addFormRow(row)
        
        return row
    }

    func didChangeScaleValue(_ picker: ScalePicker, value: CGFloat) {
        print("Changed scale picker value: \(value)")
    }
    
    func didBeginChangingValue(picker: ScalePicker) {
        print("Begin changing scale picker value")
    }
    
    func didEndChangingValue(picker: ScalePicker) {
        print("End changing scale picker value")
    }
    
}

private extension CGFloat {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
