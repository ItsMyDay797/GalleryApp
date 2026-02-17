//
//  CoreDataStack.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import CoreData

final class CoreDataStack {

    let container: NSPersistentContainer

    init(inMemory: Bool = false) throws {
        let container = NSPersistentContainer(name: "GalleryAppV3")
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }

        var loadError: Error?
        let semaphore = DispatchSemaphore(value: 0)
        container.loadPersistentStores { _, error in
            loadError = error
            semaphore.signal()
        }
        semaphore.wait()

        if let error = loadError {
            throw error
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
}

