//
//  FavoritesViewModel.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation

protocol FavoritesViewModelDelegate: AnyObject {
    func favoritesDidUpdate()
    func favoritesDidFail(with error: Error)
}

final class FavoritesViewModel {

    private let store: FavoritesStoreProtocol
    private let repository: PhotoRepositoryProtocol

    private(set) var photos: [Photo] = []
    weak var delegate: FavoritesViewModelDelegate?

    init(store: FavoritesStoreProtocol, repository: PhotoRepositoryProtocol) {
        self.store = store
        self.repository = repository
    }

    func reload() {
        let ids = store.favoriteIds()
        guard !ids.isEmpty else {
            photos = []
            delegate?.favoritesDidUpdate()
            return
        }

        var loaded: [Photo] = []
        let lock = NSLock()
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            repository.loadPhoto(id: id) { result in
                if case .success(let photo) = result {
                    lock.lock()
                    loaded.append(photo)
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.photos = loaded
            self?.delegate?.favoritesDidUpdate()
        }
    }

    func isFavorite(id: String) -> Bool {
        store.isFavorite(id: id)
    }

    func toggleFavorite(id: String) {
        store.toggleFavorite(id: id)
    }
}
