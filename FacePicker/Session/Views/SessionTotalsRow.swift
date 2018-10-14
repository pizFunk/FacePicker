//
//  SessionTotalsRow.swift
//  FacePicker
//
//  Created by matthew on 9/24/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionTotalsRow: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    
    let nibName = "SessionTotalsRow"
    
    var fontSize: CGFloat {
        didSet {
            unitsLabel.font = unitsLabel.font.withSize(fontSize)
            descriptionLabel.font = descriptionLabel.font.withSize(fontSize)
            typeLabel.font = typeLabel.font.withSize(fontSize)
            buttonHeightConstraint.constant = fontSize + 4
        }
    }
    
    override init(frame: CGRect) {
        fontSize = UIFont.systemFontSize
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        ViewHelper.setViewEdges(for: contentView, equalTo: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
