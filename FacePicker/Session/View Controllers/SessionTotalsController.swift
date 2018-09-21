//
//  SessionTotalsController.swift
//  FacePicker
//
//  Created by matthew on 9/19/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionTotalsController: UIViewController {
    var stackView = UIStackView()
    var session: Session? {
        didSet {
            setTotals()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        ViewHelper.setBottom(for: view, equalTo: stackView)
        ViewHelper.setTop(for: stackView, equalTo: view)
        ViewHelper.setLeadingAndTrailing(for: stackView, equalTo: view, withConstant: 15)
        stackView.axis = .vertical
        stackView.spacing = 8.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(SessionTotalsController.onSessionDidChange(notification:)), name: .sessionDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("SessionTotalsController: view.bounds = \(view.bounds)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func onSessionDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Session], let sessionData = userInfo.first else {
            return
        }
        self.session = sessionData.value
    }
    
    private func setTotals() {
        guard let session = session else {
            return
        }
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
            stackView.removeArrangedSubview(view)
        }
        
        if let injections = session.injections {
            var totalsByType = [String: Float]()
            
            for injection in injections {
                if var sum = totalsByType[injection.type.description] {
                    sum += injection.units
                    totalsByType[injection.type.description] = sum
                } else {
                    totalsByType[injection.type.description] = injection.units
                }
            }
            if totalsByType.count > 0 {
                let font = UIFont.systemFont(ofSize: 20)
                let boldFont = UIFont.systemFont(ofSize: 20, weight: .bold)
                let titleLabel = UILabel()
                titleLabel.text = "Totals:"
                titleLabel.font = boldFont.withSize(24)
                stackView.addArrangedSubview(titleLabel)
                for (key, value) in totalsByType {
                    let unitLabel = UILabel()
                    let label = UILabel()
                    let typeLabel = UILabel()
                    
                    unitLabel.text = "\(value)"
                    SessionHelper.setColor(forLabel: unitLabel, withStringType: key)
                    unitLabel.font = boldFont
                    unitLabel.setContentHuggingPriority(.required, for: .horizontal)
                    unitLabel.sizeToFit()
                    
                    label.text = "units of"
                    label.font = font
                    label.setContentHuggingPriority(.required, for: .horizontal)
                    label.sizeToFit()
                    
                    typeLabel.text = "\(key)"
                    SessionHelper.setColor(forLabel: typeLabel, withStringType: key)
                    typeLabel.font = boldFont
                    typeLabel.sizeToFit()
                    
                    let view = UIView()
                    view.addSubview(unitLabel)
                    view.addSubview(label)
                    ViewHelper.setLeadingOf(label, equalToTrailingOf: unitLabel, withConstant: 5)
                    ViewHelper.centerVerically(label, to: unitLabel)
                    view.addSubview(typeLabel)
                    ViewHelper.setLeadingOf(typeLabel, equalToTrailingOf: label, withConstant: 5)
                    ViewHelper.centerVerically(typeLabel, to: label)
                    ViewHelper.setOrigin(for: view, equalTo: unitLabel)
                    ViewHelper.setTrailingAndBottom(for: view, equalTo: typeLabel)
//                    view.backgroundColor = UIColor(white: 0.8, alpha: 1.0)

                    stackView.addArrangedSubview(view)
                }
            }
        }
    }
}
