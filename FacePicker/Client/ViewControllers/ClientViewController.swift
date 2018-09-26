//
//  ClientViewController.swift
//  FacePicker
//
//  Created by matthew on 9/14/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import ContextMenu

class ClientViewController: UIViewController, UITextViewDelegate, ContextMenuDelegate, ClientControllerDelegate {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        notesTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(ClientViewController.viewTapped(sender:)))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        if !notesTextView.frame.contains(sender.location(in: view)) {
            notesTextView.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private Functions
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
        if let neuroDate = client.formattedLastNeuroDate() {
            priorNeuroDateLabel.text = neuroDate
            priorNeuroProductLabel.text = client.lastNeuroProduct
            priorNeuroStack.isHidden = false
        } else {
            priorNeuroStack.isHidden = true
        }
        if let fillerDate = client.formattedLastFillerDate() {
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
    
    // MARK: - UITextViewDelegate
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let client = client else { return }
        client.notes = notesTextView.text
        appDelegate().saveContext()
    }
    
    // MARK: - Actions
    @IBAction func editClientPressed(_ sender: UIButton) {
        guard let client = client else { return }
        self.namePriorToEdit = client.formattedName()
        let clientController = ClientController(nibName: "ClientController", bundle: nil)
        clientController.delegate = self
        clientController.client = self.client
        showContextualMenu(
            clientController,
            options: ContextMenu.Options(
                allowTapDismiss: false),
            delegate: self)
    }
    @IBAction func showConsentButtonPressed(_ sender: UIButton) {
        guard let client = client, let signatureData = client.signature as Data?, let signatureDate = client.formattedSignatureDate() else {
            return
//            fatalError("Couldn't find signature image or date when trying to show consent overlay!")
        }
        let clientConsentController = ClientConsentController(nibName: "ClientConsentController", bundle: nil)
        clientConsentController.signatureImage = UIImage(data: signatureData)
        clientConsentController.signatureDate = signatureDate
        showContextualMenu(clientConsentController)
    }
    
    // MARK: - ContextMenuDelegate
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
    }
    
    // MARK: - ClientControllerDelegate
    func clientControllerDidSave(client: Client) {
        let nameDidChange = self.namePriorToEdit != client.formattedName()
        self.client = client
        loadClientData()
        if nameDidChange {
            // if the name changed let DetailControll tell the ListController so it can update
            delegate?.clientNameWasEdited(client: client)
        }
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

protocol ClientViewControllerDelegate {
    func clientNameWasEdited(client: Client)
}
