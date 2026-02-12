//
//  PhotoDetailPageViewController.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

final class PhotoDetailPageViewController: UIPageViewController {

    var photos: [Photo] = []
    var initialIndex: Int = 0
    var favoritesStore: FavoritesStoreProtocol?

    private var favoriteBarButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        let button = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(favoriteTapped))
        favoriteBarButton = button
        navigationItem.rightBarButtonItem = button

        guard !photos.isEmpty, initialIndex >= 0, initialIndex < photos.count else { return }
        let vc = makeDetailViewController(index: initialIndex)
        setViewControllers([vc], direction: .forward, animated: false)
        updateFavoriteButton()
    }

    private func makeDetailViewController(index: Int) -> PhotoDetailViewController {
        let vc = PhotoDetailViewController()
        vc.photo = photos[index]
        vc.favoritesStore = favoritesStore
        vc.hideNavBarFavoriteButton = true
        return vc
    }

    private var currentPhoto: Photo? {
        (viewControllers?.first as? PhotoDetailViewController)?.photo
    }

    private func updateFavoriteButton() {
        guard let photo = currentPhoto, let store = favoritesStore else { return }
        let isFavorite = store.isFavorite(id: photo.id)
        favoriteBarButton?.image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favoriteBarButton?.tintColor = isFavorite ? .systemRed : .systemGray
    }

    @objc private func favoriteTapped() {
        guard let photo = currentPhoto, let store = favoritesStore else { return }
        store.toggleFavorite(id: photo.id)
        updateFavoriteButton()
    }
}

// MARK: - UIPageViewControllerDataSource

extension PhotoDetailPageViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let detail = viewController as? PhotoDetailViewController,
              let photo = detail.photo,
              let idx = photos.firstIndex(where: { $0.id == photo.id }),
              idx > 0 else { return nil }
        return makeDetailViewController(index: idx - 1)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let detail = viewController as? PhotoDetailViewController,
              let photo = detail.photo,
              let idx = photos.firstIndex(where: { $0.id == photo.id }),
              idx < photos.count - 1 else { return nil }
        return makeDetailViewController(index: idx + 1)
    }
}

// MARK: - UIPageViewControllerDelegate

extension PhotoDetailPageViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed { updateFavoriteButton() }
    }
}
