//
//  PhotoDetailViewController.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

final class PhotoDetailViewController: UIViewController {

    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let authorLabel = UILabel()
    private var favoriteBarButton: UIBarButtonItem?

    var photo: Photo? {
        didSet {
            configureContent()
            updateFavoriteButton()
        }
    }

    var favoritesStore: FavoritesStoreProtocol? {
        didSet { updateFavoriteButton() }
    }

    var imageLoader: ImageLoadingServiceProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        configureFavoriteButton()
        configureContent()
        updateFavoriteButton()
    }

    private func configureFavoriteButton() {
        let button = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(favoriteTapped))
        favoriteBarButton = button
        navigationItem.rightBarButtonItem = button
    }

    @objc private func favoriteTapped() {
        guard let photo = photo, let store = favoritesStore else { return }
        store.toggleFavorite(id: photo.id)
        updateFavoriteButton()
    }

    private func updateFavoriteButton() {
        guard let photo = photo, let store = favoritesStore else { return }
        let isFavorite = store.isFavorite(id: photo.id)
        let image = UIImage(systemName: isFavorite ? "heart.fill" : "heart")
        favoriteBarButton?.image = image
        favoriteBarButton?.tintColor = isFavorite ? .systemRed : .systemGray
    }

    private func configureLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)

        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        authorLabel.textColor = .secondaryLabel

        view.addSubview(imageView)
        view.addSubview(descriptionLabel)
        view.addSubview(authorLabel)

        let margin = AppConstants.Layout.detailHorizontalMargin
        let spacing = AppConstants.Layout.detailVerticalSpacing
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: spacing),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),

            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: AppConstants.Layout.detailAuthorTopSpacing),
            authorLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            authorLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -spacing)
        ])
    }

    private func configureContent() {
        guard let photo = photo else { return }
        guard imageView.superview != nil else { return }

        descriptionLabel.text = photo.description ?? NSLocalizedString("detail.no_description", comment: "")
        authorLabel.text = String(format: NSLocalizedString("detail.author_format", comment: ""), photo.userName)
        imageView.image = nil

        imageLoader?.load(url: photo.regularURL) { [weak self] result in
            switch result {
            case .success(let image):
                self?.imageView.image = image
            case .failure:
                self?.imageView.image = nil
            }
        }
    }
}

