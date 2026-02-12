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

    private(set) var photos: [Photo] = []

    weak var delegate: GalleryViewModelDelegate?

    private let imageCache: NSCache<NSURL, UIImage> = {
        let c = NSCache<NSURL, UIImage>()
        c.countLimit = 100
        c.totalCostLimit = 50 * 1024 * 1024
        return c
    }()

    // MARK: - Init

    init(repository: PhotoRepositoryProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    // MARK: - Data Loading

    func reload() {
        repository.loadFirstPage { [weak self] result in
            self?.handle(result: result, reset: true)
        }
    }

    func loadMoreIfNeeded(currentIndex: Int) {
        let thresholdIndex = photos.count - 6
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

    // MARK: - Images

    func thumbnail(for photo: Photo, completion: @escaping (UIImage?) -> Void) {
        let url = photo.smallURL as NSURL

        if let cached = imageCache.object(forKey: url) {
            completion(cached)
            return
        }

        URLSession.shared.dataTask(with: photo.smallURL) { [weak self] data, _, _ in
            var image: UIImage?
            if let data = data {
                image = UIImage(data: data)
            }

            if let image = image {
                let cost = image.jpegData(compressionQuality: 1)?.count ?? 0
                self?.imageCache.setObject(image, forKey: url, cost: cost)
            }

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

