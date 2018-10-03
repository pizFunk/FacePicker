//
//  ClientContext.swift
//  FacePicker
//
//  Created by matthew on 10/2/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation

class ClientContext: CustomStringConvertible {
    private var _rawNameStrings:[String]
    private var _cleanFullName:FullName
    private var _visitDates = [Date]()
    private var _associatedClients = [FullName]()
    
    init(initialRawNameString rawName: String, cleanFullName: FullName) {
        self._rawNameStrings = [String](arrayLiteral: rawName)
        self._cleanFullName = cleanFullName
    }
    
    init(initialRawNameString rawName: String, cleanFullName: FullName, visitDates: [Date], associatedClients: [FullName]) {
        self._rawNameStrings = [String](arrayLiteral: rawName)
        self._cleanFullName = cleanFullName
        self._visitDates = visitDates
        self._associatedClients = associatedClients
    }
}

extension ClientContext {
    var rawNameStrings:[String] {
        get {
            return _rawNameStrings
        }
    }
    
    func addRawNameString(_ rawNameString: String) {
        if !_rawNameStrings.contains(rawNameString) {
            _rawNameStrings.append(rawNameString)
        }
    }
    
    var cleanFullName:FullName {
        get {
            return _cleanFullName
        }
    }
    
    var sortedFormattedDates:[String] {
        get {
            var formattedDates = [String]()
            let formatter = DateFormatter()
            formatter.dateFormat = ClientCSVManager.fullMonthDateFormat
            for date in _visitDates.sorted() {
                formattedDates.append(formatter.string(from: date))
            }
            return formattedDates
        }
    }
    
    var description: String {
        var description = "Dates appeared:\n"
        description +=    "---------------\n"
        description += sortedFormattedDates.joined(separator: "\n")
        description += "\nAssociated Clients:\n"
        description +=   "-------------------\n"
        for associate in _associatedClients {
            description += associate.description
        }
        return description
    }
    
    var sortedAssociations:[FullName] {
        get {
            return _associatedClients.sorted()
        }
    }
    
    func containsAssociate(_ name: FullName) -> Bool {
        return _associatedClients.contains(name)
    }
    
    func addAssociate(_ name: FullName) {
        _associatedClients.append(name)
    }
    
    func addDate(_ date: Date) {
        _visitDates.append(date)
    }
}
