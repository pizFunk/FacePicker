//
//  ProductLabelCell.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class ProductLabelCell: UICollectionViewCell {
    var imageViewHeightAnchor: NSLayoutConstraint?
    var imageViewWidthAnchor: NSLayoutConstraint?
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var productLabelImageView: UIImageView!
    
    var cornerRadius:CGFloat = 10 {
        didSet {
            ViewHelper.roundCornersOnView(contentView, withRadius: cornerRadius)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ViewHelper.roundCornersOnView(contentView, withRadius: cornerRadius)
    }
}
