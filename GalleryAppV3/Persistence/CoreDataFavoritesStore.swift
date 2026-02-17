//
//  CoreDataFavoritesStore.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import CoreData

final class CoreDataFavoritesStore: FavoritesStoreProtocol {

    private let stack: CoreDataStack
    private let context: NSManagedObjectContext
    private var favorites: Set<String>

    init(stack: CoreDataStack) throws {
        self.stack = stack
        self.context = stack.container.viewContext
        self.favorites = []
        try loadFavorites()
        try migrateFromUserDefaultsIfNeeded()
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(id: String) {
        context.performAndWait {
            do {
                if favorites.contains(id) {
                    if let object = try fetchObject(id: id) {
                        context.delete(object)
                    }
                    favorites.remove(id)
                } else {
                    let object = NSEntityDescription.insertNewObject(forEntityName: "FavoritePhoto", into: context)
                    object.setValue(id, forKey: "id")
                    object.setValue(Date(), forKey: "createdAt")
                    favorites.insert(id)
                }
                if context.hasChanges {
                    try context.save()
                }
            } catch {
                context.rollback()
                do {
                    try loadFavorites()
                } catch {
                    assertionFailure(error.localizedDescription)
                }
                assertionFailure(error.localizedDescription)
            }
        }
    }

    func favoriteIds() -> [String] {
        Array(favorites)
    }

    private func loadFavorites() throws {
        let request = NSFetchRequest<NSManagedObject>(entityName: "FavoritePhoto")
        let result = try context.fetch(request)
        favorites = Set(result.compactMap { $0.value(forKey: "id") as? String })
    }

    private func fetchObject(id: String) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "FavoritePhoto")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first
    }

    private func migrateFromUserDefaultsIfNeeded() throws {
        guard favorites.isEmpty else { return }
        let defaults = UserDefaults.standard
        let key = "favorite_photo_ids"
        guard let stored = defaults.array(forKey: key) as? [String], !stored.isEmpty else { return }

        for id in stored {
            let object = NSEntityDescription.insertNewObject(forEntityName: "FavoritePhoto", into: context)
            object.setValue(id, forKey: "id")
            object.setValue(Date(), forKey: "createdAt")
            favorites.insert(id)
        }

        if context.hasChanges {
            try context.save()
        }
        defaults.removeObject(forKey: key)
    }
}

