//
//  String+Extensions.swift
//  FacePicker
//
//  Created by matthew on 10/1/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst().lowercased()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
