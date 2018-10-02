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
}
