//
//  UIViewController+Extensions.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setEnabled(_ enabled: Bool, includingNavigationController: Bool = true) {
        guard view.window != nil else {
            // view isn't showing, do nothing
            return
        }
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
    
    func createPopoverNavigationController(withTarget target: UIPopoverPresentationControllerDelegate? = nil, withRootViewController viewController: UIViewController, anchoredTo anchor: UIView, andPermittedArrowDirections arrowDirections: UIPopoverArrowDirection = .up) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.isTranslucent = false
        makeViewControllerPopover(navController, withTarget: target, anchoredTo: anchor)
        
        return navController
    }
    
    func makeViewControllerPopover(_ viewController: UIViewController, withTarget target: UIPopoverPresentationControllerDelegate? = nil, anchoredTo anchor: UIView, andPermittedArrowDirections arrowDirections: UIPopoverArrowDirection = .up) {
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.permittedArrowDirections = arrowDirections
        viewController.popoverPresentationController?.delegate = target
        viewController.popoverPresentationController?.sourceRect = anchor.bounds
        viewController.popoverPresentationController?.sourceView = anchor
    }
}
