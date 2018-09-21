//
//  SessionListCell.swift
//  FacePicker
//
//  Created by matthew on 9/21/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionListCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SessionListCell"
    
    var viewController: SessionListController? {
        didSet {
            setupViewController()
        }
    }    
}

private extension SessionListCell {
    func setupViewController() {
        guard let viewController = viewController else { fatalError() }
        
        contentView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        ViewHelper.setViewEdges(for: viewController.view, equalTo: contentView)
    }
}
