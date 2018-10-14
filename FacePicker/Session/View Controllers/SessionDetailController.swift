//
//  SessionDetailController.swift
//  FacePicker
//
//  Created by matthew on 9/21/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import CoreData
import CropViewController
import ContextMenu

class SessionDetailController: UIViewController {
    @IBOutlet weak var sessionDescriptionView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveNotesButton: UIButton!
    @IBOutlet weak var totalsStackView: UIStackView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var productLabelCollectionContainerView: UIView!
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var totalsButtonsSeparator: UILabel!
    @IBOutlet weak var invoiceButton: UIButton!
    
    // editing:
    private var datePicker = UIDatePicker()
    private var fillerProductRow: SessionTotalsRow?
    private var latisseProductRow: SessionTotalsRow?
    
    lazy var productLabelCollectionViewController:ProductLabelCollectionViewController = {
        let viewController = ProductLabelCollectionViewController()
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        productLabelCollectionContainerView.addSubview(viewController.view)
        ViewHelper.setViewEdges(for: viewController.view, equalTo: productLabelCollectionContainerView)
        
        return viewController
    }()
    
    private var invoiceController:InvoiceController?
    
    private var _totalNeurotoxinUnits:Float = 0 // so we don't have to keep calling the computed property
    var session: Session? {
        didSet {
            loadViewIfNeeded()
            _totalNeurotoxinUnits = session?.totalNeurotoxinUnits ?? 0
            setDescriptionLabel()
            setNotes()
            setTotals()
            setLabelImages()
            setProductAndInvoiceButtons()
            cameraButton.isHidden = !(session?.isEditable ?? true)
        }
    }
    
    //constraints
    var totalsStackBottomAnchor: NSLayoutConstraint?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SessionDetailController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // edit mode
        setupDatePicker()
        ViewHelper.setTextFieldEnabled(dateTextField, isEnabled: false) // initially set "disabled"
        if let session = session {
            if session.isEditable {
            }
        }
        
        // description
        ViewHelper.setBorderOnView(sessionDescriptionView, withColor: UIColor(white: 0.6, alpha: 1).cgColor, rounded: false)
        sessionDescriptionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        // notes
        notesTextView.delegate = self
        ViewHelper.setBorderOnView(notesTextView, withColor: ViewHelper.defaultBorderColor)
        
        // labels
        ViewHelper.setBorderOnView(productLabelCollectionContainerView, withColor: UIColor(white: 0.6, alpha: 1).cgColor)
        productLabelCollectionContainerView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SessionDetailController.onSessionDidChange(notification:)), name: .sessionDidChange, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        ViewHelper.setTextFieldEnabled(dateTextField, isEnabled: editing)
        addProductButton.isEnabled = !editing
        invoiceButton.isEnabled = !editing
        cameraButton.isEnabled = !editing
        productLabelCollectionViewController.isEditing = editing
        if let fillerRow = fillerProductRow {
            fillerRow.deleteButton.isHidden = !editing
        }
        if let latisseRow = latisseProductRow {
            latisseRow.deleteButton.isHidden = !editing
        }
    }
    
    @objc
    func onSessionDidChange(notification: Notification) {
        if notification.object is SessionDetailController {
            // ignore notifications we sent...
            return
        }
        guard let userInfo = notification.userInfo as? [String : Session], let sessionData = userInfo.first else {
            return
        }
        self.session = sessionData.value
    }
    
    @IBAction func saveNotesButtonPressed(_ sender: UIButton) {
        saveNotes()
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.modalTransitionStyle = .crossDissolve
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func addProductButtonPressed(_ sender: UIButton) {
        let addProductController = AddProductController(nibName: AddProductController.nibName, bundle: nil)
        addProductController.delegate = self
        let popoverNavController = createPopoverNavigationController(withTarget: self, withRootViewController: addProductController, anchoredTo: addProductButton)
        
        present(popoverNavController, animated: true, completion: nil)
    }
    
    @IBAction func invoiceButtonPressed(_ sender: Any) {
        guard let session = session else { return }
        // show invoice context menu
        invoiceController = InvoiceController(nibName: InvoiceController.nibName, bundle: nil)
        invoiceController?.delegate = self
        if let invoice = session.invoice {
            invoiceController?.readOnly = true
            invoiceController?.invoice = invoice
            makeViewControllerPopover(invoiceController!, anchoredTo: invoiceButton) // if target isn't nil we will delete session on dismiss!
            present(invoiceController!, animated: true, completion: nil)
        } else {
            let invoice = Invoice.createForSession(session)
            invoice.setDefaults()
            invoiceController?.invoice = invoice
            let popoverNavController = createPopoverNavigationController(withTarget: self, withRootViewController: invoiceController!, anchoredTo: invoiceButton)
            present(popoverNavController, animated: true, completion: nil)
        }
    }
    
    @objc
    func datePickerValueChanged(sender: UIDatePicker) {
        guard let session = session else { return }
        dateTextField.text = Session.formatDate(sender.date)
        session.date = sender.date as NSDate
        
        NotificationCenter.default.post(name: .sessionDidChange, object: self, userInfo: ["": session])
    }
}

