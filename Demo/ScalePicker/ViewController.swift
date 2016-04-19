//
//  ViewController.swift
//  ScalePickerDemo
//
//  Created by Dmitry on 14/3/16.
//  Copyright © 2016 Dmitry Klimkin. All rights reserved.
//

import UIKit
import XLForm
import ScalePicker

class ViewController: XLFormViewController, ScalePickerDelegate {
    typealias FormButtonHandler = () -> Void

    private let scaleView = ScalePicker(frame: CGRectMake(0, 0, Utils.ScreenWidth, 50))

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerView = UIView(frame: CGRectMake(0, 0, Utils.ScreenWidth , 70))
        
        headerView.userInteractionEnabled = true
        headerView.backgroundColor = Utils.BackgroundColor
        
        scaleView.center = CGPointMake(headerView.frame.size.width / 2, headerView.frame.size.height / 2)
        scaleView.minValue = -3.0
        scaleView.maxValue = 3.0
        scaleView.numberOfTicksBetweenValues = 2
        scaleView.spaceBetweenTicks = 20.0
        scaleView.showTickLabels = true
        scaleView.delegate = self
        scaleView.snapEnabled = true
        scaleView.bounces = false
        scaleView.tickColor = UIColor.whiteColor()
        scaleView.centerArrowImage = UIImage(named: "arrowPointer")
        scaleView.gradientMaskEnabled = true

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * CGFloat(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.scaleView.setInitialCurrentValue(0.0)
        }
        
        headerView.addSubview(scaleView)
        
        tableView.tableHeaderView = headerView
        
        initializeForm()
    }
    
    func initializeForm() {
        let form = XLFormDescriptor(title: "Scale picker")
        
        form.rowNavigationOptions = XLFormRowNavigationOptions.Enabled
        
        var section = XLFormSectionDescriptor.formSectionWithTitle("Properties")
        
        form.addFormSection(section)
        
        var row = XLFormRowDescriptor(tag: "minValue", rowType: XLFormRowDescriptorTypeSelectorSegmentedControl, title: "Min value")
        
        row.selectorOptions = ["-10.0", "-3.0", "0.0"]
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
        row.value = "YES"
        
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
        row.value = "NO"
        
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
                    self.scaleView.tickColor = UIColor.whiteColor()
                } else if updatedValue == "Red" {
                    self.scaleView.tickColor = UIColor.redColor()
                } else if updatedValue == "Green" {
                    self.scaleView.tickColor = UIColor.greenColor()
                }
            }
        }
        
        section.addFormRow(row)
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Actions")
        
        form.addFormSection(section)

        createButtonRow("increaseValue", title: "Increase value", section: section) { [unowned self]() -> Void in
            self.scaleView.increaseValue()
        }

        createButtonRow("decreaseValue", title: "Decrease value", section: section) { [unowned self]() -> Void in
            self.scaleView.decreaseValue()
        }
        
        createButtonRow("resetValue", title: "Reset value", section: section) { [unowned self]() -> Void in
            self.scaleView.reset()
        }
        
        self.form = form
    }
    
    func createButtonRow(tag:String, title:String, section:XLFormSectionDescriptor, handler: FormButtonHandler) -> XLFormRowDescriptor {
        let row = XLFormRowDescriptor(tag: tag, rowType:XLFormRowDescriptorTypeButton, title:title)
        
        row.action.formBlock = { [unowned self] (sender: XLFormRowDescriptor!) -> Void in
            self.deselectFormRow(sender)
            
            handler()
        }
        
        section.addFormRow(row)
        
        return row
    }

    func didChangeScaleValue(picker: ScalePicker, value: CGFloat) {
        print("Changed scale picker value: \(value)")
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}



