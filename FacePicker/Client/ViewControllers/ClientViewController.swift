//
//  ClientViewController.swift
//  FacePicker
//
//  Created by matthew on 9/14/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import ContextMenu

// MARK: - Properties

class ClientViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var streetAdressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var cellPhoneLabel: UILabel!
    @IBOutlet weak var homePhoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var referrerLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var medicationsTextView: UITextView!
    @IBOutlet weak var conditionsTextView: UITextView!
    @IBOutlet weak var smokerLabel: UILabel!
    @IBOutlet weak var howMuchSmokeLabel: UILabel!
    @IBOutlet weak var priorNeuroDateLabel: UILabel!
    @IBOutlet weak var priorNeuroProductLabel: UILabel!
    @IBOutlet weak var priorFillerDateLabel: UILabel!
    @IBOutlet weak var priorFillerProductLabel: UILabel!
    @IBOutlet weak var referrerStack: UIStackView!
    @IBOutlet weak var smokeAmountStack: UIStackView!
    @IBOutlet weak var priorNeuroStack: UIStackView!
    @IBOutlet weak var priorFillerStack: UIStackView!
    @IBOutlet weak var editClientButton: UIButton!
    @IBOutlet weak var saveNotesButton: UIButton!
    
    var delegate: ClientViewControllerDelegate?
    var client: Client? {
        didSet {
            guard client != nil else { return }
            loadViewIfNeeded()
            loadClientData()
            setStyling()
        }
    }
    private var namePriorToEdit = ""
}

// MARK: - Public Functions

extension ClientViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        notesTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(ClientViewController.viewTapped(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        if !notesTextView.frame.contains(sender.location(in: view)) {
            notesTextView.resignFirstResponder()
        }
    }
    
    @IBAction func editClientPressed(_ sender: UIButton) {
        guard let client = client else { return }
        self.namePriorToEdit = client.formattedName()
        let clientController = ClientController(nibName: "ClientController", bundle: nil)
        clientController.delegate = self
        clientController.client = self.client
        let navController = UINavigationController(rootViewController: clientController)
        navController.modalPresentationStyle = .pageSheet
        
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func showConsentButtonPressed(_ sender: UIButton) {
        guard let client = client, let signatureData = client.signature as Data?, let signatureDate = client.formattedSignatureDate() else {
            Application.onError("No signature image or date when trying to show consent overlay!")
            return
        }
        let clientConsentController = ClientConsentController(nibName: "ClientConsentController", bundle: nil)
        clientConsentController.signatureImage = UIImage(data: signatureData)
        clientConsentController.signatureDate = signatureDate
        showContextualMenu(clientConsentController)
    }
    
    @IBAction func saveNotesButtonPressed(_ sender: UIButton) {
        saveNotes()
    }
}

// MARK: - Private Functions

private extension ClientViewController {

    private func loadClientData() {
        guard let client = client else { return }
        nameLabel.text = client.formattedName()
        dobLabel.text = client.formattedDOB()
        streetAdressLabel.text = client.streetAddress
        cityStateZipLabel.text = client.formattedCityStateZip()
        cellPhoneLabel.text = client.formattedCellPhone()
        if let homePhone = client.formattedHomePhone() {
            homePhoneLabel.text = homePhone
            homePhoneLabel.isHidden = false
        } else {
            homePhoneLabel.isHidden = true
        }
        emailLabel.text = client.email
        if let referrer = client.referer, !referrer.isEmpty {
            referrerLabel.text = referrer
            referrerStack.isHidden = false
        } else {
            referrerStack.isHidden = true
        }
        notesTextView.text = client.notes
        medicationsTextView.text = client.medications ?? "None."
        conditionsTextView.text = client.medicalConditions ?? "None."
        smokerLabel.text = client.formattedSmoker()
        if let smokeHowMuch = client.smokeHowMuch, !smokeHowMuch.isEmpty {
            howMuchSmokeLabel.text = smokeHowMuch
            smokeAmountStack.isHidden = false
        } else {
            smokeAmountStack.isHidden = true
        }
        if let neuroDate = client.lastNeuroDate, !neuroDate.isEmpty { //} client.formattedLastNeuroDate() {
            priorNeuroDateLabel.text = neuroDate
            priorNeuroProductLabel.text = client.lastNeuroProduct
            priorNeuroStack.isHidden = false
        } else {
            priorNeuroStack.isHidden = true
        }
        if let fillerDate = client.lastFillerDate, !fillerDate.isEmpty { //} client.formattedLastFillerDate() {
            priorFillerDateLabel.text = fillerDate
            priorFillerProductLabel.text = client.lastFillerProduct
            priorFillerStack.isHidden = false
        } else {
            priorFillerStack.isHidden = true
        }
    }
    
    private func setStyling() {
        let color = ViewHelper.defaultBorderColor
        ViewHelper.setBorderOnView(medicationsTextView, withColor: color)
        ViewHelper.setBorderOnView(conditionsTextView, withColor: color)
        ViewHelper.setBorderOnView(notesTextView, withColor: color)
    }
    
    private func saveNotes() {
        guard let client = client else { return }
        client.notes = notesTextView.text
        saveNotesButton.isHidden = true
        
        Application.logInfo("Saved notes for Client with id: \(client.id.uuidString)")
    }
    
    private func isNotesDifferentThanSaved() -> Bool {
        let clientNotes = client?.notes ?? ""
        return notesTextView.text != clientNotes
    }
}

// MARK: - UITextViewDelegate

extension ClientViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveNotes()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveNotesButton.isHidden = !isNotesDifferentThanSaved()
    }
}

// MARK: - ContextMenuDelegate

extension ClientViewController: ContextMenuDelegate {
    
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
    }
}

// MARK: - ClientControllerDelegate

extension ClientViewController: ClientControllerDelegate {

    func clientControllerDidSave(client: Client) {
        let nameDidChange = self.namePriorToEdit != client.formattedName()
        self.client = client
        loadClientData()
        if nameDidChange {
            // if the name changed let DetailControll tell the ListController so it can update
            delegate?.clientNameWasEdited(client: client)
        }
    }
}

// MARK: - ClientViewControllerDelegate

protocol ClientViewControllerDelegate {
    func clientNameWasEdited(client: Client)
}
