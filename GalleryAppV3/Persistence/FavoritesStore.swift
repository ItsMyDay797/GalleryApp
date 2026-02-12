//
//  FavoritesStore.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation

protocol FavoritesStoreProtocol {
    func isFavorite(id: String) -> Bool
    func toggleFavorite(id: String)
}

final class FavoritesStore: FavoritesStoreProtocol {

    private let defaults: UserDefaults
    private let key = "favorite_photo_ids"

    private var favorites: Set<String>

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.array(forKey: key) as? [String] {
            favorites = Set(stored)
        } else {
            favorites = []
        }
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains(id)
    }

    func toggleFavorite(id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        defaults.set(Array(favorites), forKey: key)
    }
}

