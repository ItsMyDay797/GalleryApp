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
    var imageLoader: ImageLoadingServiceProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        guard !photos.isEmpty, initialIndex >= 0, initialIndex < photos.count else { return }
        let vc = makeDetailViewController(index: initialIndex)
        setViewControllers([vc], direction: .forward, animated: false)
    }

    private func makeDetailViewController(index: Int) -> PhotoDetailViewController {
        let vc = PhotoDetailViewController()
        vc.photo = photos[index]
        vc.favoritesStore = favoritesStore
        vc.imageLoader = imageLoader
        return vc
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
    ) {}
}
