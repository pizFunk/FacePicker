//
//  Payment+CoreDataClass.swift
//  FacePicker
//
//  Created by matthew on 10/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Payment)
public class Payment: NSManagedObject {
    // static
    static func create() -> Payment {
        return CoreDataManager.shared.create()
    }
    
    static let entityName = "Payment"
}
