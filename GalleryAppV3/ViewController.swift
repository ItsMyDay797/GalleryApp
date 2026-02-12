//
//  ViewController.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

final class ViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var viewModel: GalleryViewModel!
    private var favoritesStore: FavoritesStoreProtocol!
    private var previousPhotoCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Gallery"

        configureDependencies()
        configureCollectionView()

        viewModel.reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let indexPaths = collectionView?.indexPathsForVisibleItems ?? []
        if !indexPaths.isEmpty {
            collectionView?.reloadItems(at: indexPaths)
        }
    }

    private func configureDependencies() {
        do {
            let apiClient = try UnsplashAPIClient()
            let repository = PhotoRepository(apiClient: apiClient)
            let store = FavoritesStore()
            self.favoritesStore = store
            let vm = GalleryViewModel(repository: repository, favoritesStore: store)
            vm.delegate = self
            self.viewModel = vm
        } catch {
            showError(error)
        }
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: GalleryCollectionViewCell.reuseIdentifier)

        view.addSubview(cv)
        NSLayoutConstraint.activate([
            cv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        self.collectionView = cv
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - GalleryViewModelDelegate

extension ViewController: GalleryViewModelDelegate {
    func galleryDidUpdate(reloadAll: Bool) {
        let count = viewModel.photos.count
        if reloadAll {
            previousPhotoCount = count
            collectionView.reloadData()
        } else {
            let newCount = count - previousPhotoCount
            guard newCount > 0 else { return }
            let start = previousPhotoCount
            let indexPaths = (start..<count).map { IndexPath(item: $0, section: 0) }
            previousPhotoCount = count
            collectionView.performBatchUpdates {
                collectionView.insertItems(at: indexPaths)
            }
        }
    }

    func galleryDidFail(with error: Error) {
        showError(error)
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.photos.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseIdentifier, for: indexPath) as? GalleryCollectionViewCell,
            let photo = viewModel?.photos[indexPath.item]
        else {
            return UICollectionViewCell()
        }

        let isFav = viewModel.isFavorite(id: photo.id)
        cell.displayedPhotoId = photo.id
        cell.configure(with: nil, isFavorite: isFav)
        cell.onFavoriteTap = { [weak self] in
            self?.viewModel.toggleFavorite(id: photo.id)
            self?.collectionView.reloadItems(at: [indexPath])
        }

        viewModel.thumbnail(for: photo) { [weak self] image in
            guard cell.displayedPhotoId == photo.id else { return }
            cell.configure(with: image, isFavorite: self?.viewModel.isFavorite(id: photo.id) ?? false)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photos = viewModel?.photos, !photos.isEmpty else { return }
        let pageVC = PhotoDetailPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageVC.photos = photos
        pageVC.initialIndex = indexPath.item
        pageVC.favoritesStore = favoritesStore
        navigationController?.pushViewController(pageVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        viewModel.loadMoreIfNeeded(currentIndex: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let paddingSpace = 12 * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let width = floor(availableWidth / itemsPerRow)
        return CGSize(width: width, height: width)
    }
}

