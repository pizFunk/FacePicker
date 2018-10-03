//
//  ClientDifference.swift
//  FacePicker
//
//  Created by matthew on 10/2/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation

public struct ClientDifference {
    var firstContext: ClientContext?
    var secondContext: ClientContext?
}

extension ClientDifference {
    var firstFullName:FullName? {
        get {
            return firstContext?.cleanFullName
        }
    }
    
    var secondFullName:FullName? {
        get {
            return secondContext?.cleanFullName
        }
    }
    
    var firstSortedDates:[String]? {
        get {
            return firstContext?.sortedFormattedDates
        }
    }
    
    var secondSortedDates:[String]? {
        get {
            return secondContext?.sortedFormattedDates
        }
    }
    
    var firstSortedAssociations:[FullName]? {
        get {
            return firstContext?.sortedAssociations
        }
    }
    
    var secondSortedAssociations:[FullName]? {
        get {
            return secondContext?.sortedAssociations
        }
    }
}
