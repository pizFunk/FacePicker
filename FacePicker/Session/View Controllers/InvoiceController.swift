//
//  InvoiceController.swift
//  FacePicker
//
//  Created by matthew on 10/11/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

protocol InvoiceControllerDelegate {
    func invoiceControllerDidCancel(invoice: Invoice)
    func invoiceControllerDidFinalize(invoice: Invoice)
}

class InvoiceController: UIViewController {
    static let nibName = "InvoiceController"
    
    @IBOutlet var initiallyHiddenViews: [UIView]!
    
    // main stack view:
    @IBOutlet weak var mainStackView: UIStackView!
    
    // view collections for hiding:
    @IBOutlet var neuroToxinViews: [UIView]!
    @IBOutlet var fillerViews: [UIView]!
    @IBOutlet var latisseViews: [UIView]!
    
    // individual views for button press hiding:
    @IBOutlet weak var neurotoxinDiscountView: UIView!
    @IBOutlet weak var neurotoxinPriceView: UIView!
    @IBOutlet weak var fillerDiscountView: UIView!
    @IBOutlet weak var fillerPriceView: UIView!
    @IBOutlet weak var latissePriceView: UIView!
    
    // price and count buttons:
    @IBOutlet weak var neurotoxinUnitsButton: UIButton!
    @IBOutlet weak var neurotoxinPriceButton: UIButton!
    @IBOutlet weak var fillerCountButton: UIButton!
    @IBOutlet weak var fillerPriceButton: UIButton!
    @IBOutlet weak var latisseCountButton: NiceButton!
    @IBOutlet weak var latissePriceButton: UIButton!
    
    // discount labels:
    @IBOutlet weak var neurotoxinDiscountLabel: UILabel!
    @IBOutlet weak var neurotoxinDiscountDescriptionLabel: UILabel!
    @IBOutlet weak var fillerDiscountLabel: UILabel!
    @IBOutlet weak var fillerDiscountDescriptionLabel: UILabel!
    
    // adjustment sliders:
    @IBOutlet weak var neurotoxinDiscountSlider: UISlider!
    @IBOutlet weak var neurotoxinPriceSlider: UISlider!
    @IBOutlet weak var fillerDiscountSlider: UISlider!
    @IBOutlet weak var fillerPriceSlider: UISlider!
    @IBOutlet weak var latissePriceSlider: UISlider!
    
    // total and payment type:
    @IBOutlet weak var discountAmountView: UIView!
    @IBOutlet weak var totalsAndPaymentStack: UIStackView!
    @IBOutlet weak var discountAmountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var paymentErrorView: UIView!
    @IBOutlet weak var paymentErrorLabel: UILabel!
    @IBOutlet weak var paymentLabelView: UIView!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var singlePaymentPlaceholderButton: NiceButton!
    @IBOutlet weak var addPaymentView: UIView!
    @IBOutlet weak var paymentsStack: UIStackView!
    
    // button collection for read-only
    @IBOutlet var allButtons: [UIButton]!
    
    // auto-hide price adjustment views after touch up event
    private var viewsForSliders:[UISlider:UIView] {
        return [neurotoxinPriceSlider: neurotoxinPriceView, fillerPriceSlider: fillerPriceView, latissePriceSlider: latissePriceView]
    }
    
    var readOnly = false
    var invoice: Invoice!
    var delegate: InvoiceControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiallyHiddenViews.forEach { view in
            view.isHidden = true
        }
        
        setupNavBar()
        setupNeurotoxin()
        setupFiller()
        setupLatisse()
        updateTotal()
        setupPayments()
        
        // opening a "finalized" invoice
        if readOnly {
            allButtons.forEach { button in
                button.isUserInteractionEnabled = false
            }
        } else {
            attachAutohideHandlersToPriceSliders()
        }
        latisseCountButton.color = readOnly ? latissePriceButton.tintColor : UIColor.black
        
