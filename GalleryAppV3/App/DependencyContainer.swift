//
//  DependencyContainer.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

struct DependencyContainer {

    func makeGalleryViewController() -> UIViewController? {
        guard let apiClient = try? UnsplashAPIClient() else { return nil }
        let imageLoader = ImageLoadingService()
        guard let stack = try? CoreDataStack() else { return nil }
        guard let store = try? CoreDataFavoritesStore(stack: stack) else { return nil }
        let repository = PhotoRepository(apiClient: apiClient)
        let viewModel = GalleryViewModel(repository: repository, favoritesStore: store, imageLoader: imageLoader)
        let vc = ViewController(viewModel: viewModel, favoritesStore: store, imageLoader: imageLoader)
        viewModel.delegate = vc
        return vc
    }

    func makeFavoritesViewController(favoritesStore: FavoritesStoreProtocol) -> UIViewController? {
        guard let apiClient = try? UnsplashAPIClient() else { return nil }
        let imageLoader = ImageLoadingService()
        let repository = PhotoRepository(apiClient: apiClient)
        let viewModel = FavoritesViewModel(store: favoritesStore, repository: repository)
        let vc = FavoritesViewController(viewModel: viewModel, favoritesStore: favoritesStore, imageLoader: imageLoader)
        viewModel.delegate = vc
        return vc
    }
}
