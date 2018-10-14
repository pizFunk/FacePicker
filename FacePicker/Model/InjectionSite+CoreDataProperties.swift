//
//  InjectionSite+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 9/14/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension InjectionSite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InjectionSite> {
        return NSFetchRequest<InjectionSite>(entityName: InjectionSite.entityName)
    }

    @NSManaged public var units: Float
    @NSManaged public var id: UUID
    @NSManaged public var xPos: Double
    @NSManaged public var yPos: Double
    @NSManaged public var session: Session

    @NSManaged private var typeRaw: Int16
    var type: InjectionType {
        get {
            return InjectionType(rawValue: Int(self.typeRaw)) ?? InjectionType.Neurotoxin
        }
        set {
            self.typeRaw = Int16(newValue.rawValue)
        }
    }
}
