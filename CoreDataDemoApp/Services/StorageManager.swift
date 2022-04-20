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

    private init() {}

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func fetchData() -> [ToDoTask] {
        var taskList: [ToDoTask] = []
        let fetchRequest = ToDoTask.fetchRequest()
        do {
            taskList = try self.persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error.localizedDescription)
        }
        return taskList
    }

    func save(task: ToDoTask) {
        self.persistentContainer.viewContext.insert(task)
        if self.persistentContainer.viewContext.hasChanges {
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                print(error)
            }
        }
    }

    func delete(task: ToDoTask) {
        self.persistentContainer.viewContext.delete(task)
        if self.persistentContainer.viewContext.hasChanges {
            do {
                try self.persistentContainer.viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}
