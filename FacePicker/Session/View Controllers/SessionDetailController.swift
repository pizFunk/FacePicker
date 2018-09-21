//
//  SessionDetailController.swift
//  FacePicker
//
//  Created by matthew on 9/21/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionDetailController: UIViewController {

    let totalsViewController = SessionTotalsController()
    var session: Session? {
        didSet {
            totalsViewController.session = session
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.addSubview(totalsViewController.view)
        totalsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        ViewHelper.setViewEdges(for: totalsViewController.view, equalTo: view, withConstant: 0, excludingBottom: true)
//        totalsViewController.view.backgroundColor = UIColor.green
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("SessionDetailController: view.bounds = \(view.bounds)")
        print("SessionDetailController: totalsViewController.view.bounds = \(totalsViewController.view.bounds)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
