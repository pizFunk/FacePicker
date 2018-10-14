//
//  UIButton.swift
//  FacePicker
//
//  Created by matthew on 10/11/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

extension UIButton {
    func setTitleWithoutAnimation(_ title: String?, for state: UIControlState) {
        UIView.performWithoutAnimation {
            setTitle(title, for: state)
            layoutIfNeeded()
        }
    }
}