private extension SessionDetailController {
    private func setupDatePicker() {
        guard let session = session else {
            // TODO: log error
            return
        }
        datePicker.date = session.date as Date
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.year = 2018
        datePicker.minimumDate = Calendar.current.date(from: dateComponents)
        datePicker.addTarget(self, action: #selector(SessionDetailController.datePickerValueChanged(sender:)), for: .valueChanged)
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = createDoneToolbarForDatePicker()
    }
    
    private func setDescriptionLabel() {
        nameLabel.text = ""
        dateTextField.text = ""
        if let session = session {
            let client = session.client
            nameLabel.text = client.formattedName()
            dateTextField.text = session.formattedDate()
        }
    }
    
    private func setNotes() {
        if let session = session, let notes = session.notes {
            notesTextView.text = notes
        } else {
            notesTextView.text = ""
        }
    }
    
    private func setTotals() {
        guard let session = session else {
            return
        }
        
        for view in totalsStackView.arrangedSubviews {
            view.removeFromSuperview()
            totalsStackView.removeArrangedSubview(view)
        }
        
        if _totalNeurotoxinUnits > 0 {
            totalsStackView.addArrangedSubview(SessionHelper.createTotalsRow(value: _totalNeurotoxinUnits.description, type: InjectionType.Neurotoxin))
        }
        if session.fillerCount > 0 {
            let fillerRow = SessionHelper.createTotalsRow(value: session.fillerCount.description, type: ProductType.Filler)
            fillerRow.deleteButton.addTarget(self, action: #selector(SessionDetailController.deleteFiller(sender:)), for: .touchUpInside)
            fillerRow.deleteButton.isHidden = !isEditing
            totalsStackView.addArrangedSubview(fillerRow)
            fillerProductRow = fillerRow
        }
        if session.latisseCount > 0 {
            let latisseRow = SessionHelper.createTotalsRow(value: session.latisseCount.description, type: ProductType.Latisse)
            latisseRow.deleteButton.addTarget(self, action: #selector(SessionDetailController.deleteLatisse(sender:)), for: .touchUpInside)
            latisseRow.deleteButton.isHidden = !isEditing
            totalsStackView.addArrangedSubview(latisseRow)
            latisseProductRow = latisseRow
        }
    }
    
    @objc
    func deleteFiller(sender: Any) {
        session?.fillerCount = 0
        setTotals()
    }
    
    @objc
    func deleteLatisse(sender: Any) {
        session?.latisseCount = 0
        setTotals()
    }
    
    private func setLabelImages() {
        let labels = session?.labelsArray() ?? [ProductLabel]()
        productLabelCollectionViewController.productLabels = labels
    }
    
    private func isNotesDifferentThanSaved() -> Bool {
        let sessionNotes = session?.notes ?? ""
        return notesTextView.text != sessionNotes
    }
    
    private func saveNotes() {
        guard let session = session else {
            Application.onError("Trying to save notes to a nil Session!")
            return
        }
        if isNotesDifferentThanSaved() {
            session.notes = notesTextView.text
            NotificationCenter.default.post(name: .sessionDidChange, object: self, userInfo: ["": session])
            
            Application.logInfo("Notes saved for Session with id: \(session.id.uuidString) of Client \(session.client.id.uuidString)")
        }
        saveNotesButton.isHidden = true
        notesTextView.resignFirstResponder()
    }
    
    private func addNewLabel(_ image: UIImage) {
        guard let session = session else {
            Application.onError("Attempting to add new ProductLabel to nonexistent Session!")
            return
        }
        guard let imageData = UIImagePNGRepresentation(image) as NSData? else {
            Application.onError("Couldnt get image as NSData from UIImagePNGRepresentation!")
            return
        }
        let newLabel = ProductLabel.create()
        newLabel.image = imageData
        newLabel.sequence = session.nextLabelSequence
        session.addToLabels(newLabel)
        productLabelCollectionViewController.productLabels.append(newLabel)
        NotificationCenter.default.post(name: .sessionDidChange, object: self, userInfo: ["": session])
        
        Application.logInfo("Added ProductLabel for Session with id: \(session.id.uuidString)")
    }
    
    private func onInvoiceCancel(invoice: Invoice) {
        print("cancelling invoice and deleting")
        CoreDataManager.shared.delete(invoice)
    }
    
    private func onInvoiceFinalized(invoice: Invoice) {
        session?.invoice = invoice
        setProductAndInvoiceButtons()
    }
    
    private func setProductAndInvoiceButtons() {
        guard let session = session else { return }
        addProductButton.isHidden = false
        totalsButtonsSeparator.isHidden = false
        invoiceButton.isHidden = false
        if let _ = session.invoice {
            // we have a "finalized" invoice
            addProductButton.isHidden = true
            totalsButtonsSeparator.isHidden = true
            invoiceButton.setTitleWithoutAnimation("View Invoice", for: .normal)
        } else if session.isEditable {
            // we can edit this session
            if _totalNeurotoxinUnits == 0 && session.fillerCount == 0 && session.latisseCount == 0 {
                // we don't have any products yet, only show add product button
                totalsButtonsSeparator.isHidden = true
                invoiceButton.isHidden = true
            } else {
                // we have products, so show create button
                invoiceButton.setTitleWithoutAnimation("Create Invoice", for: .normal)
            }
        } else {
            // hide everything
            addProductButton.isHidden = true
            totalsButtonsSeparator.isHidden = true
            invoiceButton.isHidden = true
        }
    }
}

extension SessionDetailController: UITextViewDelegate {
//    func textViewDidEndEditing(_ textView: UITextView) {
//        saveNotes()
//    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveNotesButton.isHidden = !isNotesDifferentThanSaved()
    }
}

extension SessionDetailController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: CropViewCroppingStyle.default, image: image)
        cropController.delegate = self
        
