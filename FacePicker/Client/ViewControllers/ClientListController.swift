//
//  ClientsController.swift
//  FacePicker
//
//  Created by matthew on 9/12/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import UIKit
import CoreData
import ContextMenu

//MARK: - Properties

class ClientListController: UITableViewController {
        
    let searchController = UISearchController(searchResultsController: nil)
    var selectedRowBeforeEdit:Int?
    var clients: [Client] = [Client]()
    var filteredClients: [Client] = [Client]()
    var delegate: ClientSelectionChangedDelegate?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - Public Functions

extension ClientListController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        setEditButtonTitle()
//        UISearchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Clients"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
//        tableView.tableHeaderView = searchController.searchBar
        //definesPresentationContext = true
        
        fetchClients()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ClientListController.onListAllClientsSettingDidChange(notification:)), name: .listAllClientsSettingDidChange, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Change "Edit" button title to "Delete"
    override func setEditing(_ editing: Bool, animated: Bool) {
        if let indexPath = tableView.indexPathForSelectedRow, editing {
            selectedRowBeforeEdit = indexPath.row
        }
        super.setEditing(editing, animated: animated)
        if !editing {
            setEditButtonTitle()
            // if we didn't delete the current selected row, reselect it
            if let selectedRow = selectedRowBeforeEdit {
                tableView.selectRow(at: IndexPath(row: selectedRow, section: 0), animated: true, scrollPosition: .middle)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let clientController = ClientController(nibName: ClientController.nibName, bundle: nil)
        clientController.delegate = self
        showContextualMenu(
            clientController,
            options: ContextMenu.Options(
                allowTapDismiss: false),
            delegate: self)
    }
    
    @objc func onListAllClientsSettingDidChange(notification: Notification) {
        if !isFiltering() {
            tableView.reloadData()
            delegate?.clientSelectionDidChange(nil)
        }
    }
}

//MARK: - Private Functions

private extension ClientListController {
    
    private func fetchClients() {
        if let clients = Client.fetchClients(context: managedContext()) {
            self.clients = clients
            sortClients()
        }
    }
    
    private func getSelectedClient() -> Client? {
        if let indexPath = tableView.indexPathForSelectedRow {
            if filteredClients.count > 0 {
                return filteredClients[indexPath.row]
            } else {
                return clients[indexPath.row]
            }
        }
        return nil
    }
    
    @discardableResult
    private func setSelectedClient(client: Client) -> Bool {
        var index:Int?
        if isFiltering() {
            index = filteredClients.index(of: client)
        } else {
            index = clients.index(of: client)
        }
        if index != nil {
            tableView.selectRow(at: IndexPath(row: index!, section: 0), animated: false, scrollPosition: .middle)
            return true
        }
        return false
    }
    
    private func sortClients() {
        clients.sort(by: {
            if $0.firstName.lowercased() == $1.firstName.lowercased() {
                return $0.lastName.lowercased() < $1.lastName.lowercased()
            }
            return $0.firstName.lowercased() < $1.firstName.lowercased()
        })
    }
    
    private func setEditButtonTitle() {
        self.editButtonItem.title = "Delete"
    }
    
    private func searchBarEmpty() -> Bool {
        return (searchController.searchBar.text?.isEmpty ?? true)
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarEmpty()
    }
}

extension ClientListController: ContextMenuDelegate {
    
    //MARK: - ContextMenuDelegate
    
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
    }
}

// MARK: - ClientControllerDelegate

extension ClientListController: ClientControllerDelegate {
    
    func clientControllerDidSave(client: Client) {
        clients.append(client)
        sortClients()
        let index = clients.index(of: client)!
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .middle)
        tableView(tableView, didSelectRowAt: IndexPath(item: index, section: 0))
    }
}

// MARK - ClientDetailControllerDelegate

extension ClientListController: ClientDetailControllerDelegate {
    
    func clientNameWasEdited(client: Client) {
        
        if let index = clients.index(of: client),
            let cell = tableView.cellForRow(at: IndexPath(item: index, section: 0)) as? ClientTableViewCell {
            let selectedClient = getSelectedClient()
            
            cell.nameLabel.text = client.formattedName()
            sortClients()
            tableView.reloadData()
            
            if let client = selectedClient {
                setSelectedClient(client: client)
            }
        }
    }
    
    func setEditingSessions(_ editing: Bool) {
        print("need to \(editing ? "disable" : "enable") client list view!")
        
        setEnabled(!editing)
    }
}

// UISearchResultsUpdating

extension ClientListController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let selectedClient = getSelectedClient()
        
        filteredClients = clients.filter({ (client) -> Bool in
            return client.formattedName().lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
        
        if selectedClient == nil || !setSelectedClient(client: selectedClient!) {
            delegate?.clientSelectionDidChange(nil)
        }
    }
}

// MARK: - UITableViewDataSource

extension ClientListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredClients.count
        } else if Application.Settings.listAllClients {
            return clients.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ClientTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ClientTableViewCell else {
            Application.onError("Dequeued cell was not ClientTableViewCell as expected.")
            return UITableViewCell()
        }

        let client: Client
        if isFiltering() {
            client = filteredClients[indexPath.row]
        } else {
            client = clients[indexPath.row]
        }
        cell.nameLabel.text = client.formattedName()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            let removedClient: Client
            if isFiltering() {
                removedClient = filteredClients.remove(at: indexPath.row)
                if let index = clients.index(of: removedClient) {
                    clients.remove(at: index)
                } else {
                    Application.onError("Failed to remove deleted filtered client from clients!")
                }
            } else {
                removedClient = clients.remove(at: indexPath.row)
            }
            let context = managedContext()
            Application.logInfo("Deleting Client with uuid: \(removedClient.id.uuidString)")
            context.delete(removedClient)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            // if deleting current
            if selectedRowBeforeEdit == indexPath.row {
                // reset the detail controller
                delegate?.clientSelectionDidChange(nil)
                selectedRowBeforeEdit = nil
            } else if let selectedRow = selectedRowBeforeEdit {
                // subtract from row if necessary
                if indexPath.row < selectedRow {
                    selectedRowBeforeEdit = selectedRow - 1
                }
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
}

// MARK: - UITableViewDelegate

extension ClientListController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.searchBar.resignFirstResponder()
        
        if isFiltering() {
            delegate?.clientSelectionDidChange(filteredClients[indexPath.row])
        } else {
            delegate?.clientSelectionDidChange(clients[indexPath.row])
        }
        if let clientDetailController = delegate as? ClientDetailController {
            // for when split view is collapsed to master only
            guard let navigationController = clientDetailController.navigationController else {
                Application.onError("clientDetailController did not have a NavigationController!")
                return
            }
            showDetailViewController(navigationController, sender: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
}

// MARK: - ClientSelectionChangedDelegate

protocol ClientSelectionChangedDelegate {
    func clientSelectionDidChange(_ client: Client?)
}
