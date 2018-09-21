//
//  UIImage+PixelColor.swift
//  FacePicker
//
//  Created by matthew on 9/15/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    func getPixelColor(x: Int, y: Int) -> UIColor {
        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)
        
        let numberOfComponents = 4 // (r,g,b,a)
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
        
        let b = CGFloat(data![pixelData]) / 255.0    // suspect blue
        let g = CGFloat(data![pixelData+1]) / 255.0
        let r = CGFloat(data![pixelData+2]) / 255.0
        let a = CGFloat(data![pixelData+3]) / 255.0  // suspect red
        
        if r != 0 || g != 0 || b != 0 || a != 0 {
            print("pixelColor (\(x),\(y)) r:\(r), g:\(g), b:\(b), a:\(a)")
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
