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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveNotesButton: UIButton!
    @IBOutlet weak var totalsStackView: UIStackView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var productLabelCollectionContainerView: UIView!
    
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

        // Do any additional setup after loading the view.
        
        // set the height of the stackview to the view ??
        //ViewHelper.setViewEdges(for: totalsViewController.view, equalTo: view, withConstant: 0, excludingBottom: true)
        
//        view.addSubview(stackView)
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        ViewHelper.setBottom(for: view, equalTo: stackView)
//        ViewHelper.setTop(for: stackView, equalTo: view)
//        ViewHelper.setLeadingAndTrailing(for: stackView, equalTo: view, withConstant: 15)
//        stackView.axis = .vertical
//        stackView.spacing = 8.0
        
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
    
    @objc
    func onSessionDidChange(notification: Notification) {
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
}

private extension SessionDetailController {
    private func setDescriptionLabel() {
        nameLabel.text = ""
        dateLabel.text = ""
        if let session = session {
            let client = session.client
            nameLabel.text = client.formattedName()
            dateLabel.text = session.formattedDate()
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
            var totalsByType = [String: Float]()
//            var lastRowView: UIView?
            
            for injection in injections {
                if var sum = totalsByType[injection.type.description] {
                    sum += injection.units
                    totalsByType[injection.type.description] = sum
                } else {
                    totalsByType[injection.type.description] = injection.units
                }
            }
            if totalsByType.count > 0 {
                for (key, value) in totalsByType {
                    let totalRowView = SessionTotalsRow()
                    totalRowView.unitsLabel.text = "\(value)"
                    SessionHelper.setColor(forLabel: totalRowView.unitsLabel, withStringType: key)
                    totalRowView.typeLabel.text = "\(key)"
                    SessionHelper.setColor(forLabel: totalRowView.typeLabel, withStringType: key)
                    
                    totalsStackView.addArrangedSubview(totalRowView)
                    
//                    lastRowView = totalRowView
                }
            }
//            if lastRowView != nil {
//                totalsStackBottomAnchor?.isActive = false
//                totalsStackBottomAnchor = totalsStackView.bottomAnchor.constraint(equalTo: lastRowView!.bottomAnchor)
//                totalsStackBottomAnchor?.isActive = true
//            } else {
//                totalsStackBottomAnchor?.isActive = false
//            }
        }
    }
    private func setLabelImages() {
        let images = session?.labelsImageArray() ?? [UIImage]()
        productLabelCollectionViewController.images = images
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
            NotificationCenter.default.post(name: .sessionDidChange, object: nil, userInfo: ["": session])
            
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
        productLabelCollectionViewController.images.append(image)
        NotificationCenter.default.post(name: .sessionDidChange, object: nil, userInfo: ["": session])
        
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
