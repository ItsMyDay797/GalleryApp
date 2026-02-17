//
//  ImageLoadingService.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import UIKit

protocol ImageLoadingServiceProtocol {
    func load(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class ImageLoadingService: ImageLoadingServiceProtocol {

    private let session: URLSession
    private let cache: NSCache<NSURL, UIImage>

    init(session: URLSession = .shared, cacheCountLimit: Int = AppConstants.ImageCache.countLimit, cacheTotalCostLimit: Int = AppConstants.ImageCache.totalCostLimitBytes) {
        self.session = session
        self.cache = NSCache<NSURL, UIImage>()
        self.cache.countLimit = cacheCountLimit
        self.cache.totalCostLimit = cacheTotalCostLimit
    }

    func load(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            completion(.success(cached))
            return
        }

        session.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(.failure(ImageLoadingError.invalidData)) }
                return
            }
            let cost = data.count
            self?.cache.setObject(image, forKey: key, cost: cost)
            DispatchQueue.main.async { completion(.success(image)) }
        }.resume()
    }
}

enum ImageLoadingError: LocalizedError {
    case invalidData
    var errorDescription: String? { "Не удалось загрузить изображение." }
}
