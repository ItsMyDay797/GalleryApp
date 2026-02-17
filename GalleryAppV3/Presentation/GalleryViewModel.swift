//
//  GalleryViewModel.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation
import UIKit

protocol GalleryViewModelDelegate: AnyObject {
    func galleryDidUpdate(reloadAll: Bool)
    func galleryDidFail(with error: Error)
}

final class GalleryViewModel {

    // MARK: - Properties

    private let repository: PhotoRepositoryProtocol
    private let favoritesStore: FavoritesStoreProtocol
    private let imageLoader: ImageLoadingServiceProtocol

    private(set) var photos: [Photo] = []

    weak var delegate: GalleryViewModelDelegate?

    init(repository: PhotoRepositoryProtocol, favoritesStore: FavoritesStoreProtocol, imageLoader: ImageLoadingServiceProtocol) {
        self.repository = repository
        self.favoritesStore = favoritesStore
        self.imageLoader = imageLoader
    }

    // MARK: - Data Loading

    func reload() {
        repository.loadFirstPage { [weak self] result in
            self?.handle(result: result, reset: true)
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        let thresholdIndex = photos.count - AppConstants.Gallery.loadMoreThresholdFromEnd
        guard currentIndex >= thresholdIndex else { return }

        repository.loadNextPage { [weak self] result in
            self?.handle(result: result, reset: false)
        }
    }

    private func handle(result: Result<[Photo], Error>, reset: Bool) {
        switch result {
        case .success(let newPhotos):
            if reset {
                photos = newPhotos
            } else {
                photos.append(contentsOf: newPhotos)
            }
            delegate?.galleryDidUpdate(reloadAll: reset)
        case .failure(let error):
            delegate?.galleryDidFail(with: error)
        }
    }

    // MARK: - Favorites

    func isFavorite(id: String) -> Bool {
        favoritesStore.isFavorite(id: id)
    }

    func toggleFavorite(id: String) {
        favoritesStore.toggleFavorite(id: id)
    }

    func thumbnail(for photo: Photo, completion: @escaping (Result<UIImage, Error>) -> Void) {
        imageLoader.load(url: photo.smallURL, completion: completion)
    }
}

