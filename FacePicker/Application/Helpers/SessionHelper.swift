//
//  SessionHelper.swift
//  FacePicker
//
//  Created by matthew on 9/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

public class SessionHelper {
    private static var _cachedDefaultFaceImage: UIImage? = nil
    public static var neurotoxinColor = ViewHelper.Colors.Scheme3.one
    public static var fillerColor = ViewHelper.Colors.Scheme3.two
    public static var latisseColor = ViewHelper.Colors.Scheme3.three
    public static var defaultFaceImage: UIImage {
        if _cachedDefaultFaceImage == nil {
            guard let faceImage = UIImage(named: "face") else {
                Application.onError("Couldn't load image \"face\" from Bundle!")
                return UIImage()
            }
            _cachedDefaultFaceImage = faceImage
        }
        return _cachedDefaultFaceImage!
    }
    public static func setTitleAndColor(forButton button: UIButton, withSite site: InjectionSite) {
        let buttonTitle = site.formattedUnits()
        let centerX = button.center.x
        button.setTitle(buttonTitle, for: .normal)
        button.sizeToFit()
        button.center.x = centerX
        button.setTitleColor(SessionHelper.getColor(forType: site.type), for: .normal)
    }
    public static func setTitleAndColor(forLabel label: UILabel, withSite site: InjectionSite) {
        label.text = site.formattedUnits()
        SessionHelper.setColor(forLabel: label, withType: site.type)
    }
    public static func setColor(forLabel label: UILabel, withStringType stringType: String) {
        guard let type = InjectionType.fromString(stringType) else { return }
        SessionHelper.setColor(forLabel: label, withType: type)
    }
    public static func setColor(forLabel label: UILabel, withType type: InjectionType) {
        label.textColor = SessionHelper.getColor(forType: type)
    }
    public static func setColor(forLabel label: UILabel, withType type: ProductType) {
        label.textColor = SessionHelper.getColor(forType: type)
    }
    public static func getColor(forType type: InjectionType) -> UIColor {
        var color: UIColor
        switch type {
        case .Neurotoxin:
            //            color = SessionHelper.neurotoxinColor
            color = UIColor.purple
        case .Filler:
            //            color = SessionHelper.fillerColor
            color = UIColor.magenta
        }
        return color
    }
    public static func getColor(forType type: ProductType) -> UIColor {
        var color: UIColor
        switch type {
        case .Filler:
            color = UIColor.magenta
        case .Latisse:
            color = UIColor.orange
        }
        return color
    }
    public static func textToImage(drawSites sites: [InjectionSite], inImage image: UIImage) -> UIImage {
        let textFont = UIFont.systemFont(ofSize: 18)
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
        for site in sites {
            let text = site.formattedUnits()
            let label = UILabel()
            label.text = text
            label.sizeToFit()
            var point = ViewHelper.resolvePixelsFromProportions(size: image.size, x: site.xPos, y: site.yPos)
            point.x -= label.bounds.width / 2
            point.y -= label.bounds.height / 2
            let rect = CGRect(origin: point, size: image.size)
            let textFontAttributes = [
                NSAttributedStringKey.font: textFont,
                NSAttributedStringKey.foregroundColor: SessionHelper.getColor(forType: site.type),
                ] as [NSAttributedStringKey : Any]
            text.draw(in: rect, withAttributes: textFontAttributes)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    static func createTotalsRow(value: String, description: String, type: String) -> SessionTotalsRow {
        let totalsRowView = SessionTotalsRow()
        totalsRowView.unitsLabel.text = value
        totalsRowView.descriptionLabel.text = description
        totalsRowView.typeLabel.text = type
        
        return totalsRowView
    }
    
    static func createTotalsRow(value: String, type: InjectionType) -> SessionTotalsRow {
        var description = ""
        if type == .Neurotoxin {
            description = Float(value) == 1 ? "unit of" : "units of"
        }
        let totalsRowView = createTotalsRow(value: value, description: description, type: type.description)
        setColor(forLabel: totalsRowView.unitsLabel, withType: type)
        setColor(forLabel: totalsRowView.typeLabel, withType: type)
        
        return totalsRowView
    }
    
    static func createTotalsRow(value: String, type: ProductType) -> SessionTotalsRow {
        var description = ""
        let singular = Float(value) == 1
        switch type {
        case .Filler:
            description = singular ? "syringe" : "syringes"
        case .Latisse:
            description = singular ? "bottle" : "bottles"
        }
        description += " of"
        let totalsRowView = createTotalsRow(value: value, description: description, type: type.description)
        setColor(forLabel: totalsRowView.unitsLabel, withType: type)
        setColor(forLabel: totalsRowView.typeLabel, withType: type)
        
        return totalsRowView
    }
}
