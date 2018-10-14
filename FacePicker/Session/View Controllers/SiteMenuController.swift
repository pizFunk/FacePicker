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
    private var sliderHeightConstraint:NSLayoutConstraint!
    private var unitLabel: UILabel!
    private var unitDescriptionLabel: UILabel!
    private var unitTypeButton: UIButton!
    private var unitTypeDropDown: DropDown!
    // button from SessionController menu is shown for:
    var siteButton: UIButton!
    
    public let sliderStepInterval = Application.Settings.unitSelectionIncrement
    private let sliderMaxValue:Float = 5.0
    public var editMode: Bool = false
    public var delegate: SiteMenuControllerDelegate?
    public var site: InjectionSite!
    public var state: SiteMenuControllerState = .Other
    
    private let sizeWithSlider = CGSize(width: 250, height: 90)
    private let sizeWithoutSlider = CGSize(width: 250, height: 60)
    
    //MARK: - Static Properties
    private static var previousSiteValues: (units: Float, type: InjectionType)?
    public static var usePreviousValues: Bool = false
    
    //MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        slider.maximumValue = sliderMaxValue
        view.addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0)
            ])
        
        unitAmountSlider = slider
        sliderHeightConstraint = slider.heightAnchor.constraint(equalToConstant: 0.0)
        
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
        
        let label2 = UILabel()
        label2.text = " units of "
        view.addSubview(label2)
        label2.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label2.centerYAnchor.constraint(equalTo: label.centerYAnchor), //constant: -1.0),
            label2.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20.0),
            label2.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 0.0)
            ])
        unitDescriptionLabel = label2
        
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
        dropdown.selectionAction = onTypeDropDownValueChange
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
        
        
//        preferredContentSize = sizeWithSlider
        if editMode {
            // update current if set
            setCurrentValues()
        } else {
            setDefaultValues()
        }
        SessionHelper.setTitleAndColor(forButton: siteButton, withSite: site)
    }
    
    private func onTypeDropDownValueChange(index: Int, item: String) {
        unitTypeButton.setTitle(item, for: .normal)
        guard let selectedType = InjectionType(rawValue: index) else {
            // TODO: log error
            return
        }
        setSliderForType(selectedType)
        site.type = selectedType
        switch selectedType {
        case .Neurotoxin:
            site.units = unitAmountSlider.value //sliderStepInterval
        case .Filler:
            site.units = 0
        default:
            break
        }
        setUnitLabel()
        SessionHelper.setTitleAndColor(forButton: self.siteButton, withSite: self.site)
    }
    
    private func setSliderForType(_ type: InjectionType, isLoading: Bool = false) {
        switch type {
        case .Neurotoxin:
            unitAmountSlider.isHidden = false
            sliderHeightConstraint.isActive = false
            preferredContentSize = sizeWithSlider
            navigationController?.preferredContentSize = sizeWithSlider // b/c of the way ContextMenu is written
        case .Filler:
            unitAmountSlider.isHidden = true
            sliderHeightConstraint.isActive = true
            preferredContentSize = sizeWithoutSlider
            navigationController?.preferredContentSize = sizeWithoutSlider // b/c of the way ContextMenu is written
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let type = site.type
        setSliderForType(type, isLoading: true)
        unitAmountSlider.setValue(units, animated: false)
        setUnitLabel()
        unitTypeDropDown.clearSelection()
        unitTypeDropDown.selectRow(type.rawValue)
        setTypeButton(type.description)
    }
    private func setDefaultValues() {
        site.units = unitAmountSlider.minimumValue
        site.type = InjectionType.Neurotoxin
        if SiteMenuController.usePreviousValues, let previousValues = SiteMenuController.previousSiteValues/*, previous.units > 0*/ {
            site.units = previousValues.units
            site.type = previousValues.type
        }
        setSliderForType(site.type, isLoading: true)
        unitAmountSlider.setValue(site.units, animated: false)
        setUnitLabel()
        unitTypeDropDown.clearSelection()
        unitTypeDropDown.selectRow(site.type.rawValue)
        setTypeButton(site.type.description)
    }
    private func setUnitLabel() {
        var description = ""
        switch site.type {
        case .Neurotoxin:
            description = " units of "
        case .Filler:
            description = " location of "
        default:
            break
        }
        unitDescriptionLabel.text = description
        unitLabel.text = site.formattedUnits() // String(format: "%.1f", units)
    }
    private func setTypeButton(_ type: String) {
        unitTypeButton.setTitle(type, for: .normal)
    }
    
    //MARK: - Actions
    @objc func onSave() {
//        print("--- SiteMenuController.onSave() ---")
//        guard let selectedType = unitTypeDropDown.indexPathForSelectedRow else {
//            site = nil
//            return
//        }
//        let value = unitAmountSlider.value
//        let type = InjectionType(rawValue: selectedType.row)!
//        site?.setUnits(value, ofType: type)
        SiteMenuController.previousSiteValues = (units: site.units, type: site.type)
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
        sender.value = ViewHelper.snapSliderToIncrement(sender, increment: sliderStepInterval)

        site.units = sender.value
        setUnitLabel()
        
        SessionHelper.setTitleAndColor(forButton: siteButton, withSite: site)
    }
}

protocol SiteMenuControllerDelegate {
    func siteMenuDidSave(savedSite: InjectionSite) -> ()
    func siteMenuDidDelete(deletedSite: InjectionSite) -> ()
}

class NiceButton: UIButton {
    var underlineView = UIView()
    
    var color:UIColor? {
        didSet {
            guard let color = color else { return }
            setTitleColor(color, for: .normal)
            underlineView.backgroundColor = color
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let view = UIView()
        view.backgroundColor = color ?? tintColor //UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 1.0)
        
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
        
        underlineView = view
    }
}
