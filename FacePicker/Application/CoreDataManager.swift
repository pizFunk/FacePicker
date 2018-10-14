//
//  CoreDataManager.swift
//  FacePicker
//
//  Created by matthew on 10/11/18.
//  Copyright © 2018 matthew. All rights reserved.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() { }
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "FacePicker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                Application.onError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        get {
            return persistentContainer.viewContext
        }
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                Application.logInfo("Saved ManagedContext")
            } catch {
                let nserror = error as NSError
                Application.onError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func create<T:NSManagedObject>() -> T {
        return T(context: context)
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    func fetchAll<T:NSManagedObject>() -> [T]? {
        let request = NSFetchRequest<T>(entityName: String.init(describing: T.self))
        return try? context.fetch(request)
    }
}
