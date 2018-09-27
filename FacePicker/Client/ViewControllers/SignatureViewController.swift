//
//  SignatureViewController.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import SwiftSignatureView

class SignatureController: UIViewController {
    
    var signatureView = SwiftSignatureView()
    var delegate: SignatureControllerDelegate?
}

extension SignatureController {
    
    override func viewDidLoad() {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width * 0.95
        preferredContentSize = CGSize(width: width, height: width / 3)
        
        navigationItem.title = "Signature"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action:  #selector(onClear(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onDone(sender:)))
        view.backgroundColor = UIColor.red
        
        view.addSubview(signatureView)
        signatureView.backgroundColor = UIColor.white
        signatureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signatureView.topAnchor.constraint(equalTo: view.topAnchor),
            signatureView.leftAnchor.constraint(equalTo: view.leftAnchor),
            signatureView.rightAnchor.constraint(equalTo: view.rightAnchor),
            signatureView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    @objc
    func onClear(sender: UIBarButtonItem) {
        signatureView.clear()
    }
    
    @objc
    func onDone(sender: UIBarButtonItem) {
        delegate?.signatureDidFinish(signature: signatureView.signature ?? UIImage())
        dismiss(animated: true, completion: nil)
    }
}

protocol SignatureControllerDelegate {
    func signatureDidFinish(signature: UIImage) -> ()
}