        adjustHeightForContentChange(initialLoad: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        adjustHeightForContentChange()
    }
    
    private func adjustHeightForContentChange(initialLoad: Bool = false) {
        view.layoutIfNeeded()
        let newSize = CGSize(width: 450, height: mainStackView.frame.height)
        if initialLoad {
            preferredContentSize = newSize
        } else {
            navigationController?.preferredContentSize = newSize
        }
    }
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(InvoiceController.onCancel(sender:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finalize", style: .done, target: self, action: #selector(InvoiceController.onFinalize(sender:)))
    }
    
    private func updateNeurotoxinUnitsButtonTitle() {
        neurotoxinUnitsButton.setTitleWithoutAnimation(InvoiceHelper.formatCount(invoice.neurotoxinUnitsSold), for: .normal)
    }
    
    private func updateNeurotoxinPriceButtonTitle() {
        neurotoxinPriceButton.setTitleWithoutAnimation(InvoiceHelper.formatPrice(invoice.neurotoxinPricePerUnit), for: .normal)
    }
    
    private func updateNeurotoxinDiscountLabels() {
        let discount = invoice.neurotoxinUnitsDiscounted
        var description = discount == 1 ? "discounted unit" : "discounted units"
        description += readOnly ? "." : ":"
        neurotoxinDiscountDescriptionLabel.text = description
        neurotoxinDiscountLabel.text = InvoiceHelper.formatCount(discount)
    }
    
    private func setupNeurotoxin() {
        if invoice.neurotoxinUnitsTotal > 0 {
            updateNeurotoxinUnitsButtonTitle()
            updateNeurotoxinPriceButtonTitle()
            
            if readOnly {
                if invoice.neurotoxinUnitsDiscounted > 0 {
                    neurotoxinDiscountView.isHidden = false
                    neurotoxinDiscountSlider.isHidden = true
                    updateNeurotoxinDiscountLabels()
                }
            } else {
                neurotoxinDiscountSlider.minimumValue = 0
                neurotoxinDiscountSlider.maximumValue = invoice.neurotoxinUnitsTotal
                neurotoxinDiscountSlider.value = neurotoxinDiscountSlider.minimumValue
                
                // TODO: use Settings defaults?
                neurotoxinPriceSlider.minimumValue = 5
                neurotoxinPriceSlider.maximumValue = 10
                neurotoxinPriceSlider.value = 9 // TODO: get default value from Settings
            }
        } else {
            neuroToxinViews.forEach { view in
                view.isHidden = true
            }
        }
    }
    
    private func updateFillerCountButtonTitle() {
        fillerCountButton.setTitleWithoutAnimation(InvoiceHelper.formatCount(invoice.fillerCountSold), for: .normal)
    }
    
    private func updateFillerPriceButtonTitle() {
        fillerPriceButton.setTitleWithoutAnimation(InvoiceHelper.formatPrice(invoice.fillerPricePerUnit), for: .normal)
    }
    
    private func updateFillerDiscountCountLabels() {
        let discount = invoice.fillerCountDiscounted
        var description = discount == 1 ? "discounted syringe" : "discounted syringes"
        description += readOnly ? "." : ":"
        fillerDiscountDescriptionLabel.text = description
        fillerDiscountLabel.text = InvoiceHelper.formatCount(discount)
    }
    
    private func setupFiller() {
        if invoice.fillerCountTotal > 0 {
            updateFillerCountButtonTitle()
            updateFillerPriceButtonTitle()
            
            if readOnly {
                if invoice.fillerCountDiscounted > 0 {
                    fillerDiscountView.isHidden = false
                    fillerDiscountSlider.isHidden = true
                    updateFillerDiscountCountLabels()
                }
            } else {
                fillerDiscountSlider.minimumValue = 0
                fillerDiscountSlider.maximumValue = Float(invoice.fillerCountTotal)
                fillerDiscountSlider.value = fillerDiscountSlider.minimumValue
                
                // TODO: use Settings defaults?
                fillerPriceSlider.minimumValue = 300
                fillerPriceSlider.maximumValue = 450
                fillerPriceSlider.value = 325 // TODO: get default value from Settings
            }
        } else {
            fillerViews.forEach { view in
                view.isHidden = true
            }
        }
    }
    
    private func updateLatissePriceButtonTitle() {
        latissePriceButton.setTitleWithoutAnimation(InvoiceHelper.formatPrice(invoice.latissePricePerUnit), for: .normal)
    }
    
    private func setupLatisse() {
        if invoice.latisseCountTotal > 0 {
            updateLatissePriceButtonTitle()
            latisseCountButton.setTitle(InvoiceHelper.formatCount(invoice.latisseCountSold), for: .normal)
            
            if !readOnly {
                latissePriceSlider.minimumValue = 100
                latissePriceSlider.maximumValue = 150
                latissePriceSlider.value = 120 // TODO: get default value from Settings
            }
        } else {
            latisseViews.forEach { view in
                view.isHidden = true
            }
        }
    }
    
    private func updateTotal() {
        let total = invoice.neurotoxinTotal + invoice.fillerTotal + invoice.latisseTotal
        let discount = invoice.neurotoxinDiscount + invoice.fillerDiscount
        
        discountAmountLabel.text = InvoiceHelper.formatPrice(discount)
        ViewHelper.setViewVisibility(discountAmountView, isHidden: discount == 0)
        
        invoice.total = total
        totalLabel.text = InvoiceHelper.formatPrice(total)
    }
    
    private func setupPayments() {
        if readOnly {
            paymentLabelView.isHidden = false
            let paymentsArray = invoice.paymentsArray
            if paymentsArray.count == 1 {
                paymentLabel.text = "Payment:"
                singlePaymentPlaceholderButton.setTitle(paymentsArray[0].type, for: .normal)
                singlePaymentPlaceholderButton.isHidden = false
            } else {
                paymentLabel.text = "Payments:"
                for payment in invoice.paymentsArray {
                    let paymentView = PaymentView()
                    paymentView.readOnly = readOnly
                    paymentView.payment = payment
                    paymentsStack.addArrangedSubview(paymentView)
                }
                paymentsStack.isHidden = false
            }
        } else {
            addPaymentView.isHidden = false
        }
    }
    
    private func addPayment() {
        let newPayment = Payment.create()
        newPayment.amount = invoice.total - invoice.paymentsTotal
        invoice.addToPayments(newPayment)
        
        let newPaymentView = PaymentView()
        newPaymentView.payment = newPayment
        newPaymentView.delegate = self
        paymentsStack.addArrangedSubview(newPaymentView)
        if invoice.paymentsArray.count > 1 {
            newPaymentView.isHidden = true
            ViewHelper.setViewVisibility(newPaymentView, isHidden: false)
        }
        ViewHelper.setViewVisibility(paymentsStack, isHidden: false)
        ViewHelper.setViewVisibility(addPaymentView, isHidden: true) // hide it until the next slider is lowered
        ViewHelper.setViewVisibility(paymentErrorView, isHidden: true) // hide in case we've shown
    }
    
    private func clearPayments() {
        for payment in invoice.paymentsArray {
            CoreDataManager.shared.delete(payment)
        }
        for subview in paymentsStack.arrangedSubviews {
            paymentsStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    private func setAddPaymentButtonVisibilty() {
        ViewHelper.setViewVisibility(addPaymentView, isHidden: ((invoice.total - invoice.paymentsTotal) == 0))
    }
    
    private func attachAutohideHandlersToPriceSliders() {
        viewsForSliders.keys.forEach { slider in
            slider.addTarget(self, action: #selector(InvoiceController.selectViewForSlider(sender:)), for: .touchUpOutside)
            slider.addTarget(self, action: #selector(InvoiceController.selectViewForSlider(sender:)), for: .touchUpInside)
        }
    }
    
    @objc
    private func selectViewForSlider(sender: UISlider) {
        if let viewToToggle = viewsForSliders[sender] {
            ViewHelper.toggleViewVisibility(viewToToggle)
        }
    }
    
    @objc func onCancel(sender: UIBarButtonItem) {
        delegate?.invoiceControllerDidCancel(invoice: invoice)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onFinalize(sender: UIBarButtonItem) {
        if invoice.paymentsArray.count == 0 {
            paymentErrorLabel.text = "Please enter at least one payment."
            ViewHelper.setViewVisibility(paymentErrorView, isHidden: false)
            return
        }
        if invoice.paymentsTotal != invoice.total {
            paymentErrorLabel.text = "Payments do not add up to total."
            ViewHelper.setViewVisibility(paymentErrorView, isHidden: false)
            return
        }
        delegate?.invoiceControllerDidFinalize(invoice: invoice)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func neurotoxinUnitsButtonPressed(_ sender: Any) {
        ViewHelper.toggleViewVisibility(neurotoxinDiscountView)
    }
    
    @IBAction func neurotoxinPriceButtonPressed(_ sender: Any) {
        ViewHelper.toggleViewVisibility(neurotoxinPriceView)
    }
    
    @IBAction func neurotoxinDiscountSliderValueChanged(_ sender: UISlider) {
        let value = ViewHelper.snapSliderToWholeNumberOrMax(sender)
        invoice.neurotoxinUnitsDiscounted = value
        updateNeurotoxinDiscountLabels()
        updateNeurotoxinUnitsButtonTitle()
        updateTotal()
        clearPayments()
        sender.value = value
    }
    
    @IBAction func neurotoxinPriceSliderValueChanged(_ sender: UISlider) {
        let value = ViewHelper.snapSliderToIncrement(sender, increment: 0.5)
        invoice.neurotoxinPricePerUnit = value
        updateNeurotoxinPriceButtonTitle()
        updateTotal()
        sender.value = value
    }
    
    @IBAction func fillerCountButtonPressed(_ sender: Any) {
        ViewHelper.toggleViewVisibility(fillerDiscountView)
    }
    
    @IBAction func fillerPriceButtonPressed(_ sender: Any) {
        ViewHelper.toggleViewVisibility(fillerPriceView)
    }
    
    @IBAction func fillerDiscountSliderValueChanged(_ sender: UISlider) {
        let value = ViewHelper.snapSliderToWholeNumberOrMax(sender)
        invoice.fillerCountDiscounted = Int64(value)
        updateFillerDiscountCountLabels()
        updateFillerCountButtonTitle()
        updateTotal()
        clearPayments()
        sender.value = value
    }
    
    @IBAction func fillerPriceSliderValueChanged(_ sender: UISlider) {
        let value = ViewHelper.snapSliderToIncrement(sender, increment: 5)
        invoice.fillerPricePerUnit = Int64(value)
        updateFillerPriceButtonTitle()
        updateTotal()
        sender.value = value
    }
    
    @IBAction func latisseCountButtonPressed(_ sender: Any) {
        // do later if needed
    }
    
    @IBAction func latissePriceButtonPressed(_ sender: Any) {
        ViewHelper.toggleViewVisibility(latissePriceView)
    }
    
    @IBAction func latissePriceSliderValueChanged(_ sender: UISlider) {
        let value = ViewHelper.snapSliderToIncrement(sender, increment: 5)
        invoice.latissePricePerUnit = Int64(value)
        updateLatissePriceButtonTitle()
        updateTotal()
        sender.value = value
    }
    
    @IBAction func addPaymentButtonPressed(_ sender: Any) {
        addPayment()
    }
}

extension InvoiceController: PaymentViewDelegate {
    func paymentAmountChanged(for payment: Payment) {
        setAddPaymentButtonVisibilty()
    }
}
