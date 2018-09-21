//
//  ViewController.swift
//  FacePicker
//
//  Created by matthew on 9/5/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import CoreData
import DropDown
import ContextMenu
import SwiftSignatureView

class ClientController: UIViewController, UITextFieldDelegate, UITextViewDelegate, SignatureControllerDelegate {
    //MARK: - Properties
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var cellAreaTextField: UITextField!
    @IBOutlet weak var cellPrefixTextField: UITextField!
    @IBOutlet weak var cellSuffixTextField: UITextField!
    @IBOutlet weak var homeAreaTextField: UITextField!
    @IBOutlet weak var homePrefixTextField: UITextField!
    @IBOutlet weak var homeSuffixTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var medicationsTextView: UITextView!
    @IBOutlet weak var conditionsTextView: UITextView!
    @IBOutlet weak var howMuchTextField: UITextField!
    @IBOutlet weak var lastNeuroDateTextField: UITextField!
    @IBOutlet weak var lastNeuroProductTextField: UITextField!
    @IBOutlet weak var lastFillerDateTextField: UITextField!
    @IBOutlet weak var lastFillerProductTextField: UITextField!
    @IBOutlet weak var referralTextField: UITextField!
    @IBOutlet weak var signatureImageView: UIImageView!
    @IBOutlet weak var dateTextField: UITextField!
    // stackviews for show/hide
    @IBOutlet weak var smokeHowMuchStackView: UIStackView!
    @IBOutlet weak var priorNeuroStackView: UIStackView!
    @IBOutlet weak var priorFillerStackView: UIStackView!
    // date pickers
    var dobDatePicker = UIDatePicker()
    var lastNeuroDatePicker = UIDatePicker()
    var lastFillerDatePicker = UIDatePicker()
    var todaysDatePicker = UIDatePicker()
    // dropdowns
    var stateDropDown = DropDown()
    var smokeDropDown = DropDown()
    var priorTreatmentDropDown = DropDown()
    @IBOutlet weak var smokeDropDownButton: UIButton!
    @IBOutlet weak var priorTreatmentDropDownButton: UIButton!
    private let smokeDropDownOptions = ["No.", "Yes."]
    private let priorTreatmentDropDownOptions = ["No.", "Yes, both.", "Just neurotoxin.", "Just filler."]
    // textview placeholder
    var placeholderText = "Leave blank if not applicable."
    // default signature image (for validation comparison)
    let defaultSignatureImage = UIImage(named: "sign-prompt")
    // delegate
    var delegate: ClientControllerDelegate?
    
    var client: Client?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ClientController.onCancel(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(ClientController.onSave(sender:)))
        
        preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width * 0.75, height: UIScreen.main.bounds.size.height * 0.75)
//        preferredContentSize = CGSize(width: 400, height: UIScreen.main.bounds.size.height * 0.75)
        
        setBorders()
        setupDatePickers()
        setupTextControls()
        setupDropDowns()
        setupSignature()
        
        let insets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        smokeDropDownButton.contentEdgeInsets = insets
        priorTreatmentDropDownButton.contentEdgeInsets = insets
        
        var titleString = "New Client"
        if let client = self.client {
            bindClientToForm(client: client)
            titleString = "Edit Client"
        } else {
            firstNameTextField.becomeFirstResponder()
        }
        navigationItem.title = titleString
        
        // testing persistent data
