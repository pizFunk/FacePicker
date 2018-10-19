//
//  ClientDetailController.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

// MARK: - Properties

class ClientDetailController: UIViewController {
    
    let USE_SESSION_CELL = false
    private let simpleCellReuseIdentifier = "SimpleSessionCell"
    private let detailedCellReuseIdentifier = "DetailedSessionCell"
    private let reuseIndentifier = "SessionCell"
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let sessionSplitSegueIdentifier = "SessionsSplitSegue"
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var clientViewContainer: UIView!
    
//    lazy var editSessionsButton = {
//        return UIBarButtonItem(title: "Edit Treatments", style: .plain, target: self, action: #selector(ClientDetailController.newSessionButtonPressed(_:)))
//    }()
    lazy var newSessionButton = {
        return UIBarButtonItem(title: "New Treatment", style: .plain, target: self, action: #selector(ClientDetailController.newSessionButtonPressed(_:)))
    }()
    
    var widthAnchor:NSLayoutConstraint?
    var rightAnchor:NSLayoutConstraint?
    
    lazy var clientViewController:ClientViewController = {
        let clientViewController = ClientViewController(nibName: "ClientViewController", bundle: nil)
        clientViewController.delegate = self
        addChildViewController(clientViewController)
        clientViewContainer.addSubview(clientViewController.view)
        /*
         ViewHelper.setOrigin(for: clientViewController.stackView, equalTo: clientViewContainer)
         /*clientControllerViewWidthConstraint =*/ ViewHelper.setSize(for: clientViewController.stackView, equalTo: clientViewContainer).width
         */
        rightAnchor = ViewHelper.setViewEdges(for: clientViewController.view, equalTo: clientViewContainer).right
        
        return clientViewController
    }()
    
    var delegate: ClientDetailControllerDelegate?
    var client: Client? {
        didSet {
            loadViewIfNeeded()
            setupClient()
        }
    }
    var sessions: [Session] = [Session]() {
        didSet {
            // set edit button visibility
            setupNavigationBarButtons(clientExists: true, clientHasSessions: sessions.count > 0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Public Functions

extension ClientDetailController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if USE_SESSION_CELL {
            collectionView.register(UINib(nibName: reuseIndentifier, bundle: nil), forCellWithReuseIdentifier: reuseIndentifier)
        } else {
            collectionView.register(UINib(nibName: simpleCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: simpleCellReuseIdentifier)
            collectionView.register(UINib(nibName: detailedCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: detailedCellReuseIdentifier)
        }
        
        self.stackView.isHidden = true // hide by default, show when non-nil client is set
        ViewHelper.setBorderOnView(collectionView, withColor: UIColor(white: 0.8, alpha: 1).cgColor)
        collectionView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ClientDetailController.sessionDidChange(_:)), name: .sessionDidChange, object: nil)
        
        splitViewController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func shouldShowDetailedSessionCells(displayMode: UISplitViewControllerDisplayMode?) -> Bool {
        return ViewHelper.isDeviceLandscape() &&
            traitCollection.horizontalSizeClass == .regular &&
            displayMode == UISplitViewControllerDisplayMode.primaryHidden
    }
    private func shouldShowDetailedSessionCells() -> Bool {
        return shouldShowDetailedSessionCells(displayMode: splitViewController?.displayMode)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if widthAnchor == nil {
            widthAnchor = clientViewController.stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3)
//            widthAnchor = clientViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33)
//            widthAnchor = clientViewContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33)
        }
        
        if  shouldShowDetailedSessionCells() {
            stackView.axis = .horizontal
            clientViewController.stackView.axis = .vertical
            clientViewController.stackView.distribution = .fill
            clientViewController.stackView.spacing = 8
            
            widthAnchor?.isActive = true
//            rightAnchor?.isActive = false
        } else {
            stackView.axis = .vertical
            clientViewController.stackView.axis = .horizontal
            clientViewController.stackView.distribution = .fillEqually
            clientViewController.stackView.spacing = 40
            
            widthAnchor?.isActive = false
//            rightAnchor?.isActive = true
        }
        stackView.layoutIfNeeded()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if USE_SESSION_CELL {
        for visibleCell in collectionView.visibleCells {
            if let sessionCell = visibleCell as? SessionCell {
                sessionCell.showDetail = shouldShowDetailedSessionCells()
            }
        }
        } else {
        collectionView.reloadData()
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    
        if !editing {
            setEditButtonTitle()
        }
        
        // disable other nav bar buttons, disable client list, disable client view controller
        setNavBarButtonsEnabled(!editing, buttonsToIgnore: [editButtonItem])  // buttons
        delegate?.setEditingSessions(editing)  // client list
        clientViewController.setEnabled(!editing, includingNavigationController: false) // client view controller
        contentView.backgroundColor = editing ? ViewHelper.blockingViewBackgroundColor : UIColor.clear
        
        // show/hide delete button on collection view cells
        var nonVisibleIndexPaths = [IndexPath]()
        for index in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: index, section: 0)
            if let sessionCell = collectionView.cellForItem(at: indexPath) as? DeletableCollectionViewCell {
                sessionCell.isEditing = editing
            }
            else {
                nonVisibleIndexPaths.append(indexPath)
            }
        }
        collectionView.reloadItems(at: nonVisibleIndexPaths)
    }
    
    // MARK: - Actions
    
    @IBAction func newSessionButtonPressed(_ sender: UIBarButtonItem) {
        guard let newSession = addNewSession() else { return }
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredVertically)
        performSegue(withIdentifier: sessionSplitSegueIdentifier, sender: newSession)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIBarButtonItem) {
        let settingsController = SettingsViewController(nibName: SettingsViewController.nibName, bundle: nil)
        showContextualMenu(settingsController)
    }
    
    // MARK: - NotificationCenter
    
    @objc
    func sessionDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Session], let sessionData = userInfo.first else {
            return
        }
        let session = sessionData.value
        guard let index = sessions.index(of: session) else {
            Application.onError("Session that was changed in SessionList was not found in sessions!")
            return
        }
        if USE_SESSION_CELL {
        if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SessionCell {
            cell.session = session
        }
        } else {
            if let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SimpleSessionCell {
                cell.session = session
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == sessionSplitSegueIdentifier {
            guard let split = segue.destination as? UISplitViewController,
                let sessionListNav = split.viewControllers.first as? UINavigationController,
                let leftColumnController = sessionListNav.topViewController as? LeftColumnController,
                //            let sessionController = split.viewControllers.last as? SessionController
                let sessionControllerNav = split.viewControllers.last as? UINavigationController,
                let sessionController = sessionControllerNav.topViewController as? SessionController else {
                    Application.onError("Problem with Sessions SVC configuration when trying to navigate.")
                    return
            }
            
            let sessionListController = leftColumnController.sessionListViewController            
            sessionController.delegate = leftColumnController
            sessionListController.parentDelegate = self
            sessionListController.showDetailDelegate = sessionController
            
            guard let session = sender as? Session else {
                Application.onError("Segue sender was not of type Session!")
                return
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
}

// MARK: - Private Functions

private extension ClientDetailController {
    
    private func setupClient() {
        self.clientViewController.client = self.client
        if let client = client {
            self.stackView.isHidden = false
            
            if let sessions = client.sessions {
                self.sessions = [Session](sessions)
                self.sessions.sort {
                    ($0.date as Date) > ($1.date as Date)
                }
            } else {
                self.sessions = [Session]()
            }
            //                collectionView.isHidden = self.sessions.count == 0
        } else {
            // no client
            self.stackView.isHidden = true
            setupNavigationBarButtons(clientExists: false, clientHasSessions: false) // alternatively runs in the didSet of self.sessions
        }
        // reload collection view
        collectionView.reloadData()
    }

    private func setupNavigationBarButtons(clientExists: Bool, clientHasSessions: Bool) {
        if navigationItem.rightBarButtonItems != nil {
            if clientExists  {
                if !navigationItem.rightBarButtonItems!.contains(newSessionButton) {
                    self.navigationItem.rightBarButtonItems!.append(newSessionButton)
                }
                let editSessionsButtonExists = navigationItem.rightBarButtonItems!.contains(editButtonItem)
                if clientHasSessions && !editSessionsButtonExists {
                    let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                    fixedSpace.width = 50
                    self.navigationItem.rightBarButtonItems!.append(fixedSpace)
                    self.navigationItem.rightBarButtonItems!.append(editButtonItem)
                    setEditButtonTitle()
                    
                } else if !clientHasSessions && editSessionsButtonExists {
                    navigationItem.rightBarButtonItems?.removeLast(2)
                }
            } else {
                navigationItem.rightBarButtonItems = [navigationItem.rightBarButtonItems!.first!]
            }
        }
    }
    
    private func setEditButtonTitle() {
        editButtonItem.title = "Edit Treatments"
    }
    
    private func addNewSession() -> Session? {
        guard let client = client else {
            Application.onError("Trying to add new Session to nil Client!")
            return nil
        }
//        let session:Session = CoreDataManager.shared.create()
        let session = Session.create()
        client.addToSessions(session)
        session.date = Date.init() as NSDate
        session.id = UUID()
        sessions.insert(session, at: 0)
        
        Application.logInfo("Created Session with uuid: \(session.id.uuidString) for Client with uuid: \(client.id.uuidString)")
        
        return session
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ClientDetailController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        var columns:CGFloat = 2
        var widthRatio:CGFloat = 1.0
        if shouldShowDetailedSessionCells() {
            columns = 1
            widthRatio = 0.5
        } else if width > 1000 {
            columns = 3
        }
        var layoutSpacings:CGFloat = 0
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layoutSpacings = layout.sectionInset.left + layout.sectionInset.right + (layout.minimumInteritemSpacing * (columns - 1))
        }
        let itemSize = (width - layoutSpacings) / columns
        return CGSize(width: itemSize, height: itemSize * widthRatio)
    }
}

// MARK: - UICollectionViewDataSource

extension ClientDetailController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if USE_SESSION_CELL {
            guard let sessionCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIndentifier, for: indexPath) as? SessionCell else {
                Application.onError("Cell with identifier \(reuseIndentifier) wasn't of type DetailedSessionCell!")
                return UICollectionViewCell()
            }
            print("cellForItemAt: \(shouldShowDetailedSessionCells())")
            sessionCell.showDetail = shouldShowDetailedSessionCells()
            sessionCell.session = sessions[indexPath.item]
            return sessionCell
        } else {
        if shouldShowDetailedSessionCells() {
            guard let sessionCell = collectionView.dequeueReusableCell(withReuseIdentifier: detailedCellReuseIdentifier, for: indexPath) as? DetailedSessionCell else {
                Application.onError("Cell with identifier \(detailedCellReuseIdentifier) wasn't of type DetailedSessionCell!")
                return UICollectionViewCell()
            }
            sessionCell.session = sessions[indexPath.item]
            sessionCell.delegate = self
            sessionCell.isEditing = isEditing
            return sessionCell
        } else {
            guard let sessionCell = collectionView.dequeueReusableCell(withReuseIdentifier: simpleCellReuseIdentifier, for: indexPath) as? SimpleSessionCell else {
                Application.onError("Cell with identifier \(simpleCellReuseIdentifier) wasn't of type SessionCell!")
                return UICollectionViewCell()
            }
            sessionCell.session = sessions[indexPath.item]
            sessionCell.delegate = self
            sessionCell.isEditing = isEditing
            return sessionCell
        }
        }
    }
}

