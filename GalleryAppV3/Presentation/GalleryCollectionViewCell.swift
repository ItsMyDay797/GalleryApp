//
//  GalleryCollectionViewCell.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "GalleryCollectionViewCell"

    var displayedPhotoId: String?
    var onFavoriteTap: (() -> Void)?

    private let imageView = UIImageView()
    private let favoriteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.tintColor = .systemRed
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)

        contentView.addSubview(imageView)
        contentView.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            favoriteButton.widthAnchor.constraint(equalToConstant: 44),
            favoriteButton.heightAnchor.constraint(equalToConstant: 44),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            favoriteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    func configure(with image: UIImage?, isFavorite: Bool) {
        imageView.image = image
        let symbolName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: symbolName), for: .normal)
    }

    @objc private func favoriteButtonTapped() {
        onFavoriteTap?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        displayedPhotoId = nil
        onFavoriteTap = nil
        imageView.image = nil
        favoriteButton.setImage(nil, for: .normal)
    }
}

