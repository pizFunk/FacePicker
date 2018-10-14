//
//  Session+CoreDataClass.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Session)
public class Session: NSManagedObject {
    // static
    static func create() -> Session {
        return CoreDataManager.shared.create()
    }
    
    static let entityName = "Session"
    
    static var dateFormat: String {
        return "MMMM d, yyyy"
    }
    
    static func formatDate(_ date: Date) -> String {
        let now = Date.init()
        let result = NSCalendar.current.compare(now, to: date, toGranularity: .day)
        if result == ComparisonResult.orderedSame {
            return "Today"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: date)
    }
    
    // instance
    var isEditable: Bool {
        // TODO: make this feel less icky
        return formattedDate() == "Today" || Application.Settings.editOldSessionsAllowed
    }
    private var _cachedSessionImage:UIImage? = nil
    var sessionImage: UIImage? {
        if _cachedSessionImage == nil {
            updateSessionImage()
        }
        return _cachedSessionImage ?? SessionHelper.defaultFaceImage
    }
    
    var injectionsArray: [InjectionSite] {
        get {
            return Array(injections ?? Set<InjectionSite>())
        }
    }
    
    var totalNeurotoxinUnits: Float {
        get {
            var total:Float = 0
            for injection in injectionsArray {
                if injection.type == .Neurotoxin {
                    total += injection.units
                }
            }
            return total
        }
    }
    
    var nextLabelSequence: Int64 {
        var next:Int64 = 0
        for label in labelsArray() {
            if label.sequence > next {
                next = label.sequence + 1
            }
        }
        return next
    }
    
    func formattedDate() -> String {
        return Session.formatDate(self.date as Date)
    }
    
    func updateSessionImage() {
        if let injections = self.injections {
            let sites = Array(injections)
            _cachedSessionImage = SessionHelper.textToImage(drawSites: sites, inImage: SessionHelper.defaultFaceImage)
        }
    }
    
    func labelsArray() -> Array<ProductLabel> {
        guard let labels = self.labels else {
            return [ProductLabel]()
        }
        return Array(labels).sorted { $0.sequence < $1.sequence }
    }
}
