//
//  SessionCell.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionCell: UICollectionViewCell {
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    fileprivate let borderColor = UIColor(white: 0.8, alpha: 1).cgColor //ViewHelper.defaultBorderColor
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                ViewHelper.setBorderOnView(self.contentView, withColor: borderColor, andWidth: 3, rounded: false)
            } else {
                setDefaultStyle()
            }
        }
    }
    var session:Session? {
        didSet {
            if let session = session {
                //self.restorationIdentifier = session.id?.uuidString
                dateLabel.text = session.formattedDate()
                faceImageView.image = session.sessionImage
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultStyle()
    }
    
    private func setDefaultStyle() {
        ViewHelper.setBorderOnView(self.contentView, withColor: borderColor, rounded: false)
    }
}
