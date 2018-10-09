//
//  DeletableCollectionViewCell.swift
//  FacePicker
//
//  Created by matthew on 10/8/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class DeletableCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var deleteButtonBackgroundView: UIView!
    
    var isEditing:Bool = false {
        didSet {
            // show/hide delete button
            deleteButtonBackgroundView.isHidden = !isEditing
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupDeleteButton()
    }
    
    private func setupDeleteButton() {
        deleteButtonBackgroundView.isHidden = !isEditing
        let radius = deleteButtonBackgroundView.bounds.width / 2
        ViewHelper.roundCornersOnView(deleteButtonBackgroundView, withRadius: radius)
//        ViewHelper.setBorderOnView(deleteButtonBackgroundView, withColor: UIColor.red.cgColor, rounded: false)
    }
}
