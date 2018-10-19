//
//  FacePicker.swift
//  FacePicker
//
//  Created by matthew on 9/5/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import ContextMenu

@IBDesignable
class SessionController: UIViewController {
    
    //MARK: - Properties
    
    var faceImageView: UIImageView = UIImageView()
    var previousSwitch: UISwitch!
    private var siteButtons = [String:UIButton]()
    private var sites = [String:InjectionSite]()
    private var layoutConstraints = [NSLayoutConstraint]()
    var delegate: SessionControllerDelegate?
    
    var session: Session? {
        didSet {
            sessionSet()
        }
    }
}

extension SessionController {
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        let faceImage = UIImage(named: "face", in: bundle, compatibleWith: self.traitCollection)
        let faceImageView = UIImageView(image: faceImage)
        view.addSubview(faceImageView)
        
        faceImageView.translatesAutoresizingMaskIntoConstraints = false
        faceImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        faceImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        faceImageView.isHidden = true
        self.faceImageView = faceImageView
        
        SiteMenuController.usePreviousValues = true
        
        if let session = session, session.isEditable {
            setupTouchHandler()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
    override func viewWillLayoutSubviews() {
//        print("SessionController.viewWillLayoutSubviews")
        super.viewWillLayoutSubviews()
        
        navigationController?.isNavigationBarHidden = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        
        if faceImageView.isDescendant(of: view) {
            let safeAreaLayoutFrame = view.safeAreaLayoutGuide.layoutFrame
            
            NSLayoutConstraint.deactivate(layoutConstraints)
            layoutConstraints.removeAll()
            if safeAreaLayoutFrame.width * 1.178 > safeAreaLayoutFrame.height {
//                print("SessionController.viewWillLayoutSubviews limiting height of face")
                layoutConstraints.append(faceImageView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.95))
                layoutConstraints.append(faceImageView.widthAnchor.constraint(equalTo: faceImageView.heightAnchor, multiplier: 0.849))
            } else {
//                print("SessionController.viewWillLayoutSubviews limiting width of face")
                layoutConstraints.append(faceImageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95))
                layoutConstraints.append(faceImageView.heightAnchor.constraint(equalTo: faceImageView.widthAnchor, multiplier: 1.178))
            }
            NSLayoutConstraint.activate(layoutConstraints)
        }
    }
    
    override func viewDidLayoutSubviews() {
//        print("SessionController.viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        
        positionButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
    }
    
    // MARK: - Actions
    
    @IBAction func backToClientsPressed(_ sender: UIBarButtonItem) {
        //delegate?.portraitBackButtonPressed(sender)
        splitViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func facePressed(sender: UILongPressGestureRecognizer) {
//        print("--- FacePicker.facePressed(sender:) ---")
        
        if (sender.state == .began) {
            let point = sender.location(in: faceImageView)
//            print("FacePicker touched at: \(point)") //"  (x,y): (\(point.x),\(point.y))")
            addSite(atPoint: point)
        }
    }
    @objc
    func siteTapped(site: UIButton) {
//        print("--- FacePicker.siteTapped(site:) ---")
        guard let uuid = site.restorationIdentifier else {
            Application.onError("The tapped button did not have a set uuid!!!")
            return
        }
        let siteMenuController = SiteMenuController()
        siteMenuController.site = sites[uuid]
        siteMenuController.delegate = self
        siteMenuController.editMode = true
        siteMenuController.siteButton = site
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: siteMenuController,
            options: ContextMenu.Options(),
            sourceView: site,
            delegate: self)
    }
}

//MARK: - Private Functions

