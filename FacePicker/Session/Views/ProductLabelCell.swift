//
//  ProductLabelCell.swift
//  FacePicker
//
//  Created by matthew on 9/25/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

protocol ProductLabelCellDelegate {
    func productLabelCellDeleted(_ cell: ProductLabelCell)
}

class ProductLabelCell: DeletableCollectionViewCell {
    var imageViewHeightAnchor: NSLayoutConstraint?
    var imageViewWidthAnchor: NSLayoutConstraint?
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var productLabelImageView: UIImageView!
    
    var delegate:ProductLabelCellDelegate?
    
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
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.productLabelCellDeleted(self)
    }
}
