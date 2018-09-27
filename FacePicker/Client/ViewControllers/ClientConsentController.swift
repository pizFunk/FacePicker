//
//  ClientConsentController.swift
//  FacePicker
//
//  Created by matthew on 9/15/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

// MARK: - Properties

class ClientConsentController: UIViewController {
    @IBOutlet weak var signatureImageView: UIImageView!
    @IBOutlet weak var signatureDateLabel: UILabel!
    var signatureImage: UIImage?
    var signatureDate: String?
}

// MARK: - Public Functions

extension ClientConsentController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let signatureImage = signatureImage, let signatureDate = signatureDate {
            signatureImageView.image = signatureImage
            signatureDateLabel.text = signatureDate
        } else {
            Application.onError("ClientConsentController opened with no image or date to display!")
        }
        
        navigationItem.title = "Consent"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ClientConsentController.onDone(sender:)))
        
        preferredContentSize = CGSize(width: 400, height: 618)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @objc
    func onDone(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
