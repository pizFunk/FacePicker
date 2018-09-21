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

class ClientListController: UITableViewController, ClientControllerDelegate, ContextMenuDelegate, ClientDetailControllerDelegate, UISearchResultsUpdating {
    private let showClientDetailSegue = "ShowClientDetailSegue"
    var selectedRowBeforeEdit:Int?
    var clients: [Client] = [Client]()
    var filteredClients: [Client] = [Client]()
    let searchController = UISearchController(searchResultsController: nil)
    var delegate: ClientSelectionChangedDelegate?

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Private Functions
    private func fetchClients() {
        let context = managedContext()
        let request:NSFetchRequest<Client> = Client.fetchRequest()
        do {
            self.clients = try context.fetch(request)
            sortClients()
        } catch {
            fatalError("Could not load Clients in ClientsController")
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
    private func setSelectedClient(client: Client) {
        var index:Int?
        if isFiltering() {
            index = filteredClients.index(of: client)
        } else {
            index = clients.index(of: client)
        }
        if index != nil {
            tableView.selectRow(at: IndexPath(row: index!, section: 0), animated: true, scrollPosition: .none)
        }
    }
    private func sortClients() {
        clients.sort(by: { return $0.firstName.lowercased() < $1.firstName.lowercased() })
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
    
    //MARK: - ContextMenuDelegate
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
    }
    
    // MARK: - ClientControllerDelegate
    func clientControllerDidSave(client: Client) {
        clients.append(client)
        sortClients()
        let index = clients.index(of: client)!
        tableView.reloadData()
        tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
        tableView(tableView, didSelectRowAt: IndexPath(item: index, section: 0))
    }
    
    // MARK - ClientDetailControllerDelegate
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
    
    // UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let selectedClient = getSelectedClient()
        
        filteredClients = clients.filter({ (client) -> Bool in
            return client.formattedName().lowercased().contains(searchController.searchBar.text!.lowercased())
        })
        tableView.reloadData()
        
        if let client = selectedClient {
            setSelectedClient(client: client)
        }
        // else pass nil?
        // delegate?.clientSelectionDidChange(nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredClients.count
        } else {
            return clients.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "ClientTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? ClientTableViewCell else {
            fatalError("Dequeued cell was not ClientTableViewCell as expected.")
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
                fatalError("ClientListController: clientDetailController did not have a NavigationController!")
            }
            showDetailViewController(navigationController, sender: nil)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
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
                tableView.selectRow(at: IndexPath(row: selectedRow, section: 0), animated: false, scrollPosition: .none)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            let removedClient: Client
            if isFiltering() {
                removedClient = filteredClients.remove(at: indexPath.row)
                guard let index = clients.index(of: removedClient) else {
                    fatalError("Failed to remove deleted filtered client from clients")
                }
                clients.remove(at: index)
            } else {
                removedClient = clients.remove(at: indexPath.row)
            }
            let context = managedContext()
            context.delete(removedClient)
            appDelegate().saveContext()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            // if deleting current
            if selectedRowBeforeEdit == indexPath.row {
                // reset the detail controller
                performSegue(withIdentifier: showClientDetailSegue, sender: nil)
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

    // MARK: - Navigation

    //MARK: - Actions
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        let clientController = ClientController(nibName: "ClientController", bundle: nil)
        clientController.delegate = self
        showContextualMenu(
            clientController,
            options: ContextMenu.Options(
                allowTapDismiss: false),
            delegate: self)
    }
}

protocol ClientSelectionChangedDelegate {
    func clientSelectionDidChange(_ client: Client?)
}