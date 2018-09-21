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
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func managedContext() -> NSManagedObjectContext {
        return appDelegate().persistentContainer.viewContext
    }
}
