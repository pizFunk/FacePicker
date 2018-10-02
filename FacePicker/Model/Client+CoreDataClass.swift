//
//  Client+CoreDataClass.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import UIKit
import CoreData

@objc(Client)
public class Client: NSManagedObject {
    public static let entityName = "Client"
    
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
//    public func formattedLastNeuroDate() -> String? {
//        return formattedDate(self.lastNeuroDate)
//    }
//    public func formattedLastFillerDate() -> String? {
//        return formattedDate(self.lastFillerDate)
//    }
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
    
    private static func fetchClients(context: NSManagedObjectContext) -> [Client]? {
        let fetchRequest:NSFetchRequest<Client> = Client.fetchRequest()
        var existingClients:[Client]?
        do {
            existingClients = try context.fetch(fetchRequest)
        } catch {
            Application.onError("Error when trying to fetch existing clients. error = \(error)")
        }
        return existingClients
    }
    
    public static func createClientsFromImport(clients: [FullName:[Date]]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        
        var existingClients = fetchClients(context: context)
        if let eC = existingClients {
            for client in eC {
                if client.lastName != "Pisoni" {
                    context.delete(client)
                }
            }
        }
        existingClients = fetchClients(context: context)
        
        for (client, dates) in clients {
            let clientExists = existingClients?.contains(where: { existing in
                return existing.firstName == client.firstName && existing.lastName == client.lastName
            })
            if clientExists != nil && clientExists! {
                continue
            }
            let newClient = Client(context: context)
            newClient.firstName = client.firstName
            newClient.lastName = client.lastName
            newClient.id = UUID()
            for date in dates {
                let newSession = Session(context: context)
                newSession.date = date as NSDate
                newSession.id = UUID()
                newClient.addToSessions(newSession)
            }
        }
    }
}