        // Uncomment this if you wish to provide extra instructions via a title label
        //cropController.title = "Crop Image"
        
        // -- Uncomment these if you want to test out restoring to a previous crop setting --
        //cropController.angle = 90 // The initial angle in which the image will be rotated
        //cropController.imageCropFrame = CGRect(x: 0, y: 0, width: 2848, height: 4288) //The initial frame that the crop controller will have visible.
        
        // -- Uncomment the following lines of code to test out the aspect ratio features --
        //cropController.aspectRatioPreset = .presetSquare; //Set the initial aspect ratio as a square
        //cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
        //cropController.resetAspectRatioEnabled = false // When tapping 'reset', the aspect ratio will NOT be reset back to default
        //cropController.aspectRatioPickerButtonHidden = true
        
        picker.pushViewController(cropController, animated: true)
    }
}

extension SessionDetailController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        addNewLabel(image)
        
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        print("cropviewcontroller cancelled")
        cropViewController.presentingViewController?.dismiss(animated: false, completion: nil)
    }
}

extension SessionDetailController: InvoiceControllerDelegate {
    func invoiceControllerDidCancel(invoice: Invoice) {
        onInvoiceCancel(invoice: invoice)
    }
    
    func invoiceControllerDidFinalize(invoice: Invoice) {
        onInvoiceFinalized(invoice: invoice)
    }
}

extension SessionDetailController: AddProductControllerDelegate {
    func productAdded(withType type: ProductType, andAmount amount: Int) {
        guard let session = session else { return }
        switch type {
        case .Filler:
            session.fillerCount += Int64(amount)
        case .Latisse:
            session.latisseCount += Int64(amount)
        }
        setTotals()
        setProductAndInvoiceButtons()
    }
}

extension SessionDetailController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let popoverNavController = popoverPresentationController.presentedViewController as? UINavigationController,
            let viewController = popoverNavController.topViewController else {
            return
        }
        if let invoiceController = viewController as? InvoiceController {
            onInvoiceCancel(invoice: invoiceController.invoice)
        }
        else if viewController is AddProductController {
            // do nothing
        }
    }
}
