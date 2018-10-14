//
//  Session+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 10/11/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var date: NSDate
    @NSManaged public var id: UUID
    @NSManaged public var notes: String?
    @NSManaged public var fillerCount: Int64
    @NSManaged public var latisseCount: Int64
    @NSManaged public var client: Client
    @NSManaged public var injections: Set<InjectionSite>?
    @NSManaged public var labels: Set<ProductLabel>?
    @NSManaged public var invoice: Invoice?

}

// MARK: Generated accessors for injections
extension Session {

    @objc(addInjectionsObject:)
    @NSManaged public func addToInjections(_ value: InjectionSite)

    @objc(removeInjectionsObject:)
    @NSManaged public func removeFromInjections(_ value: InjectionSite)

    @objc(addInjections:)
    @NSManaged public func addToInjections(_ values: NSSet)

    @objc(removeInjections:)
    @NSManaged public func removeFromInjections(_ values: NSSet)

}

// MARK: Generated accessors for labels
extension Session {

    @objc(addLabelsObject:)
    @NSManaged public func addToLabels(_ value: ProductLabel)

    @objc(removeLabelsObject:)
    @NSManaged public func removeFromLabels(_ value: ProductLabel)

    @objc(addLabels:)
    @NSManaged public func addToLabels(_ values: NSSet)

    @objc(removeLabels:)
    @NSManaged public func removeFromLabels(_ values: NSSet)

}
