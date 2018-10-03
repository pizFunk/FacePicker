//
//  MergeClientController.swift
//  FacePicker
//
//  Created by matthew on 10/1/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit

class MergeClientController: UIViewController {
    // title labels
    @IBOutlet weak var matchCountLabel: UILabel!
    @IBOutlet weak var titleNameLabel: UILabel!    
    @IBOutlet weak var titleDescriptionLabel: UILabel!
    
    // first
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var firstDatesView: UIView!
    @IBOutlet weak var firstDatesStack: UIStackView!
    @IBOutlet weak var firstAssociationsView: UIView!
    @IBOutlet weak var firstAssociationsStack: UIStackView!
    
    // second
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var secondDatesView: UIView!
    @IBOutlet weak var secondDatesStack: UIStackView!
    @IBOutlet weak var secondAssociationsStack: UIStackView!
    @IBOutlet weak var secondAssociationsView: UIView!
    
    // buttons
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    // name entry
    @IBOutlet weak var nameEntryView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    // no match views to hide
    @IBOutlet var noMatchHiddenViews: [UIView]!
    
    static let nibName = "MergeClientController"
    
    var matchCount:Int = 1
    var clientDifference:ClientDifference?
    var promptForNameEntry = false
    
    var affirmativeSelectionHandler: ((FullName?) ->())?
    var negativeSelectionHandler: (() -> ())?
    var nextSelectionHandler: (() ->())?
    var previousSelectionHandler: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchCountLabel.text = String(matchCount)
        titleDescriptionLabel.text = matchCount == 1 ? "possble match for" : "possible matches for"
        setNameLabels()
        setDateStacks()
        setAssociationStacks()
        
        // set borders on buttons:
        ViewHelper.setBorderOnView(previousButton, withColor: previousButton.currentTitleColor.cgColor)
        ViewHelper.setBorderOnView(noButton, withColor: noButton.currentTitleColor.cgColor)
        ViewHelper.setBorderOnView(yesButton, withColor: yesButton.currentTitleColor.cgColor)
        ViewHelper.setBorderOnView(nextButton, withColor: nextButton.currentTitleColor.cgColor)
        ViewHelper.setBorderOnView(doneButton, withColor: doneButton.currentTitleColor.cgColor)
        previousButton.isHidden = previousSelectionHandler == nil
        noButton.isHidden = negativeSelectionHandler == nil
        yesButton.isHidden = affirmativeSelectionHandler == nil
        nextButton.isHidden = nextSelectionHandler == nil
        
        // set borders on views:
        ViewHelper.setBorderOnView(firstView, withColor: ViewHelper.defaultBorderColor)
        ViewHelper.setBorderOnView(secondView, withColor: ViewHelper.defaultBorderColor)
        ViewHelper.setBorderOnView(firstDatesView, withColor: UIColor.blue.cgColor)
        ViewHelper.setBorderOnView(secondDatesView, withColor: UIColor.blue.cgColor)
        ViewHelper.setBorderOnView(firstAssociationsView, withColor: UIColor.blue.cgColor)
        ViewHelper.setBorderOnView(secondAssociationsView, withColor: UIColor.blue.cgColor)
        
        if clientDifference?.secondContext == nil {
            noMatchHiddenViews.forEach({ view in
                view.isHidden = true
            })
            secondDatesView.removeFromSuperview()
            secondAssociationsView.removeFromSuperview()
        }
        nameEntryView.isHidden = !promptForNameEntry
    }
    
    private func setNameLabels() {
        titleNameLabel.text = clientDifference?.firstFullName?.description
        noButton.setTitle("Skip \(clientDifference?.firstFullName?.description ?? "")", for: .normal)
        firstNameLabel.text = clientDifference?.firstFullName?.description
        secondNameLabel.text = clientDifference?.secondFullName?.description
    }
    
    private func setDateStacks() {
        if let firstDates = clientDifference?.firstSortedDates {
            firstDatesView.isHidden = firstDates.count == 0
            for date in firstDates {
                let label = UILabel()
                label.text = date
                firstDatesStack.addArrangedSubview(label)
            }
        } else {
            firstDatesView.isHidden = true
        }
        
        if let secondDates = clientDifference?.secondSortedDates {
            secondDatesView.isHidden = secondDates.count == 0
            for date in secondDates {
                let label = UILabel()
                label.text = date
                secondDatesStack.addArrangedSubview(label)
            }
        } else {
            secondDatesView.isHidden = true
        }
    }
    
    private func setAssociationStacks() {
        if let firstAssociations = clientDifference?.firstSortedAssociations {
            firstAssociationsView.isHidden = firstAssociations.count == 0
            for lhs in firstAssociations {
                let label = UILabel()
                label.text = lhs.description
                firstAssociationsStack.addArrangedSubview(label)
            }
        } else {
            firstAssociationsView.isHidden = true
        }
        if let secondAssociations = clientDifference?.secondSortedAssociations {
            secondAssociationsView.isHidden = secondAssociations.count == 0
            for rhs in secondAssociations {
                let label = UILabel()
                label.text = rhs.description
                secondAssociationsStack.addArrangedSubview(label)
            }
        } else {
            secondAssociationsView.isHidden = true
        }
        guard !firstAssociationsView.isHidden && !secondAssociationsView.isHidden else {
            // don't bother highlighting if one side is hidden
            return
        }
        let boldFont = UIFont.systemFont(ofSize: 17, weight: .bold)
        for lhs in firstAssociationsStack.arrangedSubviews {
            for rhs in secondAssociationsStack.arrangedSubviews {
                guard let lhsLabel = lhs as? UILabel, let rhsLabel = rhs as? UILabel, let lhsText = lhsLabel.text, let rhsText = rhsLabel.text else { continue }
                if lhsText.lowercased().contains(rhsText.lowercased()) || rhsText.lowercased().contains(lhsText.lowercased()) {
                    // "highlight" them both
                    lhsLabel.font = boldFont
                    lhsLabel.textColor = UIColor.blue
                    rhsLabel.font = boldFont
                    rhsLabel.textColor = UIColor.blue
                }
            }
        }
    }
    
    @IBAction func noButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        negativeSelectionHandler?()
    }
    
    @IBAction func yesButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        affirmativeSelectionHandler?(nil)
    }
    
    @IBAction func previousButtonPressed(_ sender: UIButton) {
        modalTransitionStyle = .crossDissolve
        dismiss(animated: true, completion: nil)
        previousSelectionHandler?()
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        modalTransitionStyle = .crossDissolve
        dismiss(animated: true, completion: nil)
        nextSelectionHandler?()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, !firstName.isEmpty, !lastName.isEmpty else {
            return
        }
        dismiss(animated: true, completion: nil)
        let fullName = FullName(firstName: firstName, lastName: lastName)
        affirmativeSelectionHandler?(fullName)
    }
}
