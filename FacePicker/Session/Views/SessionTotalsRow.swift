//
//  SessionTotalsRow.swift
//  FacePicker
//
//  Created by matthew on 9/24/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionTotalsRow: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var unitsLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    let nibName = "SessionTotalsRow"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        ViewHelper.setViewEdges(for: contentView, equalTo: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
