//
//  InvoiceHelper.swift
//  FacePicker
//
//  Created by matthew on 10/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//

class InvoiceHelper {
    static func formatCount(_ count: Int64) -> String {
        return count.description
    }
    
    static func formatCount(_ count: Float) -> String {
        return count.rounded() != count ? count.description : String(format: "%.0f", count)
    }
    
    static func formatPrice(_ price: Int64) -> String {
        return "$\(price.description)"
    }
    
    static func formatPrice(_ price: Float) -> String {
        let format = price.rounded() != price ? "$%.2f" : "$%.0f"
        return String(format: format, price)
    }
}
