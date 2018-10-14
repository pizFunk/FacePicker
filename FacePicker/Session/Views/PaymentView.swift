//
//  Payment.swift
//  FacePicker
//
//  Created by matthew on 10/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import DropDown

protocol PaymentViewDelegate {
    func paymentAmountChanged(for payment: Payment)
}

class PaymentView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var paymentAmountSlider: UISlider!
    @IBOutlet weak var paymentAmountLabel: UILabel!
    @IBOutlet weak var paymentTypeDropDownButton: NiceButton!
    private var paymentTypeDropDown = DropDown()
    let nibName = "PaymentView"
    
    var readOnly = false {
        didSet {
            paymentAmountSlider.isHidden = readOnly
            paymentTypeDropDownButton.isUserInteractionEnabled = !readOnly
        }
    }
    var payment:Payment! {
        didSet {
            updatePaymentAmountLabel()
            setupPaymentAmoundSlider()
            setupPaymentTypeDropDown()
        }
    }
    var delegate:PaymentViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        ViewHelper.setViewEdges(for: contentView, equalTo: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func updatePaymentAmountLabel() {
        paymentAmountLabel.text = InvoiceHelper.formatPrice(payment.amount)
    }
    
    private func setupPaymentAmoundSlider() {
        paymentAmountSlider.minimumValue = 0
        paymentAmountSlider.maximumValue = payment.amount
        paymentAmountSlider.value = payment.amount
    }
    
    private func onPaymentTypeDropDownValueChange(index: Int, item: String) {
        paymentTypeDropDownButton.setTitleWithoutAnimation(item, for: .normal)
        payment.type = item
    }
    
    private func setupPaymentTypeDropDown() {
        paymentTypeDropDown.anchorView = paymentTypeDropDownButton
        paymentTypeDropDown.dataSource = PaymentType.toArray
        paymentTypeDropDown.selectionAction = onPaymentTypeDropDownValueChange
        // set default
        var defaultPaymentTypeOrExisting:PaymentType?
        if let paymentType = payment.type {
            defaultPaymentTypeOrExisting = PaymentType.fromString(paymentType)
        } else {
            defaultPaymentTypeOrExisting = PaymentType(rawValue: 0)
        }
        guard let unwrappedPaymentType = defaultPaymentTypeOrExisting else {
            return
        }
        payment.type = unwrappedPaymentType.description
        paymentTypeDropDown.selectRow(unwrappedPaymentType.rawValue)
        paymentTypeDropDownButton.setTitle(unwrappedPaymentType.description, for: .normal)
    }
    
    @IBAction func paymentTypeDropDownButtonPressed(_ sender: Any) {
        paymentTypeDropDown.show()
    }
    
    @IBAction func paymentAmountSliderValueChanged(_ sender: UISlider) {
        if sender.value > (sender.maximumValue / 5) * 5 {
            print("over last increment!")
        }
        let newValue = ViewHelper.snapSliderToIncrement(sender, increment: 5)
//        let newValue = sender.value
        sender.value = newValue
        payment.amount = newValue
        updatePaymentAmountLabel()
        
        // notify invoice controller that amount changed
        delegate?.paymentAmountChanged(for: payment)
    }
}
