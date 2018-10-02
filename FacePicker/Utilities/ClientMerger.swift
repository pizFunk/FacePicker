//
//  ClientMerger.swift
//  FacePicker
//
//  Created by matthew on 10/1/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import Foundation
import UIKit

class ClientMerger {
    // cap merges for testing:
    private var NUMBER_OF_MERGES_COUNTER = 0
    
    // presentation
    private var navigating = false
    
    var clients = [FullName:[Date]]()
    var associatedClients = [FullName:[FullName]]()
    
    private var lowInfoClientNames = [FullName]() // sorted
    private var lowInfoClients = [FullName:[FullName]]()
    
    // view controller to present from
    private var presentingViewController:UIViewController?
    
    private var currentMatchIndex:Int?
    private var currentMatch:FullName? {
        get {
            if let current = currentClient, let currentMatches = lowInfoClients[current], let index = currentMatchIndex, index >= 0 && index < currentMatches.count {
                return currentMatches[index]
            }
            return nil
        }
    }
    private var currentClientIndex:Int?
    private var currentClient:FullName? {
        get {
            if let index = currentClientIndex, index >= 0 && index < lowInfoClientNames.count {
                return lowInfoClientNames[index]
            }
            return nil
        }
    }
    
    private var completionHandler: (([FullName:[Date]]) -> ())?
    
    init() {}
    
    init(fromViewController viewController: UIViewController) {
        self.presentingViewController = viewController
    }
    
    init(fromViewController viewController: UIViewController, clientsToMerge: [FullName:[Date]], withAssociatedClients associatedClients: [FullName:[FullName]]) {
        self.presentingViewController = viewController
        self.clients = clientsToMerge
        self.associatedClients = associatedClients
    }
}

extension ClientMerger {
    func setViewController(_ viewController: UIViewController) {
        self.presentingViewController = viewController
    }
    
    func setClientsToMerge(_ clientsToMerge: [FullName:[Date]], withAssociatedClients associatedClients: [FullName:[FullName]]) {
        self.clients = clientsToMerge
        self.associatedClients = associatedClients
    }
    
    func beginMerge(completion: (([FullName:[Date]]) -> ())? = nil) {
        self.completionHandler = completion
        findLowInfoClients()
        moveFirst()
        reconcileClients()
    }
}

private extension ClientMerger {
    private func moveFirst() {
        currentClientIndex = 0
        currentMatchIndex = 0
        
        // change this to moveNext if matches are zero? -- won't happen though b/c of findLowInfoClients()
    }
    
    private func isFirst() -> Bool {
        return currentClientIndex == 0 && currentMatchIndex == 0
    }
    
    private func isFirstMatch() -> Bool {
        return currentMatchIndex == 0
    }
    
    private func isLastMatch() -> Bool {
        guard let matchIndex = currentMatchIndex, let current = currentClient, let currentMatches = lowInfoClients[current] else { return false } // uh oh
        return matchIndex + 1 == currentMatches.count
    }
    
    private func movePrevious() {
        if !isFirstMatch(), let matchIndex = currentMatchIndex {
            // retreat possible match
            currentMatchIndex = matchIndex - 1
        } else if let index = currentClientIndex, index - 1 >= 0 {
            // retreat client
            currentClientIndex = index - 1
            if let previousClient = currentClient,
                let previousMatches = lowInfoClients[previousClient], previousMatches.count > 0 {
                currentMatchIndex = previousMatches.count - 1
            } else {
                movePrevious()
            }
        } else {
            currentClientIndex = nil
        }
    }
    
    private func moveNext() {
        if !isLastMatch(), let matchIndex = currentMatchIndex {
            // advance possible match
            currentMatchIndex = matchIndex + 1
        } else if let index = currentClientIndex, index + 1 < lowInfoClientNames.count {
            // advance client
            currentClientIndex = index + 1
            if let nextClient = currentClient,
                let nextMatches = lowInfoClients[nextClient], nextMatches.count > 0 {
                currentMatchIndex = 0
            } else {
                moveNext()
            }
        } else {
            currentClientIndex = nil
        }
    }
    
    private func removeCurrentClient() {
        guard let current = currentClient, let index = currentClientIndex else { return } // uh oh
        lowInfoClients.removeValue(forKey: current)
        lowInfoClientNames.remove(at: index)
        if let next = currentClient, let nextMatches = lowInfoClients[next], nextMatches.count > 0 {
            currentMatchIndex = 0
        } else {
            moveNext()
        }
    }
    
