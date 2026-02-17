//
//  FavoritesViewController.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

final class FavoritesViewController: UIViewController {

    private var collectionView: UICollectionView?
    private let viewModel: FavoritesViewModel
    private let favoritesStore: FavoritesStoreProtocol
    private let imageLoader: ImageLoadingServiceProtocol

    init(viewModel: FavoritesViewModel, favoritesStore: FavoritesStoreProtocol, imageLoader: ImageLoadingServiceProtocol) {
        self.viewModel = viewModel
        self.favoritesStore = favoritesStore
        self.imageLoader = imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("gallery.favorites.title", comment: "")
        configureCollectionView()
        viewModel.reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let inset = AppConstants.Gallery.inset
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = inset
        layout.minimumInteritemSpacing = inset

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
        collectionView = cv
    }
}

extension FavoritesViewController: FavoritesViewModelDelegate {
    func favoritesDidUpdate() {
        collectionView?.reloadData()
    }

    func favoritesDidFail(with error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("alert.error_title", comment: ""),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("alert.ok", comment: ""), style: .default))
        present(alert, animated: true)
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryCollectionViewCell.reuseIdentifier, for: indexPath) as? GalleryCollectionViewCell,
            indexPath.item < viewModel.photos.count
        else {
            return UICollectionViewCell()
        }
        let photo = viewModel.photos[indexPath.item]
        let isFav = viewModel.isFavorite(id: photo.id)
        cell.displayedPhotoId = photo.id
        cell.configure(with: nil, isFavorite: isFav)
        cell.onFavoriteTap = { [weak self] in
            self?.viewModel.toggleFavorite(id: photo.id)
            self?.viewModel.reload()
        }

        imageLoader.load(url: photo.smallURL) { [weak self] result in
            guard cell.displayedPhotoId == photo.id else { return }
            let image = try? result.get()
            cell.configure(with: image, isFavorite: self?.viewModel.isFavorite(id: photo.id) ?? false)
        }

        return cell
    }
}

extension FavoritesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photos = viewModel.photos
        guard !photos.isEmpty else { return }
        let pageVC = PhotoDetailPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.photos = photos
        pageVC.initialIndex = indexPath.item
        pageVC.favoritesStore = favoritesStore
        pageVC.imageLoader = imageLoader
        navigationController?.pushViewController(pageVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = AppConstants.Gallery.columnsCount
        let inset = AppConstants.Gallery.inset
        let paddingSpace = inset * (itemsPerRow + 1)
        let availableWidth = collectionView.bounds.width - paddingSpace
        let width = floor(availableWidth / itemsPerRow)
        return CGSize(width: width, height: width)
    }
}
