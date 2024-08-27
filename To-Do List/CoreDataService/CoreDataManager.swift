//
//  CoreDataManager.swift
//  To-Do List
//
//  Created by Антон Павлов on 27.08.2024.
//

import CoreData
import UIKit

final class CoreDataManager {
    
    // MARK: - Static
    
    static let shared = CoreDataManager()
    
    // MARK: - Public Properties
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskEntity")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Public Methods
    
    func saveTask(
        id: Int64,
        title: String,
        descriptionText: String,
        creationDate: Date,
        isCompleted: Bool,
        color: UIColor,
        isPinned: Bool
    ) {
        let task = TaskEntity(context: context)
        task.id = id
        task.title = title
        task.descriptionText = descriptionText
        task.creationDate = creationDate
        task.isCompleted = isCompleted
        task.color = color
        task.isPinned = isPinned
        
        saveContext()
    }
    
    func fetchTasks() -> [TaskEntity] {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }
    
    func deleteTask(_ task: TaskEntity) {
        context.delete(task)
        saveContext()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Initializer
    
    private init() {}
}

