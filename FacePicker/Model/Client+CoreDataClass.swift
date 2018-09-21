//
//  Client+CoreDataClass.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Client)
public class Client: NSManagedObject {
    public static var dateFormat: String {
        return "MMMM d, yyyy"
    }
    public static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = Client.dateFormat
        return formatter.string(from: date)
    }
    private func formattedDate(_ date: NSDate?) -> String? {
        if let date = date as Date? {
            return Client.formatDate(date)
        }
        return nil
    }
    public func formattedDOB() -> String? {
        return formattedDate(self.dateOfBirth)
    }
    public func formattedLastNeuroDate() -> String? {
        return formattedDate(self.lastNeuroDate)
    }
    public func formattedLastFillerDate() -> String? {
        return formattedDate(self.lastFillerDate)
    }
    public func formattedSignatureDate() -> String? {
        return formattedDate(self.signatureDate)
    }
    public func formattedName() -> String {
        return String.init(format: "%@ %@", firstName, lastName)
    }
    public func formattedCityStateZip() -> String? {
        if let city = city, let state = state, let zipCode = zipCode, !city.isEmpty, !state.isEmpty, !zipCode.isEmpty {
            return String.init(format: "%@, %@ %@", city, state, zipCode)
        }
        return nil
    }
    private func formatPhone(area: String?, prefix: String?, suffix: String?, withDescriptor descriptor: String = "") -> String? {
        var phone:String? = nil
        if let area = area, let prefix = prefix, let suffix = suffix, !area.isEmpty, !prefix.isEmpty, !suffix.isEmpty {
            phone = String.init(format: "(%@) %@-%@", area, prefix, suffix)
            if !descriptor.isEmpty {
                phone = String.init(format: "%@ (%@)", phone!, descriptor)
            }
        }
        return phone
    }
    public func formattedCellPhone() -> String? {
        return formatPhone(area: cellArea, prefix: cellPrefix, suffix: cellSuffix, withDescriptor: "Cell")
    }
    public func formattedHomePhone() -> String? {
        return formatPhone(area: homeArea, prefix: homePrefix, suffix: homeSuffix, withDescriptor: "Home")
    }
    public func formattedSmoker() -> String {
        return smoker ? "Yes" : "No"
    }
}
