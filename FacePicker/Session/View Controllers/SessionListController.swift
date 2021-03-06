//
//  SessionsListController.swift
//  FacePicker
//
//  Created by matthew on 9/13/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class SessionListController: UIViewController {
    private let reuseIdentifier = "SimpleSessionCell"
    
    var sessions: [Session] = [Session]()
    var initialSelectedSession: Int?
    
    var parentDelegate: SessionListParentDelegate?
    var showDetailDelegate: SessionListShowDetailDelegate?
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var selectionChangedHandler: ((Session) -> ())?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SessionListController {
    
    override func viewDidLoad() {
//        print("SessionListController.viewDidLoad")
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        view.addSubview(collectionView)
        ViewHelper.setViewEdges(for: collectionView, equalTo: view)
        collectionView.backgroundColor = UIColor.white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(SessionListController.sessionDidChange(_:)), name: .sessionDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLayoutSubviews() {
        //        print("SessionListController.viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
        
        if initialSelectedSession != nil {
            self.collectionView.selectItem(at: IndexPath(item: initialSelectedSession!, section: 0), animated: false, scrollPosition: .centeredVertically)
            initialSelectedSession = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - NotificationCenter
    
    @objc
    func sessionDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Session], let sessionData = userInfo.first else {
            return
        }
        let session = sessionData.value
        if let index = sessions.index(of: session),
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? SimpleSessionCell {
            cell.session = session
        }
        // pass it up to the client detail controller
//        delegate?.sessionDidChange(session: session)
    }
}

extension SessionListController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right))
        return CGSize(width: itemSize, height: itemSize)
    }
    
}
    
extension SessionListController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return sessions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SimpleSessionCell else {
            Application.onError("SessionListController: Cell wasn't of type SessionCell!")
            return UICollectionViewCell()
        }
        
        cell.session = sessions[indexPath.item]
        
        return cell
    }
    
}
    
extension SessionListController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        parentDelegate?.sessionSelected(indexPath: indexPath)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
        let session = sessions[indexPath.item]
        showDetailDelegate?.showSessionDetail(session)
        selectionChangedHandler?(session)
        //        performSegue(withIdentifier: "ShowSessionDetailSegue", sender: sessions[indexPath.row])
    }
    
}

protocol SessionListParentDelegate {
    func sessionSelected(indexPath: IndexPath)
}

protocol SessionListShowDetailDelegate {
    func showSessionDetail(_ session: Session)
}
