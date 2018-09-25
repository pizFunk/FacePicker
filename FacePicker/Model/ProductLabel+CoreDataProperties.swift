//
//  ProductLabel+CoreDataProperties.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//
//

import Foundation
import CoreData


extension ProductLabel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductLabel> {
        return NSFetchRequest<ProductLabel>(entityName: ProductLabel.entityName)
    }

    @NSManaged public var image: NSData?
    @NSManaged public var session: Session?

}
