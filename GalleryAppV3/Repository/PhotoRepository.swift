//
//  PhotoRepository.swift
//  GalleryAppV3
//
//  Created by Марк Русаков on 10.02.26.
//

import Foundation

protocol PhotoRepositoryProtocol {
    func loadFirstPage(completion: @escaping (Result<[Photo], Error>) -> Void)
    func loadNextPage(completion: @escaping (Result<[Photo], Error>) -> Void)
    func reset()
}

final class PhotoRepository: PhotoRepositoryProtocol {

    private let apiClient: UnsplashAPIClientProtocol
    private let perPage: Int

    private var currentPage: Int = 0
    private var isLoading: Bool = false
    private var hasMore: Bool = true

    init(apiClient: UnsplashAPIClientProtocol, perPage: Int = 30) {
        self.apiClient = apiClient
        self.perPage = perPage
    }

    func reset() {
        currentPage = 0
        hasMore = true
    }

    func loadFirstPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        reset()
        loadNextPage(completion: completion)
    }

    func loadNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard !isLoading, hasMore else { return }

        isLoading = true
        let nextPage = currentPage + 1

        apiClient.fetchPhotos(page: nextPage, perPage: perPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false

            switch result {
            case .success(let photos):
                self.currentPage = nextPage
                if photos.isEmpty {
                    self.hasMore = false
                }
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