//        let request:NSFetchRequest<Client> = Client.fetchRequest()
//        let context = managedContext()
//        do {
//            let clients = try context.fetch(request)
//            if clients.count > 0 {
//                self.client = clients.first
//                bindClientToForm(client: self.client!)
//            }
//        } catch {
//            fatalError("Couldn't fetch Client from CoreData")
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private Functions
    private func setBorders() {
        let color = ViewHelper.defaultBorderColor
        ViewHelper.setBorderOnView(medicationsTextView, withColor: color)
        ViewHelper.setBorderOnView(conditionsTextView, withColor: color)
        ViewHelper.setBorderOnView(smokeDropDownButton, withColor: color)
        ViewHelper.setBorderOnView(priorTreatmentDropDownButton, withColor: color)
        ViewHelper.setBorderOnView(signatureImageView, withColor: color)
    }
    private func setupDatePickers() {
        let today = Date.init()
        dobDatePicker.datePickerMode = .date
        dobDatePicker.maximumDate = today
        dobDatePicker.addTarget(self, action: #selector(ClientController.dobDatePickerValueChanged(sender:)), for: .valueChanged)
        dobTextField.inputView = dobDatePicker
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        doneToolbar.setItems([
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ClientController.dismissDatePicker)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ], animated: false)
        doneToolbar.isUserInteractionEnabled = true
        dobTextField.inputAccessoryView = doneToolbar
        
        lastNeuroDatePicker.datePickerMode = .date
        lastNeuroDatePicker.maximumDate = today
        lastNeuroDatePicker.addTarget(self, action: #selector(ClientController.lastNeuroDatePickerValueChanged(sender:)), for: .valueChanged)
        lastNeuroDateTextField.inputView = lastNeuroDatePicker
        lastNeuroDateTextField.inputAccessoryView = doneToolbar
        
        lastFillerDatePicker.datePickerMode = .date
        lastFillerDatePicker.maximumDate = today
        lastFillerDatePicker.addTarget(self, action: #selector(ClientController.lastFillerDatePickerValueChanged(sender:)), for: .valueChanged)
        lastFillerDateTextField.inputView = lastFillerDatePicker
        lastFillerDateTextField.inputAccessoryView = doneToolbar
        
        todaysDatePicker.datePickerMode = .date
        todaysDatePicker.minimumDate = today
        todaysDatePicker.maximumDate = today
        todaysDatePicker.addTarget(self, action: #selector(ClientController.todaysDatePickerValueChanged(sender:)), for: .valueChanged)
        dateTextField.inputView = todaysDatePicker
        dateTextField.inputAccessoryView = doneToolbar
    }
    private func setTextFieldValue(for textField: UITextField, withDate date: Date) {
        textField.text = Client.formatDate(date)
    }
    private func setupTextControls() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        stateTextField.delegate = self
        zipTextField.delegate = self
        cellAreaTextField.delegate = self
        cellPrefixTextField.delegate = self
        cellSuffixTextField.delegate = self
        homeAreaTextField.delegate = self
        homePrefixTextField.delegate = self
        homeSuffixTextField.delegate = self
        referralTextField.delegate = self
        dateTextField.delegate = self
        
        medicationsTextView.delegate = self
        medicationsTextView.text = placeholderText
        conditionsTextView.delegate = self
        conditionsTextView.text = placeholderText
    }
    private func setupDropDowns() {
        stateDropDown.anchorView = stateTextField
        stateDropDown.dataSource = USStates.states.values.sorted()
        stateDropDown.selectionAction = { (index: Int, item: String) in
            self.stateTextField.text = item
            self.zipTextField.becomeFirstResponder()
        }
        stateTextField.addTarget(self, action: #selector(ClientController.stateTextFieldTouched(sender:)), for: .touchDown)
        
        smokeDropDown.anchorView = smokeDropDownButton
        smokeDropDown.dataSource = smokeDropDownOptions
        smokeDropDown.selectionAction = { (index: Int, item: String) in
            self.smokeDropDownButton.setTitle(item, for: .normal)
            self.toggleSmokeControls(index)
        }
        toggleSmokeControls(0)
        
        priorTreatmentDropDown.anchorView = priorTreatmentDropDownButton
        priorTreatmentDropDown.dataSource = priorTreatmentDropDownOptions
        priorTreatmentDropDown.selectionAction = { (index: Int, item: String) in
            self.priorTreatmentDropDownButton.setTitle(item, for: .normal)
            self.togglePriorTreatmentControls(index)
        }
        togglePriorTreatmentControls(0)
    }
    private func togglePriorTreatmentControls(_ index: Int) {
        var hideNeuro = true, hideFiller = true
        switch index {
        case 1:
            hideNeuro = false
            hideFiller = false
        case 2:
            hideNeuro = false
        case 3:
            hideFiller = false
        default:
            break
        }
        self.priorNeuroStackView.isHidden = hideNeuro
        self.priorFillerStackView.isHidden = hideFiller
    }
    private func toggleSmokeControls(_ index: Int) {
        var hideHowMuch = true
        switch index {
        case 1:
            hideHowMuch = false
        default:
            break
        }
        self.smokeHowMuchStackView.isHidden = hideHowMuch
    }
    private func setupSignature() {
        let tapGesutre = UITapGestureRecognizer(target: self, action: #selector(ClientController.signatureImageViewTapped(sender:)))
        signatureImageView.addGestureRecognizer(tapGesutre)
        signatureImageView.isUserInteractionEnabled = true
        signatureImageView.image = defaultSignatureImage
    }
    private func recursivelyResetBorders(inView viewToSearch: UIView) {
        for subview in viewToSearch.subviews {
            recursivelyResetBorders(inView: subview)
            if subview is UITextField || subview is UITextView || subview is UIButton || subview is UIImageView {
                print("recursively found text field or button, etc")
                ViewHelper.setBorderOnView(subview, withColor: ViewHelper.defaultBorderColor)
            }
        }
    }
    private func validateTextFieldNotEmpty(_ textField: UITextField) -> Bool {
        if textField.text == nil || textField.text!.isEmpty {
            ViewHelper.setBorderOnView(textField, withColor: ViewHelper.validationColor)
            return false
        }
        return true
    }
    private func validateDropDown(dropDown: DropDown, withButton button: UIButton) -> Bool {
        if dropDown.selectedItem == nil {
            ViewHelper.setBorderOnView(button, withColor: ViewHelper.validationColor)
            return false
        }
        return true
    }
    private func validateSignature(_ signature: UIImageView) -> Bool {
        if signature.image == nil || signature.image!.cgImage == nil || signature.image == defaultSignatureImage {
            ViewHelper.setBorderOnView(signature, withColor: ViewHelper.validationColor)
            return false
        }
        return true
    }
    private func isFormValid() -> Bool {
        recursivelyResetBorders(inView: self.view)
        
        var formIsValid = true
        formIsValid = validateTextFieldNotEmpty(firstNameTextField)
        formIsValid = validateTextFieldNotEmpty(lastNameTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(dobTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(addressTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(cityTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(stateTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(zipTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(cellAreaTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(cellPrefixTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(cellSuffixTextField) && formIsValid
        formIsValid = validateTextFieldNotEmpty(emailTextField) && formIsValid
        formIsValid = validateDropDown(dropDown: smokeDropDown, withButton: smokeDropDownButton) && formIsValid
        formIsValid = validateDropDown(dropDown: priorTreatmentDropDown, withButton: priorTreatmentDropDownButton) && formIsValid
        formIsValid = validateSignature(signatureImageView) && formIsValid
        formIsValid = validateTextFieldNotEmpty(dateTextField) && formIsValid
        
        return formIsValid
    }
    private func bindFormToClientAndSave() -> Client? {
        let context = managedContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Client", in: context) else {
            fatalError("Failed to get entity for Client.")
        }
        if client == nil {
            // if we aren't editing create new and give id
            client = Client(entity: entity, insertInto: context)
            client?.id = UUID()
        }
        client?.firstName = firstNameTextField.text ?? ""
        client?.lastName = lastNameTextField.text ?? ""
        if let dob = dobTextField.text, !dob.isEmpty {
            client?.dateOfBirth = dobDatePicker.date as NSDate
        } else {
            client?.dateOfBirth = nil
        }
        client?.streetAddress = addressTextField.text
        client?.city = cityTextField.text
        client?.state = stateTextField.text
        client?.zipCode = zipTextField.text
        client?.cellArea = cellAreaTextField.text
        client?.cellPrefix = cellPrefixTextField.text
        client?.cellSuffix = cellSuffixTextField.text
        client?.homeArea = homeAreaTextField.text
        client?.homePrefix = homePrefixTextField.text
        client?.homeSuffix = homeSuffixTextField.text
        client?.email = emailTextField.text
        client?.medications = medicationsTextView.text == placeholderText ? nil : medicationsTextView.text
        client?.medicalConditions = conditionsTextView.text == placeholderText ? nil : conditionsTextView.text
        let smoker = smokeDropDown.indexForSelectedRow == 1
        client?.smoker = smoker
        client?.smokeHowMuch = smoker ? howMuchTextField.text : nil
        // use the dropdown value instead?
        if let lastNeuroDate = lastNeuroDateTextField.text, !lastNeuroDate.isEmpty {
            client?.lastNeuroDate = lastNeuroDatePicker.date as NSDate
            client?.lastNeuroProduct = lastNeuroProductTextField.text
        } else {
            client?.lastNeuroDate = nil
            client?.lastNeuroProduct = nil
        }
        if let lastFillerDate = lastFillerDateTextField.text, !lastFillerDate.isEmpty {
            client?.lastFillerDate = lastFillerDatePicker.date as NSDate
            client?.lastFillerProduct = lastFillerProductTextField.text
        } else {
            client?.lastFillerDate = nil
            client?.lastFillerProduct = nil
        }
        client?.referer = referralTextField.text
        if let image = signatureImageView.image {
            client?.signature = UIImagePNGRepresentation(image) as NSData?
        } else {
            client?.signature = nil
        }
        if let date = dateTextField.text, !date.isEmpty {
            client?.signatureDate = todaysDatePicker.date as NSDate
        } else {
            client?.signatureDate = nil
        }
        appDelegate().saveContext()
        
        return client
    }
    private func bindClientToForm(client: Client) {
        var showNeuro = false
        var showFiller = false
        
        firstNameTextField.text = client.firstName
        lastNameTextField.text = client.lastName
        if let dob = client.dateOfBirth {
            dobDatePicker.setDate(dob as Date, animated: false)
            setTextFieldValue(for: dobTextField, withDate: dob as Date)
        }
        addressTextField.text = client.streetAddress
        cityTextField.text = client.city
        stateTextField.text = client.state
        zipTextField.text = client.zipCode
        cellAreaTextField.text = client.cellArea
        cellPrefixTextField.text = client.cellPrefix
        cellSuffixTextField.text = client.cellSuffix
        homeAreaTextField.text = client.homeArea
        homePrefixTextField.text = client.homePrefix
        homeSuffixTextField.text = client.homeSuffix
        emailTextField.text = client.email
        if let medications = client.medications {
            medicationsTextView.text = medications
            medicationsTextView.textColor = UIColor.black
        }
        if let medicalConditions = client.medicalConditions {
            conditionsTextView.text = medicalConditions
            conditionsTextView.textColor = UIColor.black
        }
        if client.smoker {
            howMuchTextField.text = client.smokeHowMuch
            smokeHowMuchStackView.isHidden = false
            smokeDropDownButton.setTitle(smokeDropDownOptions[1], for: .normal)
            smokeDropDown.selectRow(1)
        } else {
            smokeDropDownButton.setTitle(smokeDropDownOptions[0], for: .normal)
            smokeDropDown.selectRow(0)
        }
        if let neuroDate = client.lastNeuroDate {
            lastNeuroDatePicker.setDate(neuroDate as Date, animated: false)
            setTextFieldValue(for: lastNeuroDateTextField, withDate: neuroDate as Date)
            lastNeuroProductTextField.text = client.lastNeuroProduct
            showNeuro = true
        }
        if let fillerDate = client.lastFillerDate {
            lastFillerDatePicker.setDate(fillerDate as Date, animated: false)
            setTextFieldValue(for: lastFillerDateTextField, withDate: fillerDate as Date)
            lastFillerProductTextField.text = client.lastFillerProduct
            showFiller = true
        }
        var priorDropDownValue = 0
        if showNeuro && showFiller {
            priorDropDownValue = 1
        } else if showNeuro {
            priorDropDownValue = 2
        } else if showFiller {
            priorDropDownValue = 3
        }
        priorNeuroStackView.isHidden = !showNeuro
        priorFillerStackView.isHidden = !showFiller
        priorTreatmentDropDownButton.setTitle(priorTreatmentDropDownOptions[priorDropDownValue], for: .normal)
        priorTreatmentDropDown.selectRow(priorDropDownValue)
        referralTextField.text = client.referer
        if let imageData = client.signature {
            signatureImageView.image = UIImage(data:imageData as Data)
        }
        if let sigDate = client.signatureDate {
            todaysDatePicker.setDate(sigDate as Date, animated: false)
            setTextFieldValue(for: dateTextField, withDate: sigDate as Date)
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case stateTextField:
            stateDropDown.show()
        case dateTextField:
//            todaysDatePicker.setDate(Date.init(), animated: false)
            setTextFieldValue(for: dateTextField, withDate: Date.init())
        case cellAreaTextField, cellPrefixTextField, cellSuffixTextField, homeAreaTextField, homePrefixTextField, homeSuffixTextField:
            textField.selectAll(nil)
        default:
            break
        }
    }
    private func checkString(string: String, conformsToCharacterSet allowedCharacters: CharacterSet) -> Bool {
        let characterSet = CharacterSet.init(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    private func checkIsDecimalDigits(string: String) -> Bool {
        return checkString(string: string, conformsToCharacterSet: CharacterSet.decimalDigits)
    }
    private func checkIsLetters(string: String) -> Bool {
        let lettersAndSpaces = CharacterSet.letters.union(CharacterSet.whitespaces)
        return checkString(string: string, conformsToCharacterSet: lettersAndSpaces)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var moveNext:UITextField? = nil
        switch textField {
        case firstNameTextField, lastNameTextField, referralTextField:
            return checkIsLetters(string: string)
        case zipTextField:
            return checkIsDecimalDigits(string: string) && range.location < 5
        case cellAreaTextField:
            if !checkIsDecimalDigits(string: string) {
                return false
            }
            if range.location == 2 {
                moveNext = cellPrefixTextField
            }
        case cellPrefixTextField:
            if !checkIsDecimalDigits(string: string) {
                return false
            }
            if range.location == 2 {
                moveNext = cellSuffixTextField
            }
        case cellSuffixTextField:
            if !checkIsDecimalDigits(string: string) {
                return false
            }
            if range.location == 3 {
                moveNext = homeAreaTextField
            }
        case homeAreaTextField:
            if !checkIsDecimalDigits(string: string) {
                return false
            }
            if range.location == 2 {
                moveNext = homePrefixTextField
            }
        case homePrefixTextField:
            if !checkIsDecimalDigits(string: string) {
                return false
            }
            if range.location == 2 {
                moveNext = homeSuffixTextField
            }
        case homeSuffixTextField:
            if !checkIsDecimalDigits(string: string) {
                return false
            }
            if range.location == 3 {
                moveNext = emailTextField
            }
        default:
            break
        }
        if let next = moveNext {
            textField.text?.append(string)
            next.becomeFirstResponder()
            return false
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        switch textField {
        case stateTextField:
            stateDropDown.hide()
        default:
            break
        }
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case medicationsTextView, conditionsTextView:
            if textView.text == placeholderText {
                textView.text = ""
                textView.textColor = UIColor.black
            }
        default:
            return
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        switch textView {
        case medicationsTextView:
            if text == "\t" {
                conditionsTextView.becomeFirstResponder()
                return false
            }
        case conditionsTextView:
            if text == "\t" {
                if !smokeHowMuchStackView.isHidden {
                    howMuchTextField.becomeFirstResponder()
                } else if !priorNeuroStackView.isHidden {
                    lastNeuroDateTextField.becomeFirstResponder()
                } else if !priorFillerStackView.isHidden {
                    lastFillerDateTextField.becomeFirstResponder()
                } else {
                    referralTextField.becomeFirstResponder()
                }
                return false
            }
        default:
            break
        }
        return true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        switch textView {
        case medicationsTextView, conditionsTextView:
            if textView.text.isEmpty {
                textView.text = placeholderText
                textView.textColor = UIColor.lightGray
            }
        default:
            return
        }
    }

    //MARK: - SignatureControllerDelegate
    func signatureDidFinish(signature: UIImage) {
        signatureImageView.image = signature
    }
    
    //MARK: - Actions
    @objc
    func onSave(sender: UIBarButtonItem) {
//        if !isFormValid() {
//            let alert = UIAlertController(title: "Please complete the fields highlighted in red.", message: "", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
//            self.present(alert, animated: true)
//            return
//        }
        if let client = bindFormToClientAndSave() {
            delegate?.clientControllerDidSave(client: client)
        }
        dismiss(animated: true, completion: nil)
    }
    @objc
    func onCancel(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @objc
    func stateTextFieldTouched(sender: UITextField) {
        stateDropDown.show()
    }
    @objc
    func dobDatePickerValueChanged(sender: UIDatePicker) {
        setTextFieldValue(for: dobTextField, withDate: sender.date)
    }
    @objc
    func lastNeuroDatePickerValueChanged(sender: UIDatePicker) {
        setTextFieldValue(for: lastNeuroDateTextField, withDate: sender.date)
    }
    @objc
    func lastFillerDatePickerValueChanged(sender: UIDatePicker) {
        setTextFieldValue(for: lastFillerDateTextField, withDate: sender.date)
    }
    @objc
    func todaysDatePickerValueChanged(sender: UIDatePicker) {
        setTextFieldValue(for: dateTextField, withDate: sender.date)
    }
    @objc func dismissDatePicker() {
        if dobTextField.isFirstResponder {
            addressTextField.becomeFirstResponder()
        } else if lastNeuroDateTextField.isFirstResponder {
            lastNeuroProductTextField.becomeFirstResponder()
        } else if lastFillerDateTextField.isFirstResponder {
            lastFillerProductTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    @IBAction func smokeDropDownButtonTouched(_ sender: UIButton) {
        smokeDropDown.show()
    }
    @IBAction func priorTreatmentDropDownButtonPressed(_ sender: UIButton) {
        priorTreatmentDropDown.show()
    }
    @objc
    func signatureImageViewTapped(sender: UIImageView) {
        view.endEditing(true)
        let localContextMenu = ContextMenu(), signatureController = SignatureController()
        signatureController.delegate = self
        localContextMenu.show(sourceViewController: self, viewController: signatureController)
    }
}

protocol ClientControllerDelegate {
    func clientControllerDidSave(client: Client) -> Void
}

public class USStates {
    public static var states: [String : String] {
        return [
        "AK" : "Alaska",
        "AL" : "Alabama",
        "AR" : "Arkansas",
//        "AS" : "American Samoa",
        "AZ" : "Arizona",
        "CA" : "California",
        "CO" : "Colorado",
        "CT" : "Connecticut",
        "DC" : "District of Columbia",
        "DE" : "Delaware",
        "FL" : "Florida",
        "GA" : "Georgia",
//        "GU" : "Guam",
        "HI" : "Hawaii",
        "IA" : "Iowa",
        "ID" : "Idaho",
        "IL" : "Illinois",
        "IN" : "Indiana",
        "KS" : "Kansas",
        "KY" : "Kentucky",
        "LA" : "Louisiana",
        "MA" : "Massachusetts",
        "MD" : "Maryland",
        "ME" : "Maine",
        "MI" : "Michigan",
        "MN" : "Minnesota",
        "MO" : "Missouri",
        "MS" : "Mississippi",
        "MT" : "Montana",
        "NC" : "North Carolina",
        "ND" : "North Dakota",
        "NE" : "Nebraska",
        "NH" : "New Hampshire",
        "NJ" : "New Jersey",
        "NM" : "New Mexico",
        "NV" : "Nevada",
        "NY" : "New York",
        "OH" : "Ohio",
        "OK" : "Oklahoma",
        "OR" : "Oregon",
        "PA" : "Pennsylvania",
        "PR" : "Puerto Rico",
        "RI" : "Rhode Island",
        "SC" : "South Carolina",
        "SD" : "South Dakota",
        "TN" : "Tennessee",
        "TX" : "Texas",
        "UT" : "Utah",
        "VA" : "Virginia",
        "VI" : "Virgin Islands",
        "VT" : "Vermont",
        "WA" : "Washington",
        "WI" : "Wisconsin",
        "WV" : "West Virginia",
        "WY" : "Wyoming"]
    }
}
