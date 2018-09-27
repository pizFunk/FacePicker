//
//  SiteMenuControllerViewController.swift
//  FacePicker
//
//  Created by matthew on 9/10/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import DropDown

class SiteMenuController: UIViewController {
    //MARK: - Properties
    private var unitAmountSlider: UISlider!
    private var unitLabel: UILabel!
    private var unitTypeButton: UIButton!
    private var unitTypeDropDown: DropDown!
    // button from SessionController menu is shown for:
    var siteButton: UIButton!
    
    public let sliderStepInterval = Application.Settings.unitSelectionIncrement
    public var editMode: Bool = false
    public var delegate: SiteMenuControllerDelegate?
    public var site: InjectionSite!
    public var state: SiteMenuControllerState = .Other
    
    //MARK: - Static Properties
    private static var previousSite: InjectionSite? //Values: (units: Float, type: InjectionType)?
    public static var usePreviousValues: Bool = false
    
    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 250, height: 90)
        
        //
        // Save Button
        //
        //navigationItem.title = "0.0 Units"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(onSave)
        )
        
        //
        // Delete Button (if we have a set value)
        //
        if editMode {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: UIBarButtonSystemItem.trash,
                target: self,
                action: #selector(onDelete)
            )
            navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        }
        
        //
        // slider to select units
        //
        let slider = UISlider()
        slider.addTarget(self, action: #selector(sliderDidChange(sender:)), for: UIControlEvents.valueChanged)
        slider.minimumValue = sliderStepInterval
        slider.maximumValue = 5.0
        view.addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0)
            ])
        
        unitAmountSlider = slider
        
        //
        // labels
        //
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20.0),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0)
            ])
        unitLabel = label
        setUnitLabel(slider.value)
        
        let label2 = UILabel()
        label2.text = " units of "
        view.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label2.centerYAnchor.constraint(equalTo: label.centerYAnchor), //constant: -1.0),
            label2.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20.0),
            label2.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0.0)
            ])
        
        
        //
        // dropdown to select product type
        //
        let button = NiceButton()
        button.setTitle("Select Type", for: .normal)
        button.setTitleColor(view.tintColor, for: .normal)
        button.contentHorizontalAlignment = .left
        
        button.addTarget(self, action: #selector(typeButtonPressed(sender:)), for: .touchUpInside)
        let dropdown = DropDown()
        dropdown.anchorView = button
        dropdown.dataSource = InjectionType.toArray
        dropdown.selectionAction = { (index, item) in
            button.setTitle(item, for: .normal)
            self.site.type = InjectionType(rawValue: index)!
            SessionHelper.setTitleAndColor(forButton: self.siteButton, withSite: self.site)
        }
        // set default
        dropdown.selectRow(0)
        button.setTitle(InjectionType(rawValue: 0)?.description, for: .normal)
        
        unitTypeDropDown = dropdown
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: label2.centerYAnchor, constant: -1.0),
            button.leadingAnchor.constraint(equalTo: label2.trailingAnchor, constant: 0),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        unitTypeButton = button
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if editMode {
            // update current if set
            setCurrentValues()
        } else {
            setDefaultValues()
        }
        SessionHelper.setTitleAndColor(forButton: siteButton, withSite: site)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private Functions
    private func setCurrentValues() {
        guard let site = site else {
            return
        }
        let units = site.units
        unitAmountSlider.setValue(units, animated: false)
        setUnitLabel(units)
        let type = site.type
        unitTypeDropDown.clearSelection()
        unitTypeDropDown.selectRow(type.rawValue)
        setTypeButton(type.description)
    }
    private func setDefaultValues() {
        site.units = unitAmountSlider.minimumValue
        site.type = InjectionType.NeuroToxin
        if SiteMenuController.usePreviousValues, let previous = SiteMenuController.previousSite, previous.units > 0 {
            unitAmountSlider.setValue(previous.units, animated: false)
            setUnitLabel(previous.units)
            site.units = previous.units
            site.type = previous.type
        }
        unitTypeDropDown.clearSelection()
        unitTypeDropDown.selectRow(site.type.rawValue)
        setTypeButton(site.type.description)
    }
    private func setUnitLabel(_ units: Float) {
        unitLabel.text = units.description // String(format: "%.1f", units)
    }
    private func setTypeButton(_ type: String) {
        unitTypeButton.setTitle(type, for: .normal)
    }
    
    //MARK: - Actions
    @objc func onSave() {
//        print("--- SiteMenuController.onSave() ---")
        guard let selectedType = unitTypeDropDown.indexPathForSelectedRow else {
            site = nil
            return
        }
        let value = unitAmountSlider.value
        let type = InjectionType(rawValue: selectedType.row)!
        site?.setUnits(value, ofType: type)
        SiteMenuController.previousSite = site
        state = .Saving
        delegate?.siteMenuDidSave(savedSite: site)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onDelete() {
//        print("--- SiteMenuController.onDelete() ---")
        state = .Deleting
        delegate?.siteMenuDidDelete(deletedSite: site)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func typeButtonPressed(sender: UIButton) {
        unitTypeDropDown.show()
    }
    
    @objc func sliderDidChange(sender: UISlider) {
        //print("--- SiteMenuController.sliderDidChange(sender:) ---")
        
        // snap to the set step interval
        let newValue = Int(roundf(sender.value / sliderStepInterval))
        sender.value = sliderStepInterval * Float(newValue)

        setUnitLabel(sender.value)
        
        site.units = sender.value
        SessionHelper.setTitleAndColor(forButton: siteButton, withSite: site)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol SiteMenuControllerDelegate {
    func siteMenuDidSave(savedSite: InjectionSite) -> ()
    func siteMenuDidDelete(deletedSite: InjectionSite) -> ()
}

enum SiteMenuControllerState {
    case Saving
    case Deleting
    case Other
}

class NiceButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 1.0)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: 1
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .left,
            relatedBy: .equal,
            toItem: self,
            attribute: .left,
            multiplier: 1,
            constant: 0
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .right,
            relatedBy: .equal,
            toItem: self,
            attribute: .right,
            multiplier: 1,
            constant: 0
            )
        )
        
        addConstraint(NSLayoutConstraint(
            item: view,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
            )
        )
    }
}
