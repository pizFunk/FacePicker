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
                fatalError("Couldn't load image \"face\" from Bundle!")
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
    public static func getColor(forType type: InjectionType) -> UIColor {
        var color: UIColor
        switch type {
        case InjectionType.NeuroToxin:
//            color = SessionHelper.neurotoxinColor
            color = UIColor.purple
        case InjectionType.Filler:
//            color = SessionHelper.fillerColor
            color = UIColor.orange
        case InjectionType.Latisse:
//            color = SessionHelper.latisseColor
            color = UIColor.magenta
        }
        return color
    }
    public static func textToImage(drawSites sites: [InjectionSite], inImage image: UIImage) -> UIImage {
        let textFont = UIFont.systemFont(ofSize: 20)
        
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
}
