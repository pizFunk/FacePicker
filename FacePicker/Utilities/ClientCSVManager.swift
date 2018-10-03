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

class ClientCSVManager {
    static let shortYearCompactDateFormat = "M/d/yy"
    static let longYearCompactDateFormat = "M/d/yyyy"
    static let abbreviatedMonthDateFormat = "MMM d, yyyy"
    static let fullMonthDateFormat =  "MMMM d, yyyy"
    let possibleDateFormats = [ClientCSVManager.longYearCompactDateFormat, ClientCSVManager.shortYearCompactDateFormat, ClientCSVManager.abbreviatedMonthDateFormat, ClientCSVManager.fullMonthDateFormat]
    private var uniqueDateCounter = 0
    
    // raw file storage
    private var rawFiles = [URL:String]() // [url:contents]
    
    // client storage
    private var clients = [FullName:[Date]]()
    var clientsWithDates:[FullName:[Date]] {
        get {
            return clients
        }
    }
    private var contexts = [FullName:ClientContext]()
    var clientContexts:[FullName:ClientContext] {
        get {
            return contexts
        }
    }
}

extension ClientCSVManager {
    
    func importClientsFromCSV(withUrl url: URL, namesOnly: Bool = false, nameAndDateFieldsSwapped: Bool = false) {
        do {
            let contents = try String(contentsOf: url).replacingOccurrences(of: "\n\n", with: "\n") // newline replacement doesn't work?!
            rawFiles[url] = contents
            let lines = contents.components(separatedBy: .newlines)
            var currentWorkingDate = Date()
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = ClientCSVManager.longYearCompactDateFormat
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
                if name.isEmpty || name.lowercased().contains("name") {
                    continue
                }
                let fullName = makeCleanFullName(name: name)
                let date = fields[nameAndDateFieldsSwapped ? 1 : 0].replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "Sept", with: "Sep")
                if !date.isEmpty {
                    // not sure why this format matches every date!
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
                if !contexts.keys.contains(fullName) {
                    let context = ClientContext(initialRawNameString: name, cleanFullName: fullName)
                    contexts[fullName] = context
                }
                contexts[fullName]!.addRawNameString(name)
                contexts[fullName]!.addDate(currentWorkingDate)
                if foundNextDate && currentGroup.count > 0 {
                    // build associations
                    for name in currentGroup {
                        for associate in currentGroup {
                            if name != associate && !contexts[name]!.containsAssociate(associate) {
                                contexts[name]!.addAssociate(associate)
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
    
    func exportClientMergesToCSV(_ mergedPairs: [MergedPair], forUrl url: URL) {
        guard var newContents = rawFiles[url] else {
            return
        }
        for mergedPair in mergedPairs {
            for originalNameString in mergedPair.originalNameStrings {
                // wrap in commas so we don't replace substrings that also match by mistake
                let original = ",\(originalNameString),"
                let replacement = ",\(mergedPair.replacementCleanFullName),"
                print("replacing \"\(original)\" with \"\(replacement)\"")
                newContents = newContents.replacingOccurrences(of: original, with: replacement)
            }
        }
        // attempt to save the new CSV
        do {
            try newContents.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            Application.onError("Error saving file: couldn't write to file with error \(error)")
        }
    }
    
    func exportClientMergesToCSV(_ mergedPairs: [MergedPair], forUrls urls: [URL]) {
        for url in urls {
            exportClientMergesToCSV(mergedPairs, forUrl: url)
        }
    }
    
    func saveClientsToTextFile(withUrl url: URL, andClients clientsToSave: [FullName:[Date]]) {
        var contents = ""
        let formatter = DateFormatter()
        formatter.dateFormat = ClientCSVManager.fullMonthDateFormat
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

private extension ClientCSVManager {
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
        // stupid specific case
        fullName = fullName.replacingOccurrences(of: "Ma", with: "Mary Ann")
        
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
