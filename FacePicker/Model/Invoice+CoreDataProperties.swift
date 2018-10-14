//
//  Invoice+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 10/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension Invoice {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Invoice> {
        return NSFetchRequest<Invoice>(entityName: "Invoice")
    }

    @NSManaged public var fillerCountSold: Int64
    @NSManaged public var fillerCountTotal: Int64
    @NSManaged public var fillerPricePerUnit: Int64
    @NSManaged public var latisseCountSold: Int64
    @NSManaged public var latisseCountTotal: Int64
    @NSManaged public var latissePricePerUnit: Int64
    @NSManaged public var neurotoxinPricePerUnit: Float
    @NSManaged public var neurotoxinUnitsSold: Float
    @NSManaged public var neurotoxinUnitsTotal: Float
    @NSManaged public var total: Float
    @NSManaged public var session: Session?
    @NSManaged public var payments: NSOrderedSet?

}

// MARK: Generated accessors for payments
extension Invoice {

    @objc(insertObject:inPaymentsAtIndex:)
    @NSManaged public func insertIntoPayments(_ value: Payment, at idx: Int)

    @objc(removeObjectFromPaymentsAtIndex:)
    @NSManaged public func removeFromPayments(at idx: Int)

    @objc(insertPayments:atIndexes:)
    @NSManaged public func insertIntoPayments(_ values: [Payment], at indexes: NSIndexSet)

    @objc(removePaymentsAtIndexes:)
    @NSManaged public func removeFromPayments(at indexes: NSIndexSet)

    @objc(replaceObjectInPaymentsAtIndex:withObject:)
    @NSManaged public func replacePayments(at idx: Int, with value: Payment)

    @objc(replacePaymentsAtIndexes:withPayments:)
    @NSManaged public func replacePayments(at indexes: NSIndexSet, with values: [Payment])

    @objc(addPaymentsObject:)
    @NSManaged public func addToPayments(_ value: Payment)

    @objc(removePaymentsObject:)
    @NSManaged public func removeFromPayments(_ value: Payment)

    @objc(addPayments:)
    @NSManaged public func addToPayments(_ values: NSOrderedSet)

    @objc(removePayments:)
    @NSManaged public func removeFromPayments(_ values: NSOrderedSet)

}
