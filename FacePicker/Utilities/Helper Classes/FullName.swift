//
//  FullName.swift
//  FacePicker
//
//  Created by matthew on 10/2/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation

public struct FullName: Hashable, Comparable, CustomStringConvertible {
    var firstName:String = ""
    var lastName:String = ""
    
    public static func < (lhs: FullName, rhs: FullName) -> Bool {
        return (lhs.firstName + lhs.lastName) < (rhs.firstName + rhs.lastName)
    }
    public var description: String {
        var name = firstName
        if !lastName.isEmpty {
            name += " " + lastName
        }
        return name
    }
}
