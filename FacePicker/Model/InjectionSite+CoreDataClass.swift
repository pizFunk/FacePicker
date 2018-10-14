//
//  InjectionSite+CoreDataClass.swift
//  FacePicker
//
//  Created by matthew on 9/10/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData

public class InjectionSite: NSManagedObject {
    // static
    static func create() -> InjectionSite {
        return CoreDataManager.shared.create()
    }
    
    static let entityName = "InjectionSite"
    
    //instance
    func setIdAndPosition(x: Double, y: Double, id: UUID) {
        self.xPos = x
        self.yPos = y
        self.id = id
    }
    
    func setUnits(_ units: Float, ofType type: InjectionType) {
        self.units = units
        self.type = type
    }
    
    func formattedUnits() -> String {
        return self.units > 0 ? self.units.description : "\u{2718}" // String(format: "%.1f", self.units)
    }
}
