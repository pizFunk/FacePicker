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
    public static let entityName = "InjectionSite"
    
    func setIdAndPosition(x: Double, y: Double, id: UUID) {
        self.xPos = x
        self.yPos = y
        self.id = id
    }
    
    func setUnits(_ units: Float, ofType type: InjectionType) {
        self.units = units
        self.type = type
    }
    
//    func unitsAreSet() -> Bool {
//        return self.units != nil && self.type != nil
//    }
    
//    func clearUnits() {
//        self.units = nil
//        self.type = nil
//    }
    
    func formattedUnits() -> String {
        return self.units > 0 ? self.units.description : "\u{2718}" // String(format: "%.1f", self.units)
    }
}

public enum InjectionType: Int, CustomStringConvertible {
    case NeuroToxin = 0
    case Filler = 1
    case Latisse = 2
    
    static var toArray: [String] {
        return [InjectionType.NeuroToxin.description, InjectionType.Filler.description]
    }
    
    static func fromString(_ type: String) -> InjectionType? {
        if let index = InjectionType.toArray.index(of: type) {
            return InjectionType(rawValue: index)
        }
        return nil
    }
    
    public var description: String {
        switch self {
        case .NeuroToxin: return "NeuroToxin"
        case .Filler: return "Filler"
        case .Latisse: return "Latisse"
        }
    }
}
