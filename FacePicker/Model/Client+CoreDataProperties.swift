//
//  Client+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 9/15/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension Client {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Client> {
        return NSFetchRequest<Client>(entityName: "Client")
    }

    @NSManaged public var cellArea: String?
    @NSManaged public var cellPrefix: String?
    @NSManaged public var cellSuffix: String?
    @NSManaged public var city: String?
    @NSManaged public var dateOfBirth: NSDate?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String
    @NSManaged public var homeArea: String?
    @NSManaged public var homePrefix: String?
    @NSManaged public var homeSuffix: String?
    @NSManaged public var id: UUID?
    @NSManaged public var lastFillerDate: NSDate?
    @NSManaged public var lastFillerProduct: String?
    @NSManaged public var lastName: String
    @NSManaged public var lastNeuroDate: NSDate?
    @NSManaged public var lastNeuroProduct: String?
    @NSManaged public var medicalConditions: String?
    @NSManaged public var medications: String?
    @NSManaged public var referer: String?
    @NSManaged public var signature: NSData?
    @NSManaged public var signatureDate: NSDate?
    @NSManaged public var smokeHowMuch: String?
    @NSManaged public var smoker: Bool
    @NSManaged public var state: String?
    @NSManaged public var streetAddress: String?
    @NSManaged public var zipCode: String?
    @NSManaged public var notes: String?
    @NSManaged public var sessions: Set<Session>?
}

// MARK: Generated accessors for sessions
extension Client {

    @objc(addSessionsObject:)
    @NSManaged public func addToSessions(_ value: Session)

    @objc(removeSessionsObject:)
    @NSManaged public func removeFromSessions(_ value: Session)

    @objc(addSessions:)
    @NSManaged public func addToSessions(_ values: NSSet)

    @objc(removeSessions:)
    @NSManaged public func removeFromSessions(_ values: NSSet)

}
