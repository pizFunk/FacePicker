//
//  DetailedSessionCell.swift
//  FacePicker
//
//  Created by matthew on 9/28/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class DetailedSessionCell: SimpleSessionCell {
    
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var productLabelCollectionContainerView: UIView!
    
    lazy var productLabelCollectionViewController:ProductLabelCollectionViewController = {
        let viewController = ProductLabelCollectionViewController()
        viewController.columns = 2
        viewController.cornerRadius = 5.0
//        addChildViewController(viewController)
//        viewController.didMove(toParentViewController: self)
        productLabelCollectionContainerView.addSubview(viewController.view)
        ViewHelper.setViewEdges(for: viewController.view, equalTo: productLabelCollectionContainerView)
        
        return viewController
    }()
    
    override var session:Session? {
        didSet {
            if let session = session {
                notesTextView.text = session.notes
                productLabelCollectionViewController.images = session.labelsImageArray()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // notes
        ViewHelper.setBorderOnView(notesTextView, withColor: ViewHelper.defaultBorderColor)
        
        // labels
        ViewHelper.setBorderOnView(productLabelCollectionContainerView, withColor: UIColor(white: 0.6, alpha: 1).cgColor)
        productLabelCollectionContainerView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
}