private extension SessionController {
    func setupTouchHandler() {
        //print("Setting up FacePicker touch handler.")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SessionController.facePressed(sender:)))
        longPress.minimumPressDuration = 0.5
        faceImageView.addGestureRecognizer(longPress)
        
        //        print("Current self.isUserInteractionEnabled = \(faceImageView.isUserInteractionEnabled)")
        faceImageView.isUserInteractionEnabled = true
    }
    func addSite(atPoint point: CGPoint) {
        //        print("--- FaceController.addSite(atPoint:) ---")
        //        print("point = \(point)")
        
        let uuid = UUID() //NSUUID().uuidString
        let siteMenuController = SiteMenuController()
        //
        // resolve x,y proportion from current pixels
        //
        let x = Double(point.x / faceImageView.frame.size.width)
        let y = Double(point.y / faceImageView.frame.size.height)
        let site = InjectionSite.create()
        session?.addToInjections(site)
        site.setIdAndPosition(x: x, y: y, id: uuid)
        sites[uuid.uuidString] = site
        
        let siteButton = createAndAddSiteButton(withSite: site)
        ViewHelper.positionView(siteButton, at: point)
        
        siteMenuController.site = site
        siteMenuController.delegate = self
        siteMenuController.siteButton = siteButton
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: siteMenuController,
            options: ContextMenu.Options(),
            sourceView: siteButton,
            delegate: self)
    }
    func createAndAddSiteButton(withSite site: InjectionSite, interactionEnabled enabled: Bool = true) -> UIButton {
        let siteButton = UIButton()
        siteButton.restorationIdentifier = site.id.uuidString
        siteButton.setTitle(site.formattedUnits(), for: .normal)
        siteButton.setTitleColor(view.tintColor, for: UIControlState.normal)
        if enabled {
            siteButton.addTarget(self, action: #selector(SessionController.siteTapped(site:)), for: UIControlEvents.touchUpInside)
        }
        
        //
        // TODO: revisit styling
        //
        //        siteButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        //        siteButton.titleLabel?.layer.shadowRadius = 10
        //        siteButton.titleLabel?.layer.shadowOpacity = 0.8
        siteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        
        
        siteButton.sizeToFit()
        
        siteButtons[siteButton.restorationIdentifier!] = siteButton
        faceImageView.addSubview(siteButton)
        
        return siteButton
    }
    func positionButtons() {
        for (uuid, site) in sites {
            guard let siteButton = siteButtons[uuid] else {
                Application.onError("Did not find siteButton with uuid: \(uuid) as expected. Sites and Buttons array out of sync!")
                continue
            }
            let point = ViewHelper.resolvePixelsFromProportions(size: faceImageView.frame.size, x: site.xPos, y: site.yPos)
            ViewHelper.positionView(siteButton, at: point)
        }
    }
    func removeSite(_ site: InjectionSite) {
        //        print("--- FaceController.removeSite(_:) ---")
        let uuid = site.id.uuidString
        guard let removedSite = sites.removeValue(forKey: uuid) else {
            Application.onError("Unable to find site with uuid = \(uuid) in the sites array while deleting.")
            return
        }
        session?.removeFromInjections(removedSite)
        CoreDataManager.shared.delete(removedSite)
        updateSessionAndNotify()
        Application.logInfo("Deleted InjectionSite with id: \(uuid)")
        guard let siteButton = siteButtons.removeValue(forKey: uuid)  else {
            Application.onError("Unable to find button with uuid = \(uuid) in the siteButtons array while deleting. Arrays out of sync!")
            return
        }
        siteButton.removeFromSuperview()
    }
    func updateSessionAndNotify() {
        guard let session = session else {
            Application.onError("No session when updating!")
            return
        }
        session.updateSessionImage()
        NotificationCenter.default.post(name: .sessionDidChange, object: nil, userInfo: ["": session])
    }
    func sessionSet() {
        loadViewIfNeeded()
        
        // clear existing
        for (_, button) in siteButtons {
            button.removeFromSuperview()
        }
        siteButtons.removeAll()
        sites.removeAll()
        
        guard let session = session else {
            return
        }
        
        faceImageView.isHidden = false
        if session.injectionsArray.count > 0 {
            for site in session.injectionsArray {
                self.sites[site.id.uuidString] = site
                let button = createAndAddSiteButton(withSite: site, interactionEnabled: session.isEditable)
                SessionHelper.setTitleAndColor(forButton: button, withSite: site)
            }
            positionButtons()
        }
    }
}

//MARK: - SessionListShowDetailDelegate

extension SessionController : SessionListShowDetailDelegate {
    func showSessionDetail(_ session: Session) {
        self.session = session
    }
}

//MARK: - ContextMenuDelegate

extension SessionController : ContextMenuDelegate {
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
        //        print("--- FaceController.contextMenuWillDismiss(viewController:animated:) ---")
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
        //        print("--- FaceController.contextMenuDidDismiss(viewController:animated:) ---")
        guard let controller = viewController as? SiteMenuController else {
            Application.onError("Controller was not expected type of SiteMenuController")
            return
        }
        // ignore dismiss if we were editing
        if controller.editMode {
            return
        }
        switch controller.state {
        case .Saving, .Deleting:
            // let our delegate functions handle
            return
        default:
            // need to clean up button that was orphaned
            guard let site = controller.site else {
                Application.onError("Couldn't get the site object from SiteMenuController")
                return
            }
            removeSite(site)
        }
    }
}

//MARK: - SiteMenuControllerDelegate

extension SessionController : SiteMenuControllerDelegate {
    func siteMenuDidSave(savedSite: InjectionSite) {
        updateSessionAndNotify()
        Application.logInfo("Saved InjectionSite with id: \(savedSite.id.uuidString) for Session with id: \(savedSite.session.id.uuidString)")
    }
    
    func siteMenuDidDelete(deletedSite: InjectionSite) {
        removeSite(deletedSite)
    }
}

protocol SessionControllerDelegate {
//    func sessionDidChange(session: Session?)
    func portraitBackButtonPressed(_ sender: UIBarButtonItem)
}
