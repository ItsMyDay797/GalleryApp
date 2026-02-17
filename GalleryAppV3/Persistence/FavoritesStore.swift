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
    func favoriteIds() -> [String]
}
