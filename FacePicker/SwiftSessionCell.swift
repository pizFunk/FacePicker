//
//  SessionCell.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SwiftSessionCell: UICollectionViewCell {
    var faceImageView: UIImageView = UIImageView()
    var sessionDateLabel: UILabel = UILabel()
    private var sizeAnchors = [NSLayoutConstraint]()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                ViewHelper.setBorderOnView(self.contentView, withColor: ViewHelper.defaultBorderColor, andWidth: 3)
            } else {
                setDefaultStyle()
            }
        }
    }
    var session:Session? {
        didSet {
            if let session = session {
                self.restorationIdentifier = session.id?.uuidString
                sessionDateLabel.text = session.formattedDate()
                faceImageView.image = session.sessionImage
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.heightAnchor.constraint(equalTo: contentView.widthAnchor)
//        contentView.autoresizesSubviews = true
        
        sessionDateLabel.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        contentView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0)
//        contentView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        contentView.clipsToBounds = true
        
//        contentView.addSubview(faceImageView)
//        faceImageView.translatesAutoresizingMaskIntoConstraints = false
//        faceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive = true
//        faceImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        faceImageView.heightAnchor.constraint(equalTo: faceImageView.widthAnchor, multiplier: 1.178)
//
//        faceImageView.heightAnchor.constraint(equalToConstant: contentView.heightAnchor, multiplier: 0.8)
//        faceImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6)
//        faceImageView.widthAnchor.constraint(equalTo: faceImageView.heightAnchor, multiplier: 0.849)
        
//        contentView.addSubview(sessionDateLabel)
//        sessionDateLabel.translatesAutoresizingMaskIntoConstraints = false
//        sessionDateLabel.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 8.0).isActive = true
//        sessionDateLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        sessionDateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        sessionDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0).isActive  = true
        
        contentView.addSubview(faceImageView)
        faceImageView.clipsToBounds = true
        faceImageView.translatesAutoresizingMaskIntoConstraints = false
        faceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0).isActive = true
        faceImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0).isActive = true
        faceImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0).isActive = true
        ViewHelper.setBorderOnView(faceImageView, withColor: UIColor.blue.cgColor)
        
        contentView.addSubview(sessionDateLabel)
        sessionDateLabel.translatesAutoresizingMaskIntoConstraints = false
        sessionDateLabel.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 8.0).isActive = true
        sessionDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0).isActive = true
        sessionDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0).isActive = true
        sessionDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0).isActive  = true
        ViewHelper.setBorderOnView(sessionDateLabel, withColor: UIColor.blue.cgColor)
        
        setDefaultStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDefaultStyle() {
        ViewHelper.setBorderOnView(self.contentView, withColor: ViewHelper.defaultBorderColor, andWidth: 1)
    }
}
