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
    var contexts = [FullName:ClientContext]()
    
    // successful merge pairs
    var mergePairs = [MergedPair]()
    
    private var lowInfoClientNames = [FullName]() // sorted
    private var lowInfoClientMatches = [FullName:[FullName]]()
    
    // view controller to present from
    private var presentingViewController:UIViewController?
    
    private var currentMatchIndex:Int?
    private var currentMatch:FullName? {
        get {
            if let current = currentClient, let currentMatches = lowInfoClientMatches[current], let index = currentMatchIndex, index >= 0 && index < currentMatches.count {
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
    
    init(fromViewController viewController: UIViewController, clientsToMerge: [FullName:[Date]], withContexts contexts: [FullName:ClientContext]) {
        self.presentingViewController = viewController
        self.clients = clientsToMerge
        self.contexts = contexts
    }
}

extension ClientMerger {
    func setViewController(_ viewController: UIViewController) {
        self.presentingViewController = viewController
    }
    
    func setClientsToMerge(_ clientsToMerge: [FullName:[Date]], withContexts associatedClients: [FullName:ClientContext]) {
        self.clients = clientsToMerge
        self.contexts = associatedClients
    }
    
    func beginMerge(completion: (([FullName:[Date]]) -> ())? = nil) {
        self.completionHandler = completion
        findLowInfoClients()
        if lowInfoClientMatches.count > 0 {
            moveFirst()
            reconcileClients()
        }
    }
}

private extension ClientMerger {
    private func moveFirst() {
        currentClientIndex = 0
        if let current = currentClient, let count = lowInfoClientMatches[current]?.count, count > 0 {
            currentMatchIndex = 0
        } else {
            currentMatchIndex = nil
        }
    }
    
    private func isFirst() -> Bool {
        return currentClientIndex == 0 && currentMatchIndex == 0
    }
    
    private func isFirstMatchOrNil() -> Bool {
        return currentMatchIndex == nil || currentMatchIndex == 0
    }
    
    private func isLastMatchOrNil() -> Bool {
        guard let matchIndex = currentMatchIndex, let current = currentClient, let currentMatches = lowInfoClientMatches[current] else {
            return true // uh oh
        }
        return /*currentMatches.count > 0 &&*/ matchIndex + 1 == currentMatches.count
    }
    
    private func movePrevious() {
        if !isFirstMatchOrNil(), let matchIndex = currentMatchIndex {
            // retreat possible match
            currentMatchIndex = matchIndex - 1
        } else if let index = currentClientIndex, index - 1 >= 0 {
            // retreat client
            currentClientIndex = index - 1
            if let previousClient = currentClient,
                let previousMatches = lowInfoClientMatches[previousClient], previousMatches.count > 0 {
                currentMatchIndex = previousMatches.count - 1
            } else {
                currentMatchIndex = nil
            }
        } else {
            currentClientIndex = nil
        }
    }
    
    private func moveNext() {
        if !isLastMatchOrNil(), let matchIndex = currentMatchIndex {
            // advance possible match
            currentMatchIndex = matchIndex + 1
        } else {
            moveNextClient()
        }
    }
    
    private func moveNextClient() {
        if let index = currentClientIndex, index + 1 < lowInfoClientNames.count {
            // advance client
            currentClientIndex = index + 1
            if let nextClient = currentClient,
                let nextMatches = lowInfoClientMatches[nextClient], nextMatches.count > 0 {
                currentMatchIndex = 0
                return
            } else {
                currentMatchIndex = nil
            }
        } else {
            currentClientIndex = nil
        }
    }
    
    private func removeCurrentClient() {
        guard let current = currentClient, let index = currentClientIndex else { return } // uh oh
        lowInfoClientMatches.removeValue(forKey: current)
        lowInfoClientNames.remove(at: index)
        if let next = currentClient, let nextMatches = lowInfoClientMatches[next], nextMatches.count > 0 {
            currentMatchIndex = 0
        } else {
            currentMatchIndex = nil
        }
    }
    
    private func removeCurrentMatch() {
        guard let current = currentClient, var currentMatches = lowInfoClientMatches[current], var matchIndex = currentMatchIndex else { return } // uh oh
        currentMatches.remove(at: matchIndex)
        lowInfoClientMatches[current] = currentMatches
        if currentMatches.count == 0 {
            // no more matches left, get rid of this client
            removeCurrentClient()
        } else if matchIndex > currentMatches.count - 1 {
            matchIndex = currentMatches.count - 1
            currentMatchIndex = matchIndex
        }
    }
    
    private func nameCharactersValid(_ name: String) -> Bool {
        let allowedCharacters = CharacterSet.letters.union(CharacterSet(charactersIn: "- "))
        return allowedCharacters.isSuperset(of: CharacterSet(charactersIn: name))
    }
    
    private func isFullNameLowInfo(_ name: FullName) -> Bool {
        return name.lastName.isEmpty ||
            name.lastName.count < 3 ||
            !nameCharactersValid(name.description)
    }
    
    private func findLowInfoClients() {
        let sortedKeys = clients.keys.sorted { $0 < $1 }
        let lowInfoNames = sortedKeys.filter({ name in
            return isFullNameLowInfo(name)
        })
        for lowInfoName in lowInfoNames {
            let lowInfoFirstName = lowInfoName.firstName.lowercased()
            let lowInfoLastName = lowInfoName.lastName.lowercased()
            // add possible matches
            let matches = contexts.keys.filter({ name in
                if lowInfoName == name || isFullNameLowInfo(name) {
                    // don't match ourself or any low-info name (including those outside our array above)
                    return false
                }
                let firstName = name.firstName.lowercased()
                let lastName = name.lastName.lowercased()
                if lowInfoFirstName == firstName {
                    if (lowInfoLastName.isEmpty && nameCharactersValid(lowInfoLastName)) ||
                        (lastName.count > 1 && lastName.first == lowInfoLastName.first) {
                        // if last name is empty or has charachtes in it, match any last name
                        // also match first letter of last name matches
                        return true
                    }
                    else if let hyphenIndex = lastName.firstIndex(of: "-"), hyphenIndex < lastName.endIndex {
                        // if the name has a hyphen and the second letter of the hyphenated name matches our last naem
                        let charAfterHyphenIndex = lastName.index(after: hyphenIndex)
                        return lastName[charAfterHyphenIndex] == lastName.first
                    }
                }
                return false
            })
            lowInfoClientMatches[lowInfoName] = matches.sorted()
            lowInfoClientNames.append(lowInfoName)
        }
    }
    
    private func performMerge(of client: FullName, intoClientIn firstContext: ClientContext, withUserEnteredNameOrNil fullName: FullName?) {
        var replacementContext:ClientContext?
        // do the logic to copy
        if let datesToCpoy = clients[client] {
            var newName:FullName?
            if let fullName = fullName {
                // user entered a name
                newName = fullName
            }
            else if let match = currentMatch {
                // otherwise they clicked "Yes" to the match
                newName = match
            }
            if let newName = newName {
                if clients.keys.contains(newName) {
                    // append the dates to the better name's dates
                    clients[newName]!.append(contentsOf: datesToCpoy)
                } else {
                    // we got it from the all clients name list so copy the dates to a new entry with the better name
                    self.clients[newName] = datesToCpoy
                }
                if let existingContext = contexts[newName] {
                    replacementContext = existingContext
                } else {
                    let newContext = ClientContext(initialRawNameString: "", cleanFullName: newName)
                    contexts[newName] = newContext
                    replacementContext = newContext
                }
            }
            
            if let replacementContext = replacementContext {
                // create a merged pair for exporting
                mergePairs.append(MergedPair(original: firstContext, replacement: replacementContext))
            }
            // remove low-info name
            clients.removeValue(forKey: client)
        }
    }
    
    private func reconcileClients() {
        if /* NUMBER_OF_MERGES_COUNTER < 20,*/ let client = currentClient {
            let mergeController = MergeClientController(nibName: MergeClientController.nibName, bundle: nil)
            let firstContext = contexts[client]!
            var secondContext:ClientContext?
            if let match = currentMatch {
                secondContext = contexts[match]
            }
            mergeController.clientDifference = ClientDifference(firstContext: firstContext, secondContext: secondContext)
            let matchCount = lowInfoClientMatches[client]!.count
            mergeController.matchCount = matchCount
            
            mergeController.affirmativeSelectionHandler = { fullName in
//                self.NUMBER_OF_MERGES_COUNTER += 1
                self.performMerge(of: client, intoClientIn: firstContext, withUserEnteredNameOrNil: fullName)
                // we found a match, remove the current and go again
                self.removeCurrentClient()
                self.reconcileClients()
            }
            if !isFirstMatchOrNil() {
                mergeController.previousSelectionHandler = {
                    self.navigating = true
                    self.movePrevious()
                    self.reconcileClients()
                }
            }
            if !isLastMatchOrNil(){
                mergeController.nextSelectionHandler = {
                    self.navigating = true
                    self.moveNext()
                    self.reconcileClients()
                }
            }
            if isLastMatchOrNil() || matchCount > 5 {
                mergeController.promptForNameEntry = true // ask for manual entry if we don't have matches or user has arrived at last
                mergeController.negativeSelectionHandler = {
                    // we ruled out this match, remove it and go to the next match or client
                    self.moveNextClient() // changed behavior to skip, so move next client
                    self.reconcileClients()
                }
            }
            
            // present the view
            if navigating {
                navigating = false
                mergeController.modalTransitionStyle = .crossDissolve
            }
            mergeController.modalPresentationStyle = .pageSheet
            presentingViewController?.present(mergeController, animated: true, completion: nil)
        } else {
            // TODO: we're out of low-info clients, build our list now (for now wait to save debug txt?)
            self.completionHandler?(clients)
        }
    }
}