    private func removeCurrentMatch() {
        guard let current = currentClient, var currentMatches = lowInfoClients[current], var matchIndex = currentMatchIndex else { return } // uh oh
        currentMatches.remove(at: matchIndex)
        lowInfoClients[current] = currentMatches
        if currentMatches.count == 0 {
            // no more matches left, get rid of this client
            removeCurrentClient()
        } else if matchIndex > currentMatches.count - 1 {
            matchIndex = currentMatches.count - 1
            currentMatchIndex = matchIndex
        }
    }
    
    private func findLowInfoClients() {
        let sortedKeys = clients.keys.sorted { $0 < $1 }
        let lowInfoClientsSlices = sortedKeys.split(whereSeparator: { client in
            return !client.lastName.isEmpty &&
                (client.lastName.count > 2) &&
                !client.lastName.contains("(") &&
                !client.lastName.contains(")") &&
                !(client.firstName.contains("\u{2019}") || client.lastName.contains("\u{2019}"))
        })
        let names = Array<FullName>(lowInfoClientsSlices.joined())
        for lowInfoClient in names {
            print("\(lowInfoClient)")
            // add possible matches
            // TODO: worry about casing here? maybe don't need to since we are upper-casing first letters in Importer
            let matches = associatedClients.keys.filter({ name in
                let notCurrentOrAnotherLowInfo = lowInfoClient != name && !names.contains(name) // ignore self and other low-info names
                if notCurrentOrAnotherLowInfo && lowInfoClient.firstName == name.firstName {
                    if lowInfoClient.lastName.isEmpty || name.lastName.first == lowInfoClient.lastName.first {
                        // if last name is empty or first letter of last name matches
                        return true
                    }
                    else if let hyphenIndex = name.lastName.firstIndex(of: "-"), hyphenIndex < name.lastName.endIndex {
                        // if the name has a hyphen and the second letter of the hyphenated name matches our last naem
                        let charAfterHyphenIndex = name.lastName.index(after: hyphenIndex)
                        return name.lastName[charAfterHyphenIndex] == lowInfoClient.lastName.first
                    }
                }
                return false
            })
            if matches.count > 0 {
                lowInfoClients[lowInfoClient] = matches.sorted()
                lowInfoClientNames.append(lowInfoClient)
            }
        }
    }
    
    private func reconcileClients() {
        if NUMBER_OF_MERGES_COUNTER < 20, let lowInfoName = currentClient, let possibleMatch = currentMatch {
            let mergeController = MergeClientController(nibName: MergeClientController.nibName, bundle: nil)
            mergeController.clientDifference = ClientDifference(firstFullName: lowInfoName, firstAssociations: associatedClients[lowInfoName]!, secondFullName: possibleMatch, secondAssociations: associatedClients[possibleMatch]!)
            mergeController.modalPresentationStyle = .pageSheet
            mergeController.affirmativeSelectionHandler = {
                self.NUMBER_OF_MERGES_COUNTER += 1
                // do the logic to copy
                if let datesToCpoy = self.clients[lowInfoName] {
                    if self.clients.keys.contains(possibleMatch) {
                        // append the dates to the better name's dates
                        self.clients[possibleMatch]!.append(contentsOf: datesToCpoy)
                        print("merged dates for \(lowInfoName) into \(possibleMatch)")
                    } else {
                        // we got it from the all clients name list so copy the dates to a new entry with the better name
                        self.clients[possibleMatch] = datesToCpoy
                        print("changed name for \(lowInfoName) to \(possibleMatch)")
                    }
                    // remove low-info name
                    self.clients.removeValue(forKey: lowInfoName)
                }
                // we found a match, remove the current and go again
                self.removeCurrentClient()
                self.reconcileClients()
            }
            mergeController.negativeSelectionHandler = {
                // we ruled out this match, remove it and go to the next match or client
                self.removeCurrentMatch()
                self.reconcileClients()
            }
            if !isFirstMatch() {
                mergeController.previousSelectionHandler = {
                    self.navigating = true
                    self.movePrevious()
                    self.reconcileClients()
                }
            }
            if !isLastMatch() {
                mergeController.nextSelectionHandler = {
                    self.navigating = true
                    self.moveNext()
                    self.reconcileClients()
                }
            }
            if navigating {
                mergeController.modalTransitionStyle = .crossDissolve
            }
            presentingViewController?.present(mergeController, animated: true, completion: nil)
        } else {
            // TODO: we're out of low-info clients, build our list now (for now wait to save debug txt?)
            self.completionHandler?(clients)
        }
    }
}
