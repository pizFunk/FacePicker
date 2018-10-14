//
//  Invoice+CoreDataClass.swift
//  
//
//  Created by matthew on 10/11/18.
//
//

import Foundation
import CoreData

@objc(Invoice)
public class Invoice: NSManagedObject {
    // static
    static func create() -> Invoice {
        return CoreDataManager.shared.create()
    }
    
    static let entityName = "Invoice"
    
    static func createForSession(_ session: Session) -> Invoice {
        let invoice = Invoice.create()
        invoice.fillerCountTotal = session.fillerCount
        invoice.fillerCountSold = session.fillerCount
        invoice.latisseCountTotal = session.latisseCount
        invoice.latisseCountSold = session.latisseCount
        invoice.neurotoxinUnitsTotal = session.totalNeurotoxinUnits
        invoice.neurotoxinUnitsSold = session.totalNeurotoxinUnits
        
        return invoice
    }
    
    // instance
    var paymentsArray: [Payment] {
        if let paymentsArray = payments?.array as? [Payment] {
            return paymentsArray
        }
        return [Payment]()
    }
    
    var paymentsTotal: Float {
        var total:Float = 0
        for payment in paymentsArray {
            total += payment.amount
        }
        return total
    }
    
    var neurotoxinTotal: Float {
        return neurotoxinUnitsSold * neurotoxinPricePerUnit
    }
    
    var neurotoxinDiscount: Float {
        return (neurotoxinUnitsTotal - neurotoxinUnitsSold) * neurotoxinPricePerUnit
    }
    
    var neurotoxinUnitsDiscounted: Float {
        get {
            return neurotoxinUnitsTotal - neurotoxinUnitsSold
        }
        set {
            neurotoxinUnitsSold = neurotoxinUnitsTotal - newValue
        }
    }
    
    var fillerTotal: Float {
        return Float(fillerCountSold * fillerPricePerUnit)
    }
    
    var fillerDiscount: Float {
        return Float((fillerCountTotal - fillerCountSold) * fillerPricePerUnit)
    }
    
    var fillerCountDiscounted: Int64 {
        get {
            return fillerCountTotal - fillerCountSold
        }
        set {
            fillerCountSold = fillerCountTotal - newValue
        }
    }
    
    var latisseTotal: Float {
        return Float(latisseCountSold * latissePricePerUnit)
    }
    
    func setDefaults() {
        // TODO: change to global settings
        fillerPricePerUnit = 350
        latissePricePerUnit = 120
        neurotoxinPricePerUnit = 9
    }
}
