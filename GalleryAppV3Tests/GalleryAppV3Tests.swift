//
//  GalleryAppV3Tests.swift
//  GalleryAppV3Tests
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation
import Testing
@testable import GalleryAppV3

struct GalleryAppV3Tests {

    @Test @MainActor func favoritesStoreToggleAndCheck() async throws {
        let stack = try CoreDataStack(inMemory: true)
        let store = try CoreDataFavoritesStore(stack: stack)
        let id = "photo_1"

        #expect(store.isFavorite(id: id) == false)
        store.toggleFavorite(id: id)
        #expect(store.isFavorite(id: id) == true)
        store.toggleFavorite(id: id)
        #expect(store.isFavorite(id: id) == false)
    }
}
