//
//  LeftColumnController.swift
//  FacePicker
//
//  Created by matthew on 9/21/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class LeftColumnController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    let sessionListViewController: SessionListController
    let sessionDetailViewController: SessionDetailController
    let sessionDetailNibName = "SessionDetailController"
    
    // button bar labels
    let showDetailLabel = "Show Detail"
    let showHistoryLabel = "Show History"
    
    var session: Session? {
        didSet {
            sessionDetailViewController.session = session
        }
    }
    
    enum ViewType: Int {
        case SessionList = 0
        case SessionDetail
        
        static var count: Int {
            return ViewType.SessionDetail.rawValue + 1
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        sessionListViewController = SessionListController()
        sessionDetailViewController = SessionDetailController(nibName: sessionDetailNibName, bundle: nil)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        addChildViewController(sessionListViewController)
        sessionListViewController.didMove(toParentViewController: self)
        addChildViewController(sessionDetailViewController)
        sessionDetailViewController.didMove(toParentViewController: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        sessionListViewController = SessionListController()
        sessionDetailViewController = SessionDetailController(nibName: sessionDetailNibName, bundle: nil)
        
        super.init(coder: aDecoder)
        
        addChildViewController(sessionListViewController)
        sessionListViewController.didMove(toParentViewController: self)
        addChildViewController(sessionDetailViewController)
        sessionDetailViewController.didMove(toParentViewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        pageControl.numberOfPages = ViewType.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor(white: 0.8, alpha: 1)
        pageControl.currentPageIndicatorTintColor = UIColor(white: 0.5, alpha: 1)
        pageControl.addTarget(self, action: #selector(LeftColumnController.pageControlValueChanged(sender:)), for: .valueChanged)
        
        setupCollectionViewCells()
        
        sessionListViewController.selectionChangedHandler = { (session) in
            self.session = session
            self.scrollToPage(1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    var initialScrollComplete = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !initialScrollComplete {
            scrollToPage(1, animated: false)
            initialScrollComplete = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
        setPage(page)
    }
    
    @objc
    func pageControlValueChanged(sender: UIPageControl) {
        scrollToPage(sender.currentPage)
    }
    
    @IBAction func backToClientsPressed(_ sender: UIBarButtonItem) {
        if splitViewController?.displayMode == .primaryOverlay {
            splitViewController?.preferredDisplayMode = .allVisible
        }
        splitViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func columnTogglePressed(_ sender: UIBarButtonItem) {
//        print("columnTogglePressed: currentPage = \(pageControl.currentPage)")
        switch pageControl.currentPage {
        case 0:
            scrollToPage(1)
        case 1:
            scrollToPage(0)
        default:
            break
        }
    }
}

private extension LeftColumnController {
    private func setupCollectionViewCells() {
        self.collectionView.register(SessionListCell.classForCoder(), forCellWithReuseIdentifier: SessionListCell.reuseIdentifier)
        self.collectionView.register(SessionDetailCell.classForCoder(), forCellWithReuseIdentifier: SessionDetailCell.reuseIdentifier)
    }
    
    private func setPage(_ page: Int) {
//        print("setPage: \(page)")
        pageControl.currentPage = page
        switch page {
        case 0:
            navigationItem.rightBarButtonItem?.title = showDetailLabel
        case 1:
            navigationItem.rightBarButtonItem?.title = showHistoryLabel
        default:
            break
        }
    }
    
    private func scrollToPage(_ page: Int, animated: Bool = true) {
//        print("scroll to page: \(page)")
        collectionView.scrollToItem(at: IndexPath(item: page, section: 0), at: .centeredHorizontally, animated: animated)
        setPage(page)
    }
}

extension LeftColumnController : SessionControllerDelegate {
    
    func portraitBackButtonPressed(_ sender: UIBarButtonItem) {
        backToClientsPressed(sender)
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension LeftColumnController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets()
    }
}
    
// MARK: UICollectionViewDataSource

extension LeftColumnController : UICollectionViewDataSource {
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return ViewType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewType = ViewType(rawValue: indexPath.item) else {
            fatalError()
        }
        
        switch viewType {
        case .SessionList:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SessionListCell.reuseIdentifier, for: indexPath) as? SessionListCell else {
                fatalError()
            }
            cell.viewController = sessionListViewController
            return cell
        case .SessionDetail:
            guard let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: SessionDetailCell.reuseIdentifier, for: indexPath) as? SessionDetailCell else {
                fatalError()
            }
            cell.viewController = sessionDetailViewController
            return cell
        }
    }
}

// MARK: UICollectionViewDelegate

extension LeftColumnController : UICollectionViewDelegate {
    
}
