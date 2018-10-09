//
//  UIViewController+Extensions.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    fileprivate func appDelegate() -> AppDelegate {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            Application.onError("Couldn't get AppDelegate!")
            return AppDelegate()
        }
        return appDelegate
    }
    
    func managedContext() -> NSManagedObjectContext {
        return appDelegate().persistentContainer.viewContext
    }
    
    func setEnabled(_ enabled: Bool, includingNavigationController: Bool = true) {
        if includingNavigationController && navigationController != nil {
            navigationController?.setEnabled(enabled)
            return
        }
        if !enabled {
            let blockingView = UIView()
            blockingView.backgroundColor = ViewHelper.blockingViewBackgroundColor
//            blockingView.alpha = 0.5
            blockingView.tag = 8675309
            view.addSubview(blockingView)
            view.bringSubview(toFront: blockingView)
            blockingView.frame = CGRect(origin: view.bounds.origin, size: view.bounds.size)
        } else {
            let blockingView = view.viewWithTag(8675309)
            blockingView?.removeFromSuperview()
        }
        view.isUserInteractionEnabled = enabled
    }
    
    func setNavBarButtonsEnabled(_ enabled: Bool, buttonsToIgnore: [UIBarButtonItem]? = nil) {
        var barButtons = [UIBarButtonItem]()
        
        if let rightBarButtons = navigationItem.rightBarButtonItems {
            barButtons.append(contentsOf: rightBarButtons)
        }
        if let leftBarButtons = navigationItem.leftBarButtonItems {
            barButtons.append(contentsOf: leftBarButtons)
        }
        
        for button in barButtons {
            if !(buttonsToIgnore?.contains(button) ?? false) {
                button.isEnabled = enabled
            }
        }
    }

    func createDoneToolbarForDatePicker() -> UIToolbar {
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        doneToolbar.setItems([
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIViewController.dismissDatePicker)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            ], animated: false)
        doneToolbar.isUserInteractionEnabled = true
        
        return doneToolbar
    }
    
    @objc
    func dismissDatePicker() {
        view.endEditing(true)
    }
}
