//
//  Enums.swift
//  FacePicker
//
//  Created by matthew on 10/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

public enum InjectionType: Int, CustomStringConvertible {
    case Neurotoxin = 0
    case Filler = 1
//    case Latisse = 2
    
    static var toArray: [String] {
        return [InjectionType.Neurotoxin.description, InjectionType.Filler.description]
    }
    
    static func fromString(_ type: String) -> InjectionType? {
        if let index = InjectionType.toArray.index(of: type) {
            return InjectionType(rawValue: index)
        }
        return nil
    }
    
    public var description: String {
        switch self {
        case .Neurotoxin: return "Neurotoxin"
        case .Filler: return "Filler"
//        case .Latisse: return "Latisse"
        }
    }
}

public enum ProductType: Int, CustomStringConvertible {
    case Filler
    case Latisse
    
    static var toArray: [String] {
        return [ProductType.Filler.description, ProductType.Latisse.description]
    }
    
    public var description: String {
        switch self {
        case .Filler:
            return "Filler"
        case .Latisse:
            return "Latisse"
        }
    }
}

public enum PaymentType: Int, CustomStringConvertible {
    case CreditCard
    case Check
    case Cash
    case Mertz
    case Venmo
    
    static var toArray: [String] {
        var array = [String]()
        array.append(PaymentType.CreditCard.description)
        array.append(PaymentType.Check.description)
        array.append(PaymentType.Cash.description)
        array.append(PaymentType.Mertz.description)
        array.append(PaymentType.Venmo.description)
        return array
    }
    
    static func fromString(_ type: String) -> PaymentType? {
        if let index = PaymentType.toArray.index(of: type) {
            return PaymentType(rawValue: index)
        }
        return nil
    }
    
    public var description: String {
        switch self {
        case .CreditCard:
            return "Credit Card"
        case .Check:
            return "Check"
        case .Cash:
            return "Cash"
        case .Mertz:
            return "Mertz Card"
        case .Venmo:
            return "Venmo"
        }
    }
}

enum SiteMenuControllerState {
    case Saving
    case Deleting
    case Other
}
