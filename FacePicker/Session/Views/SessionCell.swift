//
//  SessionCell.swift
//  FacePicker
//
//  Created by matthew on 9/28/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionCell: UICollectionViewCell {
    
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var productLabelCollectionContainerView: UIView!
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet var noDetailConstraints: [NSLayoutConstraint]!
    @IBOutlet var detailConstraints: [NSLayoutConstraint]!
    
    
    lazy var productLabelCollectionViewController:ProductLabelCollectionViewController = {
        let viewController = ProductLabelCollectionViewController()
        viewController.columns = 2
        //        addChildViewController(viewController)
        //        viewController.didMove(toParentViewController: self)
        productLabelCollectionContainerView.addSubview(viewController.view)
        ViewHelper.setViewEdges(for: viewController.view, equalTo: productLabelCollectionContainerView)
        
        return viewController
    }()
    
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
    
    var showDetail:Bool = false {
        didSet {
            setConstraints(showDetail: showDetail)
        }
    }
    
    var storedConstraints = [NSLayoutConstraint]()
    private func setConstraints(showDetail: Bool) {
        detailsView.isHidden = !showDetail
        if showDetail {
//            contentView.addSubview(detailsView)
//            print("\(storedConstraints.count)")
//            detailsView.addConstraints(storedConstraints)
//            NSLayoutConstraint.activate(storedConstraints)
            NSLayoutConstraint.deactivate(noDetailConstraints)
            NSLayoutConstraint.activate(detailConstraints)
            setDetails()
        } else {
//            storedConstraints = detailsView.constraints
//            detailsView.removeFromSuperview()
            NSLayoutConstraint.deactivate(detailConstraints)
            NSLayoutConstraint.activate(noDetailConstraints)
        }
        
        layoutIfNeeded()
//        layoutSubviews()
    }
    private func setDetails() {
        guard let session = session else { return }
        notesTextView.text = session.notes
        
        let labels = session.labelsArray()
        productLabelCollectionViewController.productLabels = labels
    }
    
    private func createDetailsView() -> UIView {
        let view = UIView()
        
        let dateLabel = UILabel()
        dateLabel.text = "Date:"
        view.addSubview(dateLabel)
        
        return view
    }
    
    var session:Session? {
        didSet {
            if let session = session {
                //self.restorationIdentifier = session.id?.uuidString
                dateLabel.text = session.formattedDate()
                faceImageView.image = session.sessionImage
                if showDetail {
                    setDetails()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setDefaultStyle()
        
        setConstraints(showDetail: showDetail)
    }
    
    private func setDefaultStyle() {
        
        ViewHelper.setBorderOnView(self.contentView, withColor: borderColor, rounded: false)
        
        // notes
        ViewHelper.setBorderOnView(notesTextView, withColor: ViewHelper.defaultBorderColor)
        
        // labels
        ViewHelper.setBorderOnView(productLabelCollectionContainerView, withColor: UIColor(white: 0.6, alpha: 1).cgColor)
        productLabelCollectionContainerView.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
}
