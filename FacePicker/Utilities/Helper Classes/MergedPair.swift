//
//  MergedPair.swift
//  FacePicker
//
//  Created by matthew on 10/2/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation

struct MergedPair {
    private var original:ClientContext
    private var replacement:ClientContext
    
    init(original: ClientContext, replacement: ClientContext) {
        self.original = original
        self.replacement = replacement
    }
}

extension MergedPair {
    var originalNameStrings:[String] {
        get {
            return original.rawNameStrings
        }
    }
    
    var replacementNameStrings:[String] {
        get {
            return replacement.rawNameStrings
        }
    }
    
    var replacementCleanFullName:String {
        get {
            return replacement.cleanFullName.description
        }
    }
}
