//
//  Payment+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 10/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension Payment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Payment> {
        return NSFetchRequest<Payment>(entityName: Payment.entityName)
    }

    @NSManaged public var type: String?
    @NSManaged public var amount: Float
    @NSManaged public var invoice: Invoice?

}
