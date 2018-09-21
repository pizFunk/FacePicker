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
    public static var dateFormat: String {
        return "MMMM d, yyyy"
    }
    public func formattedDate() -> String {
        if let date = self.date as Date? {
            let now = Date.init()
            let result = NSCalendar.current.compare(now, to: date, toGranularity: .day)
            if result == ComparisonResult.orderedSame {
                return "Today"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = Session.dateFormat
            return formatter.string(from: date)
        }
        return ""
    }
    
    // instance
    private var _cachedSessionImage:UIImage? = nil
    var sessionImage: UIImage? {
        if _cachedSessionImage == nil {
            updateSessionImage()
        }
        return _cachedSessionImage ?? SessionHelper.defaultFaceImage
    }
    
    func updateSessionImage() {
        if let injections = self.injections {
            let sites = Array(injections)
            _cachedSessionImage = SessionHelper.textToImage(drawSites: sites, inImage: SessionHelper.defaultFaceImage)
        }
    }
}
