//
//  Session+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension Session {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Session> {
        return NSFetchRequest<Session>(entityName: "Session")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var id: UUID?
    @NSManaged public var injections: Set<InjectionSite>?
    @NSManaged public var client: Client?

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
