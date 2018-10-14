//
//  SettingsViewController.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {
    
    static let nibName = "SettingsViewController"
    
    private let unitSliderIncrements: [Float] = [0.1, 0.25, 0.5, 1.0]
    
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
    
    // merging, importing, exporting
    let csvManager = ClientCSVManager()
    let clientMerger = ClientMerger()
    private enum FilePickerDirection {
        case opening
        case saving
    }
    private var filePickerDirection:FilePickerDirection = .opening
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        preferredContentSize = CGSize(width: 400, height: 560)
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(SettingsViewController.onImport(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingsViewController.onDone(sender:)))
        
        selectionIncrementSlider.minimumValue = unitSliderIncrements[0]
        selectionIncrementSlider.maximumValue = unitSliderIncrements[unitSliderIncrements.count - 1]
        
        setupControls()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupControls() {
        listAllClientsSwitch.isOn = Application.Settings.listAllClients
        
        let validateClient = Application.Settings.validateClient
        validateClientSwitch.isOn = validateClient
        setValidationControlVisibility(!validateClient)
        requireDOBSwitch.isOn = Application.Settings.validateDOB
        requireAddressSwitch.isOn = Application.Settings.validateAddress
        requirePhoneSwitch.isOn = Application.Settings.validatePhone
        requireEmailSwitch.isOn = Application.Settings.validateEmail
        requireSignatureSwitch.isOn = Application.Settings.validateSignature
        
        editOldSessionSwitch.isOn = Application.Settings.editOldSessionsAllowed
        let settingsIncrement = Application.Settings.unitSelectionIncrement
        selectionIncrementLabel.text = settingsIncrement.description
        selectionIncrementSlider.value = settingsIncrement
        dateForNewSessionsSwitch.isOn = Application.Settings.promptDateForNewSession
    }
    
    private func setValidationControlVisibility(_ visible: Bool) {
        requireDOBStack.isHidden = visible
        requireAddressStack.isHidden = visible
        requirePhoneStack.isHidden = visible
        requireEmailStack.isHidden = visible
        requireSignatureStack.isHidden = visible
    }
    
    @objc
    func onImport(sender: UIBarButtonItem) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", "public.archive"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(SettingsViewController.onSave(sender:)))
        
        filePickerDirection = .opening
        present(documentPicker, animated: true, completion: nil)
    }
    
    @objc
    func onSave(sender: UIBarButtonItem) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text"], in: .open)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true

        filePickerDirection = .saving
        present(documentPicker, animated: true, completion: nil)
    }
    
    @objc
    func onDone(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listAllClientsSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.listAllClients = sender.isOn
        NotificationCenter.default.post(name: .listAllClientsSettingDidChange, object: nil)
    }
    
    @IBAction func validateClientSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.validateClient = sender.isOn
        setValidationControlVisibility(!sender.isOn)
    }
    
    @IBAction func requireDOBSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.validateDOB = sender.isOn
    }
    
    @IBAction func requireAddressSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.validateAddress = sender.isOn
    }
    
    @IBAction func requirePhoneSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.validatePhone = sender.isOn
    }
    
    @IBAction func requireEmailSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.validateEmail = sender.isOn
    }
    
    @IBAction func requireSignatureSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.validateSignature = sender.isOn
    }
 
    @IBAction func editOldSessionSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.editOldSessionsAllowed = sender.isOn
    }
    
    @IBAction func selectionIncrementSliderValueChanged(_ sender: UISlider) {
        sender.value = ViewHelper.snapSliderToIncrements(sender, increments: unitSliderIncrements)
        selectionIncrementLabel.text = sender.value.description // String.init(format: "%.2f", currentValue)
    }
    
    private var sliderValueBeforeTouch:Float = 0.0
    private func setIncrementSettingIfChanged(_ value: Float) {
        if value != sliderValueBeforeTouch {
            Application.Settings.unitSelectionIncrement = value
        }
    }
    
    @IBAction func selectionIncrementSliderTouchDown(_ sender: UISlider) {
        sliderValueBeforeTouch = sender.value
    }
    
    @IBAction func selectionIncrementSliderTouchUpInside(_ sender: UISlider) {
        setIncrementSettingIfChanged(sender.value)
    }
    
    @IBAction func selectionIncrementSliderTouchUpOutside(_ sender: UISlider) {
        setIncrementSettingIfChanged(sender.value)
    }
    
    
    @IBAction func dateForNewSessionsSwitchValueChanged(_ sender: UISwitch) {
        Application.Settings.promptDateForNewSession = sender.isOn
    }
}

extension SettingsViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var importedCSVs = false
        for url in urls {
            print("didPickDocumentAt: \(url)")
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }
            if !hasAccess {
                Application.onError("Error accessing file: couldn't access security scoped resource for \(url)")
            }
            if url.path.contains(".csv") {
                switch filePickerDirection {
                case .opening:
                    importedCSVs = true
                    if url.path.contains("2018") {
                        csvManager.importClientsFromCSV(withUrl: url)
                    } else {
                        // date and name are swapped for 2015
                        csvManager.importClientsFromCSV(withUrl: url, namesOnly: true, nameAndDateFieldsSwapped: url.path.contains("2015"))
                    }
                case .saving:
                    csvManager.exportClientMergesToCSV(clientMerger.mergePairs, forUrl: url)
                }
                
            } else {
                csvManager.saveClientsToTextFile(withUrl: url, andClients: clientMerger.clients)
            }
        }
        if importedCSVs {
            clientMerger.setViewController(self)
            clientMerger.setClientsToMerge(csvManager.clientsWithDates, withContexts: csvManager.clientContexts)
            clientMerger.beginMerge(completion: { mergedClients in
                Client.createClientsFromImport(clients: mergedClients)
            })
            
            // TODO: reconcile again by checking if last names contain other last names?
        }
    }
}
