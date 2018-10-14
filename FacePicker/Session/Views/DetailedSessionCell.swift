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
    @IBOutlet weak var totalsStackView: UIStackView!
    
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
                setTotals()
                productLabelCollectionViewController.productLabels = session.labelsArray()
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
    
    private func setTotals() {
        guard let session = session else { return }
        
        for view in totalsStackView.arrangedSubviews {
            view.removeFromSuperview()
            totalsStackView.removeArrangedSubview(view)
        }
        
        if session.totalNeurotoxinUnits > 0 {
            let neurotoxinRow = SessionHelper.createTotalsRow(value: session.totalNeurotoxinUnits.description, type: InjectionType.Neurotoxin)
            neurotoxinRow.fontSize = 16
            totalsStackView.addArrangedSubview(neurotoxinRow)
        }
        if session.fillerCount > 0 {
            let fillerRow = SessionHelper.createTotalsRow(value: session.fillerCount.description, type: ProductType.Filler)
            fillerRow.fontSize = 16
            totalsStackView.addArrangedSubview(fillerRow)
        }
        if session.latisseCount > 0 {
            let latisseRow = SessionHelper.createTotalsRow(value: session.latisseCount.description, type: ProductType.Latisse)
            latisseRow.fontSize = 16
            totalsStackView.addArrangedSubview(latisseRow)
        }
        if totalsStackView.arrangedSubviews.count == 0 {
            let noneLabel = UILabel()
            noneLabel.text = "None"
            noneLabel.font = noneLabel.font.withSize(16)
            totalsStackView.addArrangedSubview(noneLabel)
        }
    }
}
