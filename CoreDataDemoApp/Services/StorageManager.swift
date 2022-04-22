//
//  StorageManager.swift
//  CoreDataDemoApp
//
//  Created by Aleksandr Kretov on 19.04.2022.
//

import CoreData
import Foundation

class StorageManager {
    
    static let shared = StorageManager()

    // MARK: - Core Data stack
    
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemoApp")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext

    private init() {
        viewContext = persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //MARK: - CRUD
    
    func fetchData(completion: (Result<[ToDoTask], Error>) -> Void) {
        let fetchRequest = ToDoTask.fetchRequest()
        do {
            let tasks = try self.viewContext.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func create(_ taskName: String, completion: (ToDoTask) -> Void) {
        let task = ToDoTask(context: viewContext)
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func update(_ task: ToDoTask, newName: String) {
        task.title = newName
        saveContext()
    }
    
    func delete(_ task: ToDoTask) {
        viewContext.delete(task)
        saveContext()
    }
}
