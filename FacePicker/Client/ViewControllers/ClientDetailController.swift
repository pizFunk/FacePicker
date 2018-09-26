//
//  ClientDetailController.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import CoreData

class ClientDetailController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ClientSelectionChangedDelegate, SessionListParentDelegate, ClientViewControllerDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private let reuseIdentifier = "SessionCell"
    private let sessionSplitSegueIdentifier = "SessionsSplitSegue"
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var clientViewContainer: UIView!
    private var cellMultiplier: CGFloat = 0.44
    lazy var newSessionButton = {
        return UIBarButtonItem(title: "New Session", style: .plain, target: self, action: #selector(ClientDetailController.newSessionButtonPressed(_:)))
    }()
    lazy var clientViewController:ClientViewController = {
        let clientViewController = ClientViewController(nibName: "ClientViewController", bundle: nil)
        clientViewController.delegate = self
        addChildViewController(clientViewController)
        clientViewContainer.addSubview(clientViewController.view)
        ViewHelper.setOrigin(for: clientViewController.stackView, equalTo: clientViewContainer)
        ViewHelper.setSize(for: clientViewController.stackView, equalTo: clientViewContainer)
        return clientViewController
    }()
    
    var delegate: ClientDetailControllerDelegate?
    var client: Client? {
        didSet {
            loadViewIfNeeded()
            self.clientViewController.client = self.client
            var showNewSessionButton = false
            if let client = client {
                showNewSessionButton = true
                self.stackView.isHidden = false
                
                if let sessions = client.sessions {
                    self.sessions = [Session].init(sessions)
                    self.sessions.sort(by: { (a, b) in
                        if let aDate = a.date as Date?, let bDate = b.date as Date? {
                            return aDate > bDate
                        }
                        return false
                    })
                } else {
                    self.sessions = [Session]()
                }
                collectionView.isHidden = self.sessions.count == 0
            } else {
                // no client
                self.stackView.isHidden = true
            }
            if navigationItem.rightBarButtonItems != nil {
                let buttonExists = navigationItem.rightBarButtonItems!.contains(newSessionButton)
                if showNewSessionButton && !buttonExists  {
                    self.navigationItem.rightBarButtonItems!.append(newSessionButton)
                } else if !showNewSessionButton && buttonExists {
                    navigationItem.rightBarButtonItems!.removeLast()
                }
            }
            // reload collection view
            collectionView.reloadData()
        }
    }
    var sessions: [Session] = [Session]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard self.client != nil else {
//            return
//        }
        
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.stackView.isHidden = true // hide by default, show when non-nil client is set
        ViewHelper.setBorderOnView(collectionView, withColor: UIColor(white: 0.8, alpha: 1).cgColor)
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)

        // Do any additional setup after loading the view.

//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(ClientDetailController.sessionDidChange(_:)), name: .sessionDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var columns:CGFloat = 2
        let width = collectionView.frame.width
        if width > 1000 {
            columns = 3
        }
        let itemSize = (width - (layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * (columns - 1)))) / columns
        return CGSize(width: itemSize, height: itemSize)
    }
    
    // UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return client?.sessions?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sessionCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SessionCell else {
            fatalError("Cell with identifier SessionCell wasn't of type SessionCell!")
        }
        
        sessionCell.session = sessions[indexPath.row]
        
        return sessionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSession = sessions[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        performSegue(withIdentifier: sessionSplitSegueIdentifier, sender: selectedSession)
    }
    
    // MARK: - Private Functions
    private func addNewSession() -> Session {
        let context = managedContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Session", in: context) else {
            fatalError("ClientDetailController: failed to load entity for name \"Session\"")
        }
        let session = Session(entity: entity, insertInto: context)
        client?.addToSessions(session)
        session.date = Date.init() as NSDate?
        session.id = UUID()
        
        sessions.insert(session, at: 0)
        
        return session
    }
    
    // MARK: - Actions
    @IBAction func newSessionButtonPressed(_ sender: UIBarButtonItem) {
        let newSession = addNewSession()
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
        performSegue(withIdentifier: sessionSplitSegueIdentifier, sender: newSession)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let settingsController = SettingsViewController(nibName: SettingsViewController.nibName, bundle: nil)
        showContextualMenu(settingsController)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == sessionSplitSegueIdentifier {
            let split = segue.destination as! UISplitViewController
            let sessionListNav = split.viewControllers.first as! UINavigationController
            let leftColumnController = sessionListNav.topViewController as! LeftColumnController
//            let sessionController = split.viewControllers.last as! SessionController
            let sessionControllerNav = split.viewControllers.last as! UINavigationController
            let sessionController = sessionControllerNav.topViewController as! SessionController
            
            
            // make the detail view expandable (reqires fixing the width of the SessionListController UICollectionView)
//            split.preferredDisplayMode = .allVisible
//            sessionController.navigationItem.leftBarButtonItem = split.displayModeButtonItem
            
            let sessionListController = leftColumnController.sessionListViewController            
            sessionController.delegate = leftColumnController
            sessionListController.parentDelegate = self
            sessionListController.showDetailDelegate = sessionController
            
            guard let session = sender as? Session else {
                fatalError("ClientDataController: segue sender was not a Session!")
            }
            sessionListController.initialSelectedSession = self.sessions.index(of: session)
            sessionListController.sessions = self.sessions
            leftColumnController.session = session
            sessionController.session = session
            
//            print ("UIScreen.main.bounds.width = \(UIScreen.main.bounds.width)")
            let fraction:CGFloat = 0.37
            
            let screenWidth = ViewHelper.isDeviceLandscape() ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
            split.maximumPrimaryColumnWidth = screenWidth * fraction
            split.preferredPrimaryColumnWidthFraction = fraction // actually causes the SessionController to load (but not lay out)
        }
    }
    
    // MARK: - UISplitViewControllerDelegate
//    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
//        switch displayMode {
//        case .allVisible:
//            cellMultiplier = 0.45
//        case .primaryHidden:
//            cellMultiplier = 0.2
//        default:
//            break
//        }
//        print("ClientDetailController: changed cellMultiplier to: \(cellMultiplier)")
//    }
    
    // MARK: - ClientViewControllerDelegate
    func clientNameWasEdited(client: Client) {
        delegate?.clientNameWasEdited(client: client)
    }
    
    // MARK: - SessionListControllerDelegate
    func sessionListDidRequestDismiss(controller: SessionListController) {
//        self.sessions = controller.sessions
//        self.collectionView?.reloadData()
//        if let indexPaths = collectionView.indexPathsForSelectedItems, let index = indexPaths.first {
//            collectionView.scrollToItem(at: index, at: .centeredVertically, animated: true)
//        }
//        self.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func sessionSelected(indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
    
    // MARK: - ClientSelectionChangedDelegate
    
    func clientSelectionDidChange(_ client: Client?) {
        self.client = client
    }
    
    // MARK: - NotificationCenter
    @objc
    func sessionDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Session], let sessionData = userInfo.first else {
            return
        }
        let session = sessionData.value
        guard let index = sessions.index(of: session) else {
            fatalError("Session that was changed in SessionList was not found in sessions!")
        }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SessionCell else {
            //fatalError("Couldn't find session index in collection view!")
            // cel not visible? will update when scrolled to instead...
            return
        }
        cell.session = session
    }
}

protocol ClientDetailControllerDelegate {
    func clientNameWasEdited(client: Client)
}
