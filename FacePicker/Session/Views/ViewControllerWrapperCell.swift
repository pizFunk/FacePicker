//
//  SessionListCell.swift
//  FacePicker
//
//  Created by matthew on 9/21/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class ViewControllerWrapperCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ViewControllerWrapperCell"
    
    var viewController: UIViewController? {
        didSet {
            setupViewController()
        }
    }    
}

private extension ViewControllerWrapperCell {
    func setupViewController() {
        guard let viewController = viewController else {
            Application.onError("Tried to set up a nil ViewController!")
            return
        }
        
        contentView.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        ViewHelper.setViewEdges(for: viewController.view, equalTo: contentView)
    }
}
