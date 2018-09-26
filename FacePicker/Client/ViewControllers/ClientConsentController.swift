//
//  ClientConsentController.swift
//  FacePicker
//
//  Created by matthew on 9/15/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class ClientConsentController: UIViewController {
    @IBOutlet weak var signatureImageView: UIImageView!
    @IBOutlet weak var signatureDateLabel: UILabel!
    var signatureImage: UIImage?
    var signatureDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let signatureImage = signatureImage, let signatureDate = signatureDate else {
            fatalError("ClientConsentController opened with no image or date to display!")
        }
        signatureImageView.image = signatureImage
        signatureDateLabel.text = signatureDate
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
