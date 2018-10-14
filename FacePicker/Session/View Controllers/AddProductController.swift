//
//  AddProductController.swift
//  FacePicker
//
//  Created by matthew on 10/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import DropDown

protocol AddProductControllerDelegate {
    func productAdded(withType: ProductType, andAmount: Int)
}

class AddProductController: UIViewController {
    static let nibName = "AddProductController"
    
    @IBOutlet weak var productTypeDropDownButton: NiceButton!
    @IBOutlet weak var productAmountLabel: UILabel!
    @IBOutlet weak var productAmountSlider: UISlider!
    @IBOutlet weak var contentView: UIView!
    
    private var productTypeDropDown = DropDown()
    private var selectedAmount:Int = 1
    var delegate:AddProductControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupProductTypeDropDown()
        updateProductAmountLabel()
        setupProductAmountSlider()
        
        contentView.layoutIfNeeded()
        preferredContentSize = contentView.frame.size
    }
    
    @objc func onAddProduct(sender: Any) {
        guard let index = productTypeDropDown.indexForSelectedRow, let type = ProductType(rawValue: index) else {
            return
        }
        
        delegate?.productAdded(withType: type, andAmount: selectedAmount)
        dismiss(animated: true, completion: nil)
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddProductController.onAddProduct(sender:)))
    }
    
    private func onProductTypeDropDownValueChange(index: Int, item: String) {
        productTypeDropDownButton.setTitleWithoutAnimation(item, for: .normal)
    }
    
    private func setupProductTypeDropDown() {
        productTypeDropDown.anchorView = productTypeDropDownButton
        productTypeDropDown.dataSource = ProductType.toArray
        productTypeDropDown.selectionAction = onProductTypeDropDownValueChange
        // set default
        productTypeDropDown.selectRow(0)
        productTypeDropDownButton.setTitle(ProductType(rawValue: 0)?.description, for: .normal)
    }
    
    private func updateProductAmountLabel() {
        productAmountLabel.text = selectedAmount.description
    }
    
    private func setupProductAmountSlider() {
        productAmountSlider.minimumValue = 1
        productAmountSlider.maximumValue = 3
        productAmountSlider.value = productAmountSlider.minimumValue
    }
    
    @IBAction func productTypeDropDownButtonPressed(_ sender: Any) {
        productTypeDropDown.show()
    }
    
    @IBAction func productAmountSliderValueChanged(_ sender: UISlider) {
        let value = ViewHelper.snapSliderToWholeNumberOrMax(sender)
        sender.value = value
        
        selectedAmount = Int(value)
        updateProductAmountLabel()
    }
}
