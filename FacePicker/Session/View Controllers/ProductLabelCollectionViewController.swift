//
//  ProductLabelCollectionViewController.swift
//  FacePicker
//
//  Created by matthew on 9/28/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class ProductLabelCollectionViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // label image corner radius
    var cornerRadius:CGFloat = 10.0
    
    // collectionview layout
    var columns:CGFloat = 1 {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    let minimumLineSpacing:CGFloat = 15
    let minimumInterimSpacing:CGFloat = 15
    let sectionInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    var productCellWidth:CGFloat {
        get {
            //            let width = collectionView.contentSize.width
            let width = collectionView.frame.width
            return (width - (minimumInterimSpacing * (columns - 1)) - sectionInsets.left - sectionInsets.right) / columns
        }
    }
    let reuseIdentifier = "ProductLabelCell"
    private var _productLabels = [ProductLabel]()
    var productLabels = [ProductLabel]() {
        didSet {
            _productLabels = productLabels
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        ViewHelper.setViewEdges(for: collectionView, equalTo: view)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        //        collectionView.layoutIfNeeded()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
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
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension ProductLabelCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _productLabels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ProductLabelCell else {
            Application.onError("Dequeued cell with id \"\(reuseIdentifier)\" was not type ProductLabelCell!")
            return UICollectionViewCell()
        }
        
        cell.cornerRadius = cornerRadius
        cell.productLabelImageView.image = _productLabels[indexPath.item].toImage()
        cell.isEditing = isEditing
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProductLabelCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInterimSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = productCellWidth
        let width = cellWidth >= 0 ? cellWidth : 0
        let imageSize = _productLabels[indexPath.item].toImage()?.size ?? CGSize.zero
        let ratio = imageSize.height / imageSize.width
        let height = ratio * width
        return CGSize(width: width, height: height)
    }
}

extension ProductLabelCollectionViewController: ProductLabelCellDelegate {
    func productLabelCellDeleted(_ cell: ProductLabelCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            // TODO: log error
            return
        }
        func performDelete(sender: UIAlertAction) {
            // remove image
            let removedLabel = _productLabels.remove(at: indexPath.item)
            CoreDataManager.shared.delete(removedLabel)
            
            // remove cell
            collectionView.deleteItems(at: [indexPath])
        }
        let alert = UIAlertController(title: "Confirm Delete", message: "Really delete product label?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: performDelete(sender:)))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
