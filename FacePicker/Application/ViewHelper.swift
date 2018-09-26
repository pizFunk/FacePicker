//
//  ViewHelper.swift
//  FacePicker
//
//  Created by matthew on 9/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation
import UIKit
import DropDown

public class ViewHelper {
    // colors
    public static let defaultBorderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
    public static let validationColor = UIColor.red.cgColor
    // other named colors
    public class Colors {
        public static let deepBlue = UIColor(red: 11/255, green: 8/255, blue: 76/255, alpha: 1)
        public static let deepBlueGreen = UIColor(red: 8/255, green: 70/255, blue: 70/255, alpha: 1)
        public static let deepPink = UIColor(red: 112/255, green: 8/255, blue: 69/255, alpha: 1)
        public static let deepPurple = UIColor(red: 64/255, green: 8/255, blue: 112/255, alpha: 1)
        public static let deepRed = UIColor(red: 90/255, green: 15/255, blue: 15/255, alpha: 1)
        public static let maroon = UIColor(red: 76/255, green: 8/255, blue: 48/255, alpha: 1)
        public static let mediumBlue = UIColor(red: 9/255, green: 89/255, blue: 130/255, alpha: 1)
        public static let purple = UIColor(red: 153/255, green: 0/255, blue: 153/255, alpha: 1)
        public static let blue = UIColor(red: 0/255, green: 102/255, blue: 204/255, alpha: 1)
        public static let red = UIColor(red: 204/255, green: 0/255, blue: 0/255, alpha: 1)
        public class Scheme1 {
            public static let one = ViewHelper.colorFromRGB(red: 255, green: 182, blue: 23)
            public static let two = ViewHelper.colorFromRGB(red: 224, green: 23, blue: 255)
            public static let three = ViewHelper.colorFromRGB(red: 23, green: 96, blue: 255)
        }
        public class Scheme2 {
            public static let one = ViewHelper.colorFromRGB(red: 171, green: 2, blue: 255)
            public static let two = ViewHelper.colorFromRGB(red: 255, green: 2, blue: 145)
            public static let three = ViewHelper.colorFromRGB(red: 44, green: 2, blue: 255)
        }
        public class Scheme3 {
            public static let one = ViewHelper.colorFromRGB(red: 91, green: 255, blue: 2)
            public static let two = ViewHelper.colorFromRGB(red: 255, green: 86, blue: 1)
            public static let three = ViewHelper.colorFromRGB(red: 166, green: 1, blue: 255)
        }
    }
    // styling
    public static func colorFromRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    public static func positionView(_ view: UIView, at point: CGPoint) {
        view.center.x = point.x
        view.center.y = point.y
    }
    public static func resolvePixelsFromProportions(size: CGSize, x: Double, y: Double) -> CGPoint {
        let pixelX = Double(size.width) * x
        let pixelY = Double(size.height) * y
        
        return CGPoint(x: pixelX, y: pixelY)
    }
    public static func roundCornersOnView(_ view: UIView, withRadius radius: CGFloat = 8) {
        view.layer.cornerRadius = radius
        view.layer.masksToBounds = radius > 0
    }
    public static func setBorderOnView(_ view: UIView, withColor color: CGColor, andWidth width: CGFloat = 1.0, rounded: Bool = true) {
        view.layer.borderWidth = width
        view.layer.borderColor = color
        if rounded {
            ViewHelper.roundCornersOnView(view)
        }
    }
    public static func clearBorderOnView(_ view: UIView) {
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.clear.cgColor
        ViewHelper.roundCornersOnView(view, withRadius: 0)
    }
    // dropdown
    public static func setDropDownAppearance() {
        DropDown.startListeningToKeyboard()
        let appearance = DropDown.appearance()
        appearance.cellHeight = 50
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 8
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.4
        appearance.shadowRadius = 10
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        appearance.textFont = UIFont.systemFont(ofSize: UILabel().font.pointSize)
    }
    // constraints
    public static func setOrigin(for child: UIView, equalTo parent: UIView, withConstant constant: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.topAnchor.constraint(equalTo: parent.topAnchor, constant: constant).isActive = true
        child.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: constant).isActive = true
    }
    public static func setTrailingAndBottom(for child: UIView, equalTo parent: UIView, withConstant constant: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: constant).isActive = true
        child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: constant).isActive = true
    }
    public static func setLeadingAndTrailing(for child: UIView, equalTo parent: UIView, withConstant constant: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: constant).isActive = true
        child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -constant).isActive = true
    }
    public static func setTop(for child: UIView, equalTo parent: UIView, withConstant constant: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.topAnchor.constraint(equalTo: parent.topAnchor, constant: constant).isActive = true
    }
    public static func setBottom(for child: UIView, equalTo parent: UIView, withConstant constant: CGFloat = 0) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -constant).isActive = true
    }
    public static func setViewEdges(for child: UIView, equalTo parent: UIView, withConstant constant: CGFloat = 0, excludingBottom: Bool = false) {
        self.setOrigin(for: child, equalTo: parent, withConstant: constant)
        child.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -constant).isActive = true
        if !excludingBottom {
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -constant).isActive = true
        }
    }
    public static func setWidth(for child: UIView, equalTo parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
    }
    public static func setHeight(for child: UIView, equalTo parent: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        child.heightAnchor.constraint(equalTo: parent.heightAnchor).isActive = true
    }
    public static func setSize(for child: UIView, equalTo parent: UIView) {
        self.setWidth(for: child, equalTo: parent)
        self.setHeight(for: child, equalTo: parent)
    }
    public static func setLeadingOf(_ second: UIView, equalToTrailingOf first: UIView, withConstant constant: CGFloat = 0) {
        second.translatesAutoresizingMaskIntoConstraints = false
        second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: constant).isActive = true
    }
    public static func centerVerically(_ second: UIView, to first: UIView, withConstant constant: CGFloat = 0) {
        second.translatesAutoresizingMaskIntoConstraints = false
        second.centerYAnchor.constraint(equalTo: first.centerYAnchor, constant: constant).isActive = true
    }
    // device
    public static func isDeviceLandscape() -> Bool {
        return UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
    }
}