// MARK: - UICollectionViewDelegate

extension ClientDetailController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            // don't do anything when editing
            return
        }
        let selectedSession = sessions[indexPath.row]
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        performSegue(withIdentifier: sessionSplitSegueIdentifier, sender: selectedSession)
    }
}

// MARK: - FlexibleSessionCellDelegate

extension ClientDetailController: FlexibleSessionCellDelegate {
    
    func deleteSession(_ session: Session?) {
        guard let session = session, let index = sessions.firstIndex(of: session) else {
            return
        }
        
        func performDelete(sender: Any) {
            // remove session from array and ManagedObjectContext
            sessions.remove(at: index)
            CoreDataManager.shared.delete(session)
            
            // remove cell from collection view
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            
            // check if we're out of sessions
            if sessions.count == 0 {
                isEditing = false
            }
        }
        let alert = UIAlertController(title: "Confirm Delete", message: "Really delete treatment for \(session.formattedDate())?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: performDelete(sender:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - ClientViewControllerDelegate

extension ClientDetailController: ClientViewControllerDelegate {
    
    func clientNameWasEdited(client: Client) {
        delegate?.clientNameWasEdited(client: client)
    }
}

// MARK: - SessionListParentDelegate

extension ClientDetailController: SessionListParentDelegate {
    
    func sessionSelected(indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
    }
}

// MARK: - ClientSelectionChangedDelegate

extension ClientDetailController: ClientSelectionChangedDelegate {
    
    func clientSelectionDidChange(_ client: Client?) {
        self.client = client
    }
}

extension ClientDetailController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
        if USE_SESSION_CELL {
            let shouldShowDetail = shouldShowDetailedSessionCells(displayMode: displayMode)
            for visibleCell in collectionView.visibleCells {
                if let sessionCell = visibleCell as? SessionCell {
                    sessionCell.showDetail = shouldShowDetail
                }
            }
        } else {
            collectionView.reloadData()
        }
    }
    
//    func splitViewController(_ splitViewController: UISplitViewController, show vc: UIViewController, sender: Any?) -> Bool {
//        return true
//    }
//    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
//        return true
//    }
//    func splitViewControllerSupportedInterfaceOrientations(_ splitViewController: UISplitViewController) -> UIInterfaceOrientationMask {
//        return .all
//    }
//    func splitViewControllerPreferredInterfaceOrientationForPresentation(_ splitViewController: UISplitViewController) -> UIInterfaceOrientation {
//        return .landscapeLeft
//    }
//    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
//        return nil
//    }
//    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
//        return true
//    }
}

// MARK: - ClientDetailControllerDelegate

protocol ClientDetailControllerDelegate {
    func clientNameWasEdited(client: Client)
    func setEditingSessions(_ editing: Bool)
}
