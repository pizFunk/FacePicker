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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        ViewHelper.roundCornersOnView(contentView, withRadius: 10)
    }

    func setImage(_ image: UIImage) {
        productLabelImageView.image = image
        
//        productLabelImageView.translatesAutoresizingMaskIntoConstraints = false
//
//        imageViewHeightAnchor?.isActive = false
//        imageViewWidthAnchor?.isActive = false
//        if image.size.height >= image.size.width {
//            let ratio = image.size.width / image.size.height
//            imageViewHeightAnchor = productLabelImageView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.9)
//            imageViewHeightAnchor = productLabelImageView.widthAnchor.constraint(equalTo: productLabelImageView.heightAnchor, multiplier: ratio)
//        } else {
//            let ratio = image.size.height / image.size.width
//            imageViewHeightAnchor = productLabelImageView.widthAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.9)
//            imageViewHeightAnchor = productLabelImageView.heightAnchor.constraint(equalTo: productLabelImageView.widthAnchor, multiplier: ratio)
//        }
//        imageViewHeightAnchor?.isActive = true
//        imageViewWidthAnchor?.isActive = true
//
//        print("product label image size = \(image.size)")
//        print("imageView frame.size = \(productLabelImageView.frame.size)")
    }
}
