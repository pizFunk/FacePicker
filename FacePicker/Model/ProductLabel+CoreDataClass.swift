//
//  ProductLabel+CoreDataClass.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(ProductLabel)
public class ProductLabel: NSManagedObject {
    // static
    static func create() -> ProductLabel {
        return CoreDataManager.shared.create()
    }
    
    static let entityName = "ProductLabel"
    
    // instance
    private var _cachedImage:UIImage?
    
    func toImage() -> UIImage? {
        if _cachedImage == nil {
            if let data = image as Data?, let uiImage = UIImage(data: data) {
                _cachedImage = uiImage
            } else {
                // TODO: log error
            }
        }
        return _cachedImage
    }
}
