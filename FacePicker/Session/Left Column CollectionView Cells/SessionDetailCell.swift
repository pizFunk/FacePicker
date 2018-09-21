//
//  SessionDetailCell.swift
//  FacePicker
//
//  Created by matthew on 9/21/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionDetailCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SessionDetailCell"
    
    var viewController: SessionDetailController? {
        didSet {
            setupViewController()
        }
    }
}

private extension SessionDetailCell {
    func setupViewController() {
        guard let viewController = viewController else { fatalError() }

        contentView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        ViewHelper.setViewEdges(for: viewController.view, equalTo: contentView)
    }
}
