//
//  ClientImporter.swift
//  FacePicker
//
//  Created by matthew on 10/1/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ClientImporter {
    let possibleDateFormats = ["M/d/yyyy", "M/d/yy", "MMM d, yyyy", "MMMM d, yyyy"]
    private var uniqueDateCounter = 0
    
    // storage
    private var clients = [FullName:[Date]]()
    var clientsWithDates:[FullName:[Date]] {
        get {
            return clients
        }
    }
    private var allClients = [FullName:[FullName]]()
    var clientsWithAssociations:[FullName:[FullName]] {
        get {
            return allClients
        }
    }
}

extension ClientImporter {
    
    func retrieveClientsFromCSV(withUrl url: URL, namesOnly: Bool = false, nameAndDateFieldsSwapped: Bool = false) {
        do {
            let contents = try String(contentsOf: url).replacingOccurrences(of: "\n\n", with: "\n") // doesn't work?!
            let lines = contents.components(separatedBy: .newlines)
            var currentWorkingDate = Date()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = possibleDateFormats[0]
            var lineNumber = 0
            var currentGroup = [FullName]()
            for var line in lines {
                var foundNextDate = false
                lineNumber += 1
                line = replaceCommas(csvRow: line)
                let fields = line.components(separatedBy: "|")
                if fields.count < 2 {
                    continue
                }
                let name = fields[nameAndDateFieldsSwapped ? 0 : 1]
                if name.isEmpty {
                    continue
                }
                let fullName = makeCleanFullName(name: name)
                let date = fields[nameAndDateFieldsSwapped ? 1 : 0].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "Sept", with: "Sep")
                if !date.isEmpty {
                    // not sure why this matches every date!
                    if let nextDate = formatter.date(from: date) {
                        uniqueDateCounter += 1
                        currentWorkingDate = nextDate
                        foundNextDate = true
                    }
                }
                if !namesOnly {
                    if !clients.keys.contains(fullName) {
                        clients[fullName] = [Date]()
                    }
                    clients[fullName]!.append(currentWorkingDate)
                }
                // create separate list will all names
                if !allClients.keys.contains(fullName) {
                    allClients[fullName] = [FullName]()
                }
                if foundNextDate && currentGroup.count > 0 {
                    // build associations
                    for name in currentGroup {
                        for associate in currentGroup {
                            if name != associate && !allClients[name]!.contains(associate) {
                                allClients[name]!.append(associate)
                            }
                        }
                    }
                    // clear group and start new
                    currentGroup.removeAll()
                }
                currentGroup.append(fullName)
            }
        } catch {
            Application.onError("Error importing file: couldn't load contents with error: \(error)")
        }
    }
    
    func saveClientsToTextFile(withUrl url: URL, andClients clientsToSave: [FullName:[Date]]) {
        var contents = ""
        let formatter = DateFormatter()
        formatter.dateFormat = possibleDateFormats[3]
        let sortedKeys = clientsToSave.keys.sorted { $0 < $1 }
        contents.append("\(sortedKeys.count) unique clients.\n")
        
        contents.append("\nAll clients with dates:\n\n")
        
        for key in sortedKeys {
            contents.append("\(key)\n")
            guard var dates = clientsToSave[key] else { continue }
            dates.sort()
            for date in dates {
                let dateString = formatter.string(from: date)
                contents.append("\t\(dateString)\n")
            }
            contents.append("\n")
        }
        
        do {
            try contents.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            Application.onError("Error saving file: couldn't write to file with error \(error)")
        }
    }
}

private extension ClientImporter {
    private func replaceCommas(csvRow row: String) -> String {
        var newString = ""
        var insideQuotedField = false
        for character in row {
            var newChar = character
            if character == "," && !insideQuotedField {
                newChar = "|"
            } else if character == "\"" {
                insideQuotedField = !insideQuotedField
            }
            newString.append(newChar)
        }
        return newString
    }
    
    private func makeCleanFullName(name: String) -> FullName {
        // remove asterix
        var fullName = name.replacingOccurrences(of: "*", with: "")
        var firstName = "", lastName = ""
        
        // remove leading spaces
        if fullName.first! == " ", let index = fullName.firstIndex(where: { char in return char != " " }) {
            fullName = String(fullName[index...])
        }

        // remove trailing spaces
        while let index = fullName.lastIndex(of: " "), fullName.index(after: index) == fullName.endIndex {
            fullName = String(fullName[..<index])
        }

        // split, remove trailing spaces from last name and rejoin
        var splitName = fullName.components(separatedBy: " ")
        if splitName.count > 1 {
            repeat {
                lastName = splitName.removeLast() // grab the last element first, in the case that the first name is something like "Mary Ann"
            } while lastName.isEmpty || lastName.contains(")")
            for i in 0..<splitName.count {
                splitName[i].capitalizeFirstLetter()
            }
            firstName = splitName.joined(separator: " ")
        } else {
            firstName = splitName[0].replacingOccurrences(of: " ", with: "").capitalizingFirstLetter()
        }
        if lastName.contains("-") {
            var splitLastName = lastName.components(separatedBy: "-")
            for i in 0..<splitLastName.count {
                splitLastName[i].capitalizeFirstLetter()
            }
            lastName = splitLastName.joined(separator: "-")
        } else {
            lastName.capitalizeFirstLetter()
        }
        
        return FullName(firstName: firstName, lastName: lastName)
    }
}
