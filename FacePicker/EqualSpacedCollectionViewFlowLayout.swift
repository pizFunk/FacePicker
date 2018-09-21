//
//  EqualSpacedCollectionViewFlowLayout.swift
//  FacePicker
//
//  Created by matthew on 9/15/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation
import UIKit

@objc(EqualSpacedCollectionViewFlowLayout)
class EqualSpacedCollectionViewFlowLayout : UICollectionViewFlowLayout
{
    @IBInspectable var placeEqualSpaceAroundAllCells: Bool = false
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare()
    {
        super.prepare()
        
        if (self.placeEqualSpaceAroundAllCells) {
            var contentByItems: ldiv_t
            
            let contentSize: CGSize = self.collectionViewContentSize
            
//            guard let itemSize = collectionView?.visibleCells.first?.contentView.frame.size, itemSize.width > 1 else {
//                return
//            }
            let itemSize = self.itemSize
            if scrollDirection == UICollectionViewScrollDirection.vertical {
                contentByItems = ldiv(Int(contentSize.width), Int(itemSize.width))
            } else {
                contentByItems = ldiv(Int(contentSize.height), Int(itemSize.height))
            }
            let layoutSapcingValue: CGFloat = CGFloat(NSInteger(CGFloat(contentByItems.rem) / CGFloat(contentByItems.quot + 1)))
            let originalMinimumLineSpacing = minimumLineSpacing
            let originalMinimumInteritemSpacing = minimumInteritemSpacing
            let originalSectionInset = sectionInset
            if layoutSapcingValue != originalMinimumLineSpacing ||
                layoutSapcingValue != originalMinimumInteritemSpacing ||
                layoutSapcingValue != originalSectionInset.left ||
                layoutSapcingValue != originalSectionInset.right ||
                layoutSapcingValue != originalSectionInset.top ||
                layoutSapcingValue != originalSectionInset.bottom {
                let insetsForItem = UIEdgeInsets(top: layoutSapcingValue, left: layoutSapcingValue, bottom: layoutSapcingValue, right: layoutSapcingValue)
                minimumLineSpacing = layoutSapcingValue
                minimumInteritemSpacing = layoutSapcingValue
                sectionInset = insetsForItem
            }
        }
    }
}
