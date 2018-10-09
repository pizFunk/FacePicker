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

class SessionDetailController: UIViewController {
    @IBOutlet weak var sessionDescriptionView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveNotesButton: UIButton!
    @IBOutlet weak var totalsStackView: UIStackView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var productLabelCollectionContainerView: UIView!
    
    // editing of date:
    var datePicker = UIDatePicker()
    
    @IBOutlet weak var editButton: UIButton! // not installed
    
    lazy var productLabelCollectionViewController:ProductLabelCollectionViewController = {
        let viewController = ProductLabelCollectionViewController()
        addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        productLabelCollectionContainerView.addSubview(viewController.view)
        ViewHelper.setViewEdges(for: viewController.view, equalTo: productLabelCollectionContainerView)
        
        return viewController
    }()
    
    var session: Session? {
        didSet {
            loadViewIfNeeded()
            setDescriptionLabel()
            setNotes()
            setTotals()
            setLabelImages()
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
        setEditing(false, animated: false)
        setupDatePicker()
        
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
        let title = editing ? "Done" : "Edit"
        editButton.setTitle(title, for: .normal)
        
        productLabelCollectionViewController.isEditing = editing
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
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        isEditing = !isEditing
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
        datePicker.minimumDate = DateFormatter().date(from: "01/01/2018")
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
        
        if let injections = session.injections {
            var totalsByType = [InjectionType: Float]()
            
            for injection in injections {
                var total = totalsByType[injection.type] ?? 0
                switch injection.type {
                case .NeuroToxin:
                    // sum units
                    total += injection.units
                case .Filler:
                    // count number of sites
                    total += 1
                default:
                    break
                }
                totalsByType[injection.type] = total
            }
            if totalsByType.count > 0 {
                for (key, value) in totalsByType {
                    var valueString = ""
                    var description = ""
                    switch key {
                    case .NeuroToxin:
                        valueString = value.description
                        description = "units of"
                    case .Filler:
                        valueString = String(format: "%.0f", value)
                        description = "locations of"
                    default:
                        break
                    }
                    let totalRowView = SessionTotalsRow()
                    totalRowView.unitsLabel.text = valueString
                    SessionHelper.setColor(forLabel: totalRowView.unitsLabel, withType: key)
                    totalRowView.descriptionLabel.text = description
                    totalRowView.typeLabel.text = "\(key.description)"
                    SessionHelper.setColor(forLabel: totalRowView.typeLabel, withType: key)
                    
                    totalsStackView.addArrangedSubview(totalRowView)
                }
            }
        }
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
        let context = managedContext()
        guard let entity = NSEntityDescription.entity(forEntityName: ProductLabel.entityName, in: context) else {
            Application.onError("Couldn't get entity description for name: \(ProductLabel.entityName)!")
            return		
        }
        let newLabel = ProductLabel(entity: entity, insertInto: context)
        newLabel.image = imageData
        session.addToLabels(newLabel)
        productLabelCollectionViewController.productLabels.append(newLabel)
        NotificationCenter.default.post(name: .sessionDidChange, object: self, userInfo: ["": session])
        
        Application.logInfo("Added ProductLabel for Session with id: \(session.id.uuidString)")
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
