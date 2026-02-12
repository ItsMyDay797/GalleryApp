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

    var hideNavBarFavoriteButton: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        configureFavoriteButton()
        configureContent()
        updateFavoriteButton()
    }

    private func configureFavoriteButton() {
        guard !hideNavBarFavoriteButton else { return }
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

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            authorLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            authorLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func configureContent() {
        guard let photo = photo else { return }
        guard imageView.superview != nil else { return }

        descriptionLabel.text = photo.description ?? "Без описания"
        authorLabel.text = "Автор: \(photo.userName)"
        imageView.image = nil

        URLSession.shared.dataTask(with: photo.regularURL) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }.resume()
    }
}

