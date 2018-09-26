//
//  SettingsViewController.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    static let nibName = "SettingsViewController"
    
    private let possibleIncrementValues: [Float] = [0.1, 0.25, 0.5, 1.0]
    
    @IBOutlet weak var listAllClientsSwitch: UISwitch!
    @IBOutlet weak var validateClientSwitch: UISwitch!
    @IBOutlet weak var requireDOBSwitch: UISwitch!
    @IBOutlet weak var requireAddressSwitch: UISwitch!
    @IBOutlet weak var requirePhoneSwitch: UISwitch!
    @IBOutlet weak var requireEmailSwitch: UISwitch!
    @IBOutlet weak var requireSignatureSwitch: UISwitch!
    @IBOutlet weak var editOldSessionSwitch: UISwitch!
    @IBOutlet weak var selectionIncrementLabel: UILabel!
    @IBOutlet weak var selectionIncrementSlider: UISlider!
    @IBOutlet weak var dateForNewSessionsSwitch: UISwitch!
    
    @IBOutlet weak var requireDOBStack: UIStackView!
    @IBOutlet weak var requireAddressStack: UIStackView!
    @IBOutlet weak var requirePhoneStack: UIStackView!
    @IBOutlet weak var requireEmailStack: UIStackView!
    @IBOutlet weak var requireSignatureStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        preferredContentSize = CGSize(width: 400, height: 560)
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.onDone(sender:)))
        
        selectionIncrementSlider.minimumValue = possibleIncrementValues[0]
        selectionIncrementSlider.maximumValue = possibleIncrementValues[possibleIncrementValues.count - 1]
        
        setupControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupControls() {
        listAllClientsSwitch.isOn = Settings.listAllClients
        
        let validateClient = Settings.validateClient
        validateClientSwitch.isOn = validateClient
        setValidationControlVisibility(!validateClient)
        requireDOBSwitch.isOn = Settings.validateDOB
        requireAddressSwitch.isOn = Settings.validateAddress
        requirePhoneSwitch.isOn = Settings.validatePhone
        requireEmailSwitch.isOn = Settings.validateEmail
        requireSignatureSwitch.isOn = Settings.validateSignature
        
        editOldSessionSwitch.isOn = Settings.editOldSessionsAllowed
        let settingsIncrement = Settings.unitSelectionIncrement
        selectionIncrementLabel.text = settingsIncrement.description
        selectionIncrementSlider.value = settingsIncrement
        dateForNewSessionsSwitch.isOn = Settings.promptDateForNewSession
    }
    
    private func setValidationControlVisibility(_ visible: Bool) {
        requireDOBStack.isHidden = visible
        requireAddressStack.isHidden = visible
        requirePhoneStack.isHidden = visible
        requireEmailStack.isHidden = visible
        requireSignatureStack.isHidden = visible
    }
    
    @objc
    func onDone(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listAllClientsSwitchValueChanged(_ sender: UISwitch) {
        Settings.listAllClients = sender.isOn
        NotificationCenter.default.post(name: .listAllClientsSettingDidChange, object: nil)
    }
    
    @IBAction func validateClientSwitchValueChanged(_ sender: UISwitch) {
        Settings.validateClient = sender.isOn
        setValidationControlVisibility(!sender.isOn)
    }
    
    @IBAction func requireDOBSwitchValueChanged(_ sender: UISwitch) {
        Settings.validateDOB = sender.isOn
    }
    
    @IBAction func requireAddressSwitchValueChanged(_ sender: UISwitch) {
        Settings.validateAddress = sender.isOn
    }
    
    @IBAction func requirePhoneSwitchValueChanged(_ sender: UISwitch) {
        Settings.validatePhone = sender.isOn
    }
    
    @IBAction func requireEmailSwitchValueChanged(_ sender: UISwitch) {
        Settings.validateEmail = sender.isOn
    }
    
    @IBAction func requireSignatureSwitchValueChanged(_ sender: UISwitch) {
        Settings.validateSignature = sender.isOn
    }
 
    @IBAction func editOldSessionSwitchValueChanged(_ sender: UISwitch) {
        Settings.editOldSessionsAllowed = sender.isOn
    }
    
    @IBAction func selectionIncrementSliderValueChanged(_ sender: UISlider) {
        var currentValue = sender.value
        guard let index = possibleIncrementValues.index(where: { value in
            return currentValue < value
        }) else {
           return
        }
        let lower = possibleIncrementValues[index - 1]
        let upper = possibleIncrementValues[index]
        let mid = (lower + upper) / 2
        if currentValue <= mid {
            currentValue = lower
        }
        else {
            currentValue = upper
        }
        
        sender.value = currentValue
        selectionIncrementLabel.text = currentValue.description // String.init(format: "%.2f", currentValue)
        Settings.unitSelectionIncrement = currentValue
    }
    
    @IBAction func dateForNewSessionsSwitchValueChanged(_ sender: UISwitch) {
        Settings.promptDateForNewSession = sender.isOn
    }
}
