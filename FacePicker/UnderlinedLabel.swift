//
//  UnderlinedLabel.swift
//  FacePicker
//
//  Created by matthew on 9/24/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class UnderlinedLabel: UILabel {
    override var text: String? {
        didSet {
            guard let text = self.text else { return }
            self.attributedText = NSAttributedString(string: text, attributes: [.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
